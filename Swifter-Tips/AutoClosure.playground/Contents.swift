import UIKit

func logIfTrue(_ predicate: () -> Bool) {
    if predicate() {
        print("True")
    }
}

logIfTrue({ return 2 > 1 })

logIfTrue({ 2 > 1 })

logIfTrue { 2 > 1 }

func logIfTrue(_ predicate: @autoclosure () -> Bool) {
    if predicate() {
        print("True2")
    }
}

logIfTrue(2 > 1)

var level: Int?
var startLevel = 1

var currentLevel = level ?? startLevel

// Implementation of ?? Nil-Coalescing Operator
// Here the @autoclosure is crucial, it delays the defaultValue's calculation, which means improving the perf
func nilCoalescing<T>(optional: T?, defaultValue: @autoclosure () -> T) -> T {
    switch optional {
    case .some(let value):
        return value
    case .none:
        return defaultValue()
    }
}

level = 2
var currentLevel2 = nilCoalescing(optional: level, defaultValue: startLevel)

// &&
func logicalAND(l: Bool, r: @autoclosure () -> Bool) -> Bool {
    if l {
        return r()
    }
    else {
        return false
    }
}

func logicalOR(l: Bool, r: @autoclosure () -> Bool) -> Bool {
    if l {
        return true
    }
    else {
        return r()
    }
}

let r = logicalAND(l: true, r: false)
