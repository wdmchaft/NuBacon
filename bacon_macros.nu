(macro -> (blockBody *extraMessages)
  (if (> (*extraMessages count) 0)
    (then
      `(~ (send (do () ,blockBody) should) ,@*extraMessages)
    )
    (else
      `(send (do () ,blockBody) should)
    )
  )
)

(macro sendMessageWithList (object *body)
  (set __body (eval *body))
  (if (not (__body isKindOfClass:NuCell))
    (set __body (list __body))
  )
  `(,object ,@__body)
)

(macro ~ (*objectAndMessages)
  (set __object (eval (car *objectAndMessages)))
  (set __messages (cdr *objectAndMessages))

  (set __messagesWithoutArgs (NSMutableArray array))
  (set __lastMessageWithArgs nil)

  (while (> (__messages count) 0)
    (set __message (car __messages))
    (if (and (__message isKindOfClass:NuSymbol) ((__message stringValue) hasSuffix:":"))
      (then
        ; once we find the first NuSymbol that ends with a colon, i.e. part of a selector with args,
        ; then we take it and the rest as the last message
        (set __lastMessageWithArgs __messages)
        (set __messages `())
      )
      (else
        ; this is a selector without args, so remove it from the messages list and continue
        (__messagesWithoutArgs << __message)
        (set __messages (cdr __messages))
      )
    )
  )

  ; first dispatch all messages without arguments, if there are any
  ((__messagesWithoutArgs list) each:(do (__message)
    (set __object (sendMessageWithList __object __message))
  ))

  ; then either dispatch the last message with arguments, or return the BaconShould instance
  (if (__lastMessageWithArgs)
    (then (sendMessageWithList __object __lastMessageWithArgs))
    (else (__object))
  )
)

(macro describe (name requirements)
  `(try
    (set parent self)
    (parent childContextWithName:,name requirements:,requirements)
    (catch (e)
      (if (eq (e reason) "undefined symbol self while evaluating expression (set parent self)")
        (then
          ; not running inside a context
          ((BaconContext alloc) initWithName:,name requirements:,requirements)
        )
        ; another type of exception occured
        (else (throw e))
      )
    )
  )
)

(macro it (description block)
  `(self requirement:,description block:,block report:t)
)

(macro before (block)
  `(self before:,block)
)
(macro after (block)
  `(self after:,block)
)

; shared contexts

(set $BaconShared (NSMutableDictionary dictionary))

(macro shared (name requirements)
  `($BaconShared setValue:,requirements forKey:,name)
)

(macro behaves_like (name)
  (set context ($BaconShared valueForKey:name))
  (if (context)
    ; each requirement is a complete `it' block
    (then (context each: (do (requirement) (eval requirement))))
    (else (throw "No such context `#{name}'"))
  )
)
