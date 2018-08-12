# Closures

闭包，是有一定功能的代码块。Swift 里的闭包和 C 以及 Objective-C 里的代码块很类似，以及其他语言里的 lambdas。

闭包能够捕获（capture）以及存储 constants 和 variables 的引用，但要在它们定义的区域内，这被称为 closing over constants and variables。Swift 会为你处理捕获涉及到的内存管理。

全局函数和嵌套函数其实是闭包的特例，闭包有以下形式：

> * 全局函数是具有名字，并且不捕获任何值的闭包。
> * 嵌套函数是具有名字，并且能够捕获它的 enclosing function 里面的值的闭包。
> * 闭包表达式（closure expression）是没有名字的闭包，并且可以捕获它的 surrounding context 里的值。

Swift 的闭包表达式有着干净简洁的风格，并且有一定的优化，这些优化包括：

> * 可以根据上下文推断出变量和返回值的类型
> * Implicit returns from single-expression closures
> * Shorthand argument names（like $0, $1...)
> * Trailing closure syntax

## Closure Expressions

下面来看一点闭包表达式的例子。

### The Sorted Method

Swift 标准库提供了 sorted(by:) 方法，用来为数组排序，一旦完成了排序过程后就会返回一个新的数组。也就是说原来的数组不会被该方法修改。

一起来看下面的例子：

```swift
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
```

sorted(by:) 方法接收一个闭包，并且这个闭包有两个变量输入，并且返回一个布尔值来表示第一个变量是否应该出现在第二个变量前面或者后面。

这个例子在为 String 值的数组进行排序，所以闭包需要是一个函数，并且类型是 (String, String) -> Bool。

先看第一种实现，我们可以写一个普通的函数，并且把这个函数传递给 sorted(by:) 方法：

```swift
func backward(_ s1: String, _ s2: String) -> Bool {
    return s1 > s2
}
var reversedNames = names.sorted(by: backward)
// reversedNames is equal to ["Ewa", "Daniella", "Chris", "Barry", "Alex"]
```

如果 s1 大于 s2，那么 backward 函数就会返回 true，表明 s1 应该出现在 s2 之前。然而这样的写法看起来有点小题大做，因为函数体里只有一个类似 function (a > b)，这里我们用闭包表达式更好。

### Closure Expression Syntax

闭包表达式的语法如下：

```swift
{ (parameters) -> return type in
    statements
}
```

看看具体例子：

```swift
reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in
    return s1 > s2
})
```

注意到这里变量的声明和之前的函数变量声明是一样的，都写作 (s1: String, s2: String) -> Bool。只不过闭包表达式是写在 {} 里面的。

闭包的主体在 **in** 之后，**in** 意味着闭包的变量和返回值声明已经结束，下来该轮到主体了。

另外由于闭包的主体非常短，你甚至可以简写在一行里：

```swift
reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in return s1 > s2 } )
```

### Inferring Type From Context

因为闭包作为一个变量传给了 sorted 方法，所以 Swift 可以推断出它变量的类型以及返回值。sorted(by:) 方法是存 string 的数组调用的，所以它的变量一定是 a function of type (String, String) -> Bool。这也就意味着你不必写明 (String, String) 和 Bool 值，也就是说变量类型和返回值都可以被省略：

```swift
reversedNames = names.sorted(by: { s1, s2 in return s1 > s2 } )
```

当你把闭包当作变量传给函数或者方法的时候，总是可以推断出变量的类型以及返回值类型，所以你不必写明这些东西。当然你还是可以显式的写出来，如果变量比较复杂的话。要不要省略完全取决于好不好理解，涉及到读者以及你以后维护这段代码。

### Implicit Returns from Single-Expression Closures

Single-expression 闭包可以省略 return 关键字，比如下面的例子：

```swift
reversedNames = names.sorted(by: { s1, s2 in s1 > s2 } )
```

### Shorthand Argument Names

Swift 自动为闭包提供变量简写（shorthand argument），你可以直接写成 $0, $1, $2。

具体来看下面的例子：

```swift
reversedNames = names.sorted(by: { $0 > $1 } )
```

这里 $0, $1 分别代表了第一个第二个 String 变量。

### Operator Methods

还有一个更短的写法，看下面的例子：

```swift
reversedNames = names.sorted(by: > )
```

## Trailing Closures

