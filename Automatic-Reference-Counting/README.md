# Automatic Reference Counting

Swift 使用 Automatic Reference Counting (ARC) 来追踪和负责你的 app 的内存管理。在大多数情况下，这意味着你不用过多的去关心内存管理，当这些实例不再用到的时候，ARC 会自动释放这些内存。

然而，也有一些时候你需要面对特别情况，并且要自己负责管理内存。引用记数只适用于类的实例，structures 和 enumerations 是值类型所以不用考虑。

## How ARC Works

每当你实例化一个类的时候，ARC 会为之分配内存。这些内存包含了实例的类型信息，以及具体的值信息。

另外，当这个实例不再需要的时候，ARC 会释放对应内存，这保证了不被用到的实例不会再占用内存。

然而，如果 ARC 去释放一个仍在被使用的实例，那么该实例的数据和方法都不能再被访问，事实上如果你去尝试访问可能你的应用会崩溃。

为了保证上述的情况不发生，ARC 会追踪 properties，constans 以及 variables 是否仍在被引用，如果有一个在被引用那么就不会被释放。

为了实现这个功能，当你赋值一个类的实例给一个 property，constant 或者 variable时，它会有一个指向那个实例的**强引用**。“强”的意思是只要这个引用还在，那么实例的内存就不会被释放。

## ARC in Action

下面我们来看一个具体的例子：

```python
class Person {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) is being initialized")
    }
    deinit {
        print("\(name) is being deinitialized")
    }
}
```

该 Person 类有一个 initializer 负责设置实例的 name property，而 deinitializer 的 print 语句表示该实例被释放。

下一段代码定义了三个 Person？类型的 variables，由于是 Person？类型，所以它们自动初始化为 nil，并且暂时没有 reference 到 Person 的实例。

```swift
var reference1: Person?
var reference2: Person?
var reference3: Person?
```

现在可以创建一个 Person 实例并且赋给 variables：

```swift
reference1 = Person(name: "John Appleseed")
// Prints "John Appleseed is being initialized"
```

"John Appleseed is being initialized" 输出证明了 initialization 确实发生了。

由于新的 Person 实例赋值给了 reference1，现在有一个强引用，reference1 指向 Person 实例。由于至少有一个强引用，ARC 会保证这个实例会留在内存中并且不被释放。

如果你把这同一个实例赋给另外的 variables，那么更多指向这个实例的强引用会建立：

```swift
reference2 = reference1
reference3 = reference1
```

现在有三个强引用指向同一个 Person 实例。如果你赋值 nil 给两个 variables，Person 实例仍然不会被释放，因为还有一个强引用：

```swift
reference1 = nil
reference2 = nil
```

ARC 直到最后的强引用被打破，才会去回收 Person 的实例，如下：

```swift
reference3 = nil
// Prints "John Appleseed is being deinitialized"
```

## Strong Reference Cycles Between Class Instances

上面这个例子简单地描绘了一下 ARC 的工作原理。

然而，有时候你会遇到这样的情况：类的实例永远不会达到 0 引用的状态。比如当两个实例互相持有对方的强引用，这样的情况被称为 **a strong reference cycle**。

怎么解决呢？你可以使用 **weak** 或者 **unowned** 关键字。下面是一个具体的例子：

```swift
class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment?
    deinit { print("\(name) is being deinitialized") }
}

class Apartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}
```

每个 Person 实例有一个 name property 以及一个初始值是 nil 的 optional apartment property。因为一个 person 不一定会有 apartment。

同样的，每个 Apartment 实例有一个 unit property 以及一个初始值是 nil 的 optional tenant property。因为一个 apartment 也不一定会有 tenant。

继续看下面的代码：

```swift
var john: Person?
var unit4A: Apartment?

john = Person(name: "John Appleseed")
unit4A = Apartment(unit: "4A")
```

下图很好地表现了两个实例的关系，john variable 有一个强引用指向 Person 类实例，unit4A variable 有一个强引用指向 Apartment 类实例。

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/1.png)


现在可以把这两个实例连接在一起，如下图：

```swift
john!.apartment = unit4A
unit4A!.tenant = john
```

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/2.png)

上图就造成了 strong reference cycle。当你把它们赋值为 nil 的时候，对应的实例并不会被 ARC 回收释放：

```swift
john = nil
unit4A = nil
```

可以发现当你赋值为 nil 的时候，没有一个 deinitializer 被调用了，这也正导致了你应用中的内存泄漏。

