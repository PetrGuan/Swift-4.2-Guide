// Currying

// MARK:- Example 1
func addTo(_ adder: Int) -> ((Int) -> Int) {
    return { $0 + adder }
}

let addOne = addTo(1)
let result = addOne(1)
print(result)

func greaterThan(_ comparer: Int) -> ((Int) -> Bool) {
    return { $0 > comparer }
}


// MARK: - Example 2
protocol TargetAction {
    func performAction()
}

struct TargetActionWrapper<T: AnyObject>: TargetAction {
    weak var target: T?
    let action: (T) -> (() -> Void)

    func performAction() {
        if let t = target {
            action(t)()
        }
    }
}

enum ControlEvent {
    case TouchUpInside
    case ValueChanged
}

class Control {
    var actions = [ControlEvent: TargetAction]()

    func setTarget<T: AnyObject>(target: T, action: @escaping (T) -> (() -> Void), controlEvent: ControlEvent) {
        actions[controlEvent] = TargetActionWrapper(target: target, action: action)
    }

    func removeTargetForControlEvent(controlEvent: ControlEvent) {
        actions.removeValue(forKey: controlEvent)
    }

    func performActionForControlEvent(controlEvent: ControlEvent) {
        actions[controlEvent]?.performAction()
    }
}