如果你要把闭包当作一个函数的最后一个变量，并且这个闭包表达式非常的长，你可以把它写作 trailing closure。当你使用 trailing closure 的时候，你不用写 argument label。

```swift
func someFunctionThatTakesAClosure(closure: () -> Void) {
    // function body goes here
}

// Here's how you call this function without using a trailing closure:

someFunctionThatTakesAClosure(closure: {
    // closure's body goes here
})

// Here's how you call this function with a trailing closure instead:

someFunctionThatTakesAClosure() {
    // trailing closure's body goes here
}
```

之前的为 string 排序的闭包可以重写成 trailing closure：

```swift
reversedNames = names.sorted() { $0 > $1 }
```

如果一个闭包表达式是另一个函数或者方法的唯一变量，并且作为 trailing closure，你可以不用写括号 ()，比如下面的例子：

```swift
reversedNames = names.sorted { $0 > $1 }
```

Trailing closures 在闭包非常非常长的时候很有用，你不能在一行里写完。
比如 Swift 的数组有一个 map(\_:) 方法，需要一个闭包来作为变量。这个闭包对每个数组里的元素都被调用一次，并且返回一个 mapped value。

在调用闭包之后，map(\_:) 方法会返回一个新的数组，这个数组包含了 mapped value，并且和原来数组所对应顺序一致。

下面是一个具体的例子：

```swift
let digitNames = [
    0: "Zero", 1: "One", 2: "Two",   3: "Three", 4: "Four",
    5: "Five", 6: "Six", 7: "Seven", 8: "Eight", 9: "Nine"
]
let numbers = [16, 58, 510]
```

下面是具体的 map ：

```swift
let strings = numbers.map { (number) -> String in
    var number = number
    var output = ""
    repeat {
        output = digitNames[number % 10]! + output
        number /= 10
    } while number > 0
    return output
}
// strings is inferred to be of type [String]
// its value is ["OneSix", "FiveEight", "FiveOneZero"]
```

具体的逻辑这里就不赘述了，对 map 有疑问的可以自行 wiki。

## Capturing Values

闭包可以从周围的上下文环境里捕获 constants and variables，在 Swift 里最简单的就是嵌套函数，嵌套函数可以捕获任何它的 outer function 的变量，以及这个 outer function 里的 constants and variables。

下面是一个例子：

```swift
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}
```

可以看到嵌套函数 incrementer() -> Int 里面顺利捕获到了 amount 以及 runningTotal。

makeIncrementer 的返回值类型是 () -> Int。也就是说返回的是一个函数，并且这个函数没有变量，返回值是 Int。

如果你把闭包赋值给一个类实例的属性，并且这个闭包捕获了这个类实例的其他属性，你会陷入 strong reference cycle，Swift 使用 capture lists 来解决这个问题。

## Closures Are Reference Types

当你把函数或者闭包赋值给 constant 或者 variable 的时候，实际上你把这个变量指向了函数或者闭包，也就是这里是引用。这也意味着如果你把一个闭包赋给两个不同的变量，这两个变量都指向这同一个闭包：

```swift
let alsoIncrementByTen = incrementByTen
alsoIncrementByTen()
// returns a value of 50
```

## Escaping Closures

一个闭包被称为 escape a function，当这个闭包被当作变量传给这个函数，并且在函数 return 之后才调用这个闭包的时候。你可以通过写 @escaping 在变量类型的前面来表明这个闭包可以 escape。

闭包 escape 的一种情况是，把该闭包赋值给函数外面定义的一个变量。比如许多进行异步处理的函数，需要一个闭包的变量作为 completion handler。这个函数会在开始进行这个异步操作之后就返回，但是这个闭包一直要到整个异步操作完成了之后才被调用，通俗地讲这个闭包要在函数返回时候逃离：

```swift
var completionHandlers: [() -> Void] = []
func someFunctionWithEscapingClosure(completionHandler: @escaping () -> Void) {
    completionHandlers.append(completionHandler)
}
```

这里把这个 completionHandler 闭包添加到函数外的 completionHandlers 变量里，如果你不写 @escaping，会有 compile-time error。

把一个闭包标记为 @escaping，意味着你在这个闭包里必须显式的引用 self。举个例子，下面的代码里，传递给 someFunctionWithEscapingClosure(\_:) 的闭包是一个 escaping closure，也就是说你要显式的引用 self。相反的，传递给 someFunctionWithNonescapingClosure(\_:) 的闭包不是一个 escaping closure，意味着你可以隐式的引用 self。

```swift
func someFunctionWithNonescapingClosure(closure: () -> Void) {
    closure()
}

class SomeClass {
    var x = 10
    func doSomething() {
        someFunctionWithEscapingClosure { self.x = 100 }
        someFunctionWithNonescapingClosure { x = 200 }
    }
}

let instance = SomeClass()
instance.doSomething()
print(instance.x)
// Prints "200"

completionHandlers.first?()
print(instance.x)
// Prints "100"

```

## Autoclosures

An autoclosure is a closure that is automatically created to wrap an expression that’s being passed as an argument to a function. It doesn’t take any arguments, and when it’s called, it returns the value of the expression that’s wrapped inside of it. This syntactic convenience lets you omit braces around a function’s parameter by writing a normal expression instead of an explicit closure.

It’s common to call functions that take autoclosures, but it’s not common to implement that kind of function. For example, the assert(condition:message:file:line:) function takes an autoclosure for its condition and message parameters; its condition parameter is evaluated only in debug builds and its message parameter is evaluated only if condition is false.

An autoclosure lets you delay evaluation, because the code inside isn’t run until you call the closure. Delaying evaluation is useful for code that has side effects or is computationally expensive, because it lets you control when that code is evaluated. The code below shows how a closure delays evaluation.

```swift
var customersInLine = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
print(customersInLine.count)
// Prints "5"

let customerProvider = { customersInLine.remove(at: 0) }
print(customersInLine.count)
// Prints "5"

print("Now serving \(customerProvider())!")
// Prints "Now serving Chris!"
print(customersInLine.count)
// Prints "4"
```

Even though the first element of the customersInLine array is removed by the code inside the closure, the array element isn’t removed until the closure is actually called. If the closure is never called, the expression inside the closure is never evaluated, which means the array element is never removed. Note that the type of customerProvider is not String but () -> String—a function with no parameters that returns a string.

You get the same behavior of delayed evaluation when you pass a closure as an argument to a function.

```swift
// customersInLine is ["Alex", "Ewa", "Barry", "Daniella"]
func serve(customer customerProvider: () -> String) {
    print("Now serving \(customerProvider())!")
}
serve(customer: { customersInLine.remove(at: 0) } )
// Prints "Now serving Alex!"
```


The serve(customer:) function in the listing above takes an explicit closure that returns a customer’s name. The version of serve(customer:) below performs the same operation but, instead of taking an explicit closure, it takes an autoclosure by marking its parameter’s type with the @autoclosure attribute. Now you can call the function as if it took a String argument instead of a closure. The argument is automatically converted to a closure, because the customerProvider parameter’s type is marked with the @autoclosure attribute.

```swift
// customersInLine is ["Ewa", "Barry", "Daniella"]
func serve(customer customerProvider: @autoclosure () -> String) {
    print("Now serving \(customerProvider())!")
}
serve(customer: customersInLine.remove(at: 0))
// Prints "Now serving Ewa!"
```

NOTE

Overusing autoclosures can make your code hard to understand. The context and function name should make it clear that evaluation is being deferred.

If you want an autoclosure that is allowed to escape, use both the @autoclosure and @escaping attributes. The @escaping attribute is described above in Escaping Closures.

```swift
// customersInLine is ["Barry", "Daniella"]
var customerProviders: [() -> String] = []
func collectCustomerProviders(_ customerProvider: @autoclosure @escaping () -> String) {
    customerProviders.append(customerProvider)
}
collectCustomerProviders(customersInLine.remove(at: 0))
collectCustomerProviders(customersInLine.remove(at: 0))

print("Collected \(customerProviders.count) closures.")
// Prints "Collected 2 closures."
for customerProvider in customerProviders {
    print("Now serving \(customerProvider())!")
}
// Prints "Now serving Barry!"
// Prints "Now serving Daniella!"
```

In the code above, instead of calling the closure passed to it as its customerProvider argument, the collectCustomerProviders(\_:) function appends the closure to the customerProviders array. The array is declared outside the scope of the function, which means the closures in the array can be executed after the function returns. As a result, the value of the customerProvider argument must be allowed to escape the function’s scope.