下图是设置为 nil 后的情况：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/3.png)

## Resolving Strong Reference Cycles Between Class Instances

Swift 提供了两种方法来解决这个问题：**weak references** and **unowned references**。

当另一个实例的生命周期更短的时候使用 **weak reference**，也就是这个实例可以先被回收的时候。在上面的例子里，一个 apartment 在它的生命周期里可以没有 tenant，所以弱引用比较合适。相反，如果另一个实例的生命周期相同或者更长就用 **unowned reference**。

## Weak References

因为是弱引用，所以实例能被回收即使有弱引用仍然在引用它。所以，ARC 会自动把弱引用设置成 nil 当它指向的实例被回收之后。由于弱引用需要允许在运行时把值设置成 nil，它们总是被声明为 variables 而不是 constants。

下面的例子和之前的很相似：

```swift
class Person {
    let name: String
    init(name: String) { self.name = name }
    var apartment: Apartment?
    deinit { print("\(name) is being deinitialized") }
}

class Apartment {
    let unit: String
    init(unit: String) { self.unit = unit }
    weak var tenant: Person?
    deinit { print("Apartment \(unit) is being deinitialized") }
}
```

以下是没变的部分：

```swift
var john: Person?
var unit4A: Apartment?

john = Person(name: "John Appleseed")
unit4A = Apartment(unit: "4A")

john!.apartment = unit4A
unit4A!.tenant = john
```

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/4.png)

该 Person 类实例仍然有指向 Apartment 类实例的强引用，但现在 Apartment 类实例指向 Person 类实例的是一个**弱引用**，这意味着当你把 john variable 赋值为 nil，再没有强引用指向这个 Person 类实例：

```swift
john = nil
// Prints "John Appleseed is being deinitialized"
```

于是 Apartment 类实例的 tenant property 也被设置为 nil：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/5.png)

剩下唯一指向 Apartment 类实例的强引用就是 unit4A variable。如果你打破这个强引用，如下：

```swift
unit4A = nil
// Prints "Apartment 4A is being deinitialized"
```

于是两个实例都被回收内存：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/6.png)

## Unowned References

**unowned reference** 的使用场景：另一个实例有相同的或是更长的生命周期。**unowned reference** 应该总是有值的，所以 ARC 从来不会把它设置为 nil，也就是说 **unowned reference** 由 **nonoptional types** 来定义。

下面的例子定义了两个类，Customer 和 CreditCard，a customer 可以有 credit card，也可以没有，但是 credit card 必须有一个 customer。

CreditCard 实例永远不应该比 Customer 实例活得久。所以 Customer 类有一个 optional card property，但 CreditCard 类有 unowned (and nonoptional) customer property。

更进一步来说，新的 CreditCard 实例必须在实例化的时候传入 number value 和 customer 实例。代码如下图：

```swift
class Customer {
    let name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit { print("\(name) is being deinitialized") }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit { print("Card #\(number) is being deinitialized") }
}
```

下来我们定义一个 optional Customer variable：

```swift
var john: Customer?
```

现在你可以实例一个 Customer 类，并且用它来实例化 CreditCard类：

```swift
john = Customer(name: "John Appleseed")
john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)
```

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/7.png)

我们不会陷入 Strong Reference Cycles：

```swift
john = nil
// Prints "John Appleseed is being deinitialized"
// Prints "Card #1234567890123456 is being deinitialized"
```

## Unowned References and Implicitly Unwrapped Optional Properties

上面的例子包含了最常见的打破 strong reference cycle 的场景。现在我们来分析第三个场景，两个 properties 总该有个值，一旦初始化了以后都不该设置为 nil。这种情境下就要使用 unowned property 以及 implicitly unwrapped optional property。

这使得 properties 一旦初始化后能被直接访问（不用 optional unwrapping），并且避免 reference cycle。下面我们来看这种情况。

我们定义两个类，Country 和 City。每个 country 必须有一个 capital city，每一个 city 必须属于一个 country，如下图：

```swift
class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}

class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
}
```

声明 capitalCity property 为 implicitly unwrapped optional property，这表示这个属性默认值是 nil，但是不用 upwrap 也能直接使用。因为 capitalCity 的默认值是 nil，一个新的 Country 类的实例可以被认为是 fully initialized 的，只要它正确设置了 name property。这意味着 Country initializer 可以把 self 传给 City initializer。

正是因为上面的愿意，你可以在一行里为 Country 和 City 类实例分配内存，并且不会造成 strong reference cycle。


