NuBacon -- small RSpec clone
----------------------------

   "Truth will sooner come out from error than from confusion."
                                               ---Francis Bacon

NuBacon is a Nu port of Bacon, a small [Ruby RSpec][rs] clone.

It is a [Behavior-Driven Development][bdd] test library.


Whirl-wind tour
---------------

    (load "bacon")

    (set beEmptyArray (do (object) (eq (object count) 0)))

    (describe "An array" `(
      (before (do ()
        (set @ary (NSArray array))
        (set @otherArray (`("noodles") array))
      ))

      (it "is empty" (do ()
        (((@ary should) not) containObject:1)
      ))

      (it "has zero elements" (do ()
        (((@ary count) should) be:0)
        (((((@ary count) should) not) be) closeTo:0.1) ; default delta of 0.00001
        ((((@ary count) should) be) closeTo:0.1 delta:0.2)
      ))

      (it "raises when trying to fetch an element" (do ()
        ; TODO: this should work by not quoting, it's on the TODO
        ; ((`(@ary objectAtIndex:0) should) raise:NSRangeException)
        ((`((NSArray array) objectAtIndex:0) should) raise:"NSRangeException")
      ))

      (it "compares to another object" (do ()
        ((@ary should) be:@ary)
        ((@ary should) equal:@ary)
        (((@otherArray should) not) be:@ary)
        (((@otherArray should) not) equal:@ary)
      ))

      ; Custom assertions are trivial to do, they are blocks returning
      ; a boolean value. The block is defined at the top.
      (it "uses a custom assertion to check if the array is empty" (do ()
        (@ary should:beEmptyArray)
        (((@otherArray) should) not:beEmptyArray)
      ))

      ; TODO
      ;it 'should have super powers' do
        ;should.flunk "no super powers found"
      ;end
    ))

    ($BaconSummary print)

Now run it:

    $ nush readme_spec.nu

    An array
    - is empty
    - has zero elements
    - raises when trying to fetch an element
    - compares to another object
    - uses a custom assertion to check if the array is empty

    5 specifications (11 requirements), 0 failures, 0 errors

Implemented assertions
----------------------

* should:<predicate>
* should equal:object
* should closeTo:<float | list of floats>
* should closeTo:<float | list of floats> delta:float
* should raise
* should raise:exception
* should satisfy:message block:block


before/after
------------

before and after need to be defined before the first specification in
a context and are run before and after each specification.


Nested contexts
---------------

You can nest contexts, which will run before/after filters of parent
contexts like so:

    (describe "parent context" `(
      (describe "child context" `(
      ))
    ))

Shared contexts
---------------

You can define shared contexts in NuBacon like this:

    (shared "an empty container" `(
      (it "has size zero" (do ()
        (((@ary count) should) be:0)
      ))

      (it "is empty" (do ()
        (@ary should:beEmptyArray)
      ))
    ))

    (describe "A new array" `(
      (before (do ()
        (set @ary (NSArray array))
      )

      (behaves_like "an empty container")
    ))

These contexts are not executed on their own, but can be included with
behaves_like in other contexts.  You can use shared contexts to
structure suites with many recurring specifications.


Thanks to
---------

* Christian Neukirchen, and other contributors, for Bacon itself!


Contributing
------------

Once you've made your great commits:

1. [Fork][fk] NuBacon
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a pull request or [issue][is] with a link to your branch
5. That's it!


LICENSE
-------

Copyright (C) 2010 Eloy Durán <eloy.de.enige@gmail.com>, Fingertips BV <fngtps.com>

NuBacon is freely distributable under the terms of an MIT-style license.
See LICENSE or http://www.opensource.org/licenses/mit-license.php.


[rs]:  http://rspec.rubyforge.org/
[bdd]: http://behaviour-driven.org/
[fk]:  http://help.github.com/forking/
[is]:  https://github.com/alloy/NuBacon/issues