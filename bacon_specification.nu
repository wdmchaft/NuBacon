(class BaconSpecification is NSObject
  (ivars (id) context
         (id) description
         (id) block
         (id) postponedBlock
         (id) hasPostponedBlock
         (id) before
         (id) after
         (id) report)

  (- (id) initWithContext:(id)context description:(id)description block:(id)block before:(id)beforeFilters after:(id)afterFilters report:(id)report is
    (self init)
    (set @context context)
    (set @description description)
    (set @block block)
    (set @hasPostponedBlock nil)
    (set @report report)
    ; create copies so that when the given arrays change later on, they don't change these
    (set @before (beforeFilters copy))
    (set @after (afterFilters copy))
    self
  )

  (- (id) runBeforeFilters is
    (@before each:(do (x) (@context instanceEval:x)))
  )

  (- (id) runAfterFiltersAndThrow:(id)shouldThrow is
    (try
      (@after each:(do (x) (@context instanceEval:x)))
      (catch (e)
        (if (shouldThrow) (throw e))
      )
    )
  )

  (- (id) run is
    (if (@report)
      ($BaconSummary addSpecification)
      (print "- #{@description}")
    )
    
    (set numberOfRequirementsBefore ($BaconSummary requirements))
    
    (try
      (try
        ; before
        (self runBeforeFilters)
        ; specification
        (@context instanceEval:@block)
        (if (eq numberOfRequirementsBefore ($BaconSummary requirements))
          ; the specification did not contain any requirements, so it flunked
          (throw ((BaconError alloc) initWithDescription:"flunked"))
        )
        ; after
        (catch (e)
          ; don't allow after filters to throw, as it could result in an endless loop
          (self runAfterFiltersAndThrow:nil)
          (throw e)
        )
        ; ensure the after filters are always run, these however may throw, as we already ran the specification
        (self runAfterFiltersAndThrow:t)
      )
      (catch (e) ; now really handle the bubbled exception
        (if (@report)
          (if (eq (e class) BaconError)
            (then
              ($BaconSummary addFailure)
              (set type " [FAILURE]")
            )
            (else
              ($BaconSummary addError)
              (set type " [ERROR]")
            )
          )
          (print type)
          ($BaconSummary addToErrorLog:e context:(@context name) specification:@description type:type)
        )
      )
    )

    (unless @hasPostponedBlock (self finalize))
  )

  (- (id) postponeBlock:(id)block withDelay:(id)seconds is
    (set @postponedBlock block)
    (set @hasPostponedBlock t)
    (self performSelector:"runPostponedBlock" withObject:nil afterDelay:seconds)
    ; TODO is it correct that I need to call this here, again?!
    ((NSRunLoop mainRunLoop) runUntilDate:(NSDate dateWithTimeIntervalSinceNow:seconds))
  )

  (- (id) runPostponedBlock is
    (@context instanceEval:@postponedBlock)
    (self finalize)
  )

  (- (id) finalize is
    (if (@report) (print "\n"))
    (@context specificationDidFinish:self)
  )
)