```swift
var country = Country(name: "Canada", capitalName: "Ottawa")
print("\(country.name)'s capital city is called \(country.capitalCity.name)")
// Prints "Canada's capital city is called Ottawa"
```

## Strong Reference Cycles for Closures

A strong reference cycle 也会出现在以下情况，赋值 closure 给类实例的 property，并且 closure 的 body 捕获（capture）这个实例。closure 的 body 可以访问类实例的 property，比如说 self.someProperty，或者调用实例的方法，比如 self.someMethod()。这两种情况都会造成 closure 来捕获自己（capture self），并造成 strong reference cycle。

因为 closures 和类一样都是引用类型，所以也会造成 strong reference cycle。当你把 closure 赋值给 property 的时候，你也使一个引用指向了那个 closure。本质上来说和之前的 strong references 原理一样，现在是类实例和 closure 之间的关系。

Swift 为我们提供了优雅的解决方案，被称为 closure capture list。我们一起来看下面的例子：

```swift
class HTMLElement {

    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinitialized")
    }

}
```

这个 HTMLElement 类定义了一个 name property，表示这个元素的名字，比如“h1”表示 heading element，“p“表示 paragraph element，或者”br“是 line break element。HTMLElement 还定义了 an optional text property，也就是在元素内的具体内容。

除了这两个比较简单的属性，HTMLElement 类还定义了一个 lazy property，称作 asHTML。这个 property 引用一个 closure，这个 asHTML propert 的类型是 () -> String 函数。

这个 asHTML property 就像实例方法一样被使用，下来我们来看例子：

```swift
let heading = HTMLElement(name: "h1")
let defaultText = "some default text"
heading.asHTML = {
    return "<\(heading.name)>\(heading.text ?? defaultText)</\(heading.name)>"
}
print(heading.asHTML())
// Prints "<h1>some default text</h1>"
```

HTMLElement 类提供了一个 initializer，需要一个 name argument 或者是一个 text argument，以及一个 deinitializer。下面是实例化：

```swift
var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())
// Prints "<p>hello, world</p>"
```

不幸的是，上面的 HTMLElement 类造成了 strong reference cycle，下面是图示：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/8.png)

该实例的 asHTML property 持有指向 closure 的强引用，又因为该 closure 在 body 内使用了 self（比如 self.name 和 self.text），该 closure 捕获了 self，也就是说它持有一个指向 HTMLElement 实例的强引用，这就造成了 strong reference cycle。

如果你把 paragraph variable 设置为 nil，HTMLElement 实例以及 closure 都没有被释放：

```swift
paragraph = nil
```

## Resolving Strong Reference Cycles for Closures

你可以在 closure 的定义里使用 capture list 来解决这个问题。capture list 定义了 closure body 内捕获类型时候的规则。你可以定义捕获类型为 weak 或者 onowned 就像之前对类实例一样。

## Defining a Capture List

直接看具体例子：

```swift
lazy var someClosure: (Int, String) -> String = {
    [unowned self, weak delegate = self.delegate!] (index: Int, stringToProcess: String) -> String in
    // closure body goes here
}
```

如果 closure 没有 parameter list 或者 return type，由于它们能被从上下文推断出来，可以像以下这样：

```swift
lazy var someClosure: () -> String = {
    [unowned self, weak delegate = self.delegate!] in
    // closure body goes here
}
```

## Weak and Unowned References

如果 closure 和实例总是会引用对方，并且总该同时被释放回收，在 closure 的 capture 中使用 unowned reference。

相反的，在 closure 的 capture 中使用 weak reference，如果 captured reference 在以后会称为 nil。Weak references 总是 optional type，并且自动设置为 nil 当引用的实例被释放回收。

在之前的 HTMLElement 例子里，unowned reference 是合适的。下面是正确解法：

```swift
class HTMLElement {

    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        [unowned self] in
        if let text = self.text {
            return "<\(self.name)>\(text)</\(self.name)>"
        } else {
            return "<\(self.name) />"
        }
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("\(name) is being deinitialized")
    }

}
```

capture list 是 [unowned self]，意思是：“捕获 self 作为一个 unowned reference 而不是一个 strong reference”

```swift
var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
print(paragraph!.asHTML())
// Prints "<p>hello, world</p>"
```

下面是关系图：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/Automatic-Reference-Counting/img/9.png)

这下问题解决了。

```swift
paragraph = nil
// Prints "p is being deinitialized"
```
