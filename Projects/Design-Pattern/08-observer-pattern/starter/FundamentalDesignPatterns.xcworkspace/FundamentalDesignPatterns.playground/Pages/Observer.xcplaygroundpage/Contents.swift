/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Observer
 - - - - - - - - - -
 ![Observer Diagram](Observer_Diagram.png)
 
 The observer pattern allows "observer" objects to register for and receive updates whenever changes are made to "subject" objects.
 
 This pattern allows us to define "one-to-many" relationships between many observers receiving updates from the same subject.
 
 ## Code Example
 */

import Foundation

// MARK:- KVO
@objcMembers public class KVOUser: NSObject {
    dynamic var name: String
    
    public init(name: String) {
        self.name = name
    }
}

print("-- KVO Example --")
let kvoUser = KVOUser(name: "Ray")
var kvoObserver: NSKeyValueObservation? = kvoUser.observe(\.name, options: [.initial, .new]) {
    (user, change) in
    
    print("User's name is \(user.name)")
}

kvoUser.name = "Peter"

kvoObserver = nil
kvoUser.name = "Peter is gone"

