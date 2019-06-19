import UIKit

func doWork(block: () -> Void) {
    block()
}

doWork {
    print("WTF")
}

func doWorkAsync(block: @escaping () -> Void) {
    DispatchQueue.main.async {
        block()
    }
}

class S {
    var foo = "foo"

    func method1() {
        doWork {
            print("foo")
        }
        foo = "bar"
    }

    func method2() {
        doWorkAsync {
            print(self.foo)
        }
        foo = "bar"
    }

    func method3() {
        doWorkAsync { [weak self] in
            print(self?.foo ?? "nil")
        }
        foo = "bar"
    }
}

let aa = S()
aa.method1()
aa.method2()
aa.method3() // compare to S().method3()

protocol P {
    func work(b: @escaping () -> Void)
}

// Can compile
class C: P {
    func work(b: @escaping () -> Void) {
        DispatchQueue.main.async {
            print("in C")
            b()
        }
    }
}

// Can also compile, WTF?
class C1: P {
    func work(b: () -> Void) {

    }
}

let cc = C1()

