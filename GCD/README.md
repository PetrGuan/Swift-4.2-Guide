# GCD Concepts

要理解 GCD，你首先需要理解 concurrency 和 threading 的相关概念。

## Concurrency and Parallelism

**Concurrency** is when two or more tasks can start, run, and complete in overlapping time periods. It doesn't necessarily mean they'll ever both be running at the same instant. For example, multitasking on a single-core machine.

**Parallelism** is when tasks literally run at the same time, e.g., on a multicore processor.

Quoting Sun's Multithreaded Programming Guide:

> Concurrency: A condition that exists when at least two threads are making progress. A more generalized form of parallelism that can include time-slicing as a form of virtual parallelism.

> Parallelism: A condition that arises when at least two threads are executing simultaneously.

## Concurrency

在 iOS 的世界里，一个 process 或者 application 包含了一个或多个 threads。iOS 系统的 scheduler 会对每个 thread 独立地维护。每个 thread 都能够并行地运行（execute concurrently），但这是由系统决定的。是否并行，什么时候并行，并且具体怎么并行都由系统说了算。

单核的设备通过 **time-slicing** 来达成并行。它们运行一个 thread，执行一次上下文切换（context switch），然后再运行另一个 thread。

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/GCD/img/1.png)

多核的设备，会在同时执行多个线程。

GCD 是建立在 threads 基础上的。它维护着一个共享的 thread pool。通过 GCD 你可以添加代码块（blocks of code） 或者 work items 到 dispatch queues，然后让 GCD 来决定具体哪个线程去执行它们。

当你整理代码的时候，你可能会发现有些代码块可以同时运行，而有些不可以。如果可以，那么 GCD 就能大显身手了。

需要注意的是 GCD 决定了它需要多少 parallelism（how much parallelism it requires），这基于系统以及可用的系统资源。需要谨记于心的是 parallelism 需要 concurrency，但是 concurrency 并不能保证是 parallelism 的。

简单来说，concurrency 是关于结构（structure）而 parallelism 是关于执行（execution）。

## Queues

前面有提到，GCD 通过 DispatchQueue 类来执行在 **dispatch queues**（operates on dispatch queues）。你把 work 提交给这个 queue 然后 GCD 会用 FIFO 的顺序执行它们（First In, First Out）。

Dispatch queues 是线程安全的（**thread-safe**），这意味着你可以从多个线程同时地去访问它们。当你能理解 dispatch queues 是如何提供线程安全的时候，GCD 的好处就很明显了。关键在于选择正确的 dispatch queue 以及 dispatching function。

Queues 可以是 **serial** 的或者是 **concurrent** 的。Serial queues 保证在一个给定的时间点只有一个 task 在运行，GCD 控制着执行的时间，你不会知道在一个 task 结束和下一个 task 开始之前的这段时间有多久：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/GCD/img/2.png)

Concurrent queues 允许多个 tasks 同时执行。该 queue 会保证 tasks 以你添加的顺序来开始执行，tasks 能以任何的顺序结束运行，并且你不会知道多久后下个 task 开始，以及在任意时间点有多少个 tasks 在运行。

This is by design: 你的代码不应该依赖这些实现细节。

下面是一个例子:

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/GCD/img/3.png)

注意 Task 1, Task 2, 和 Task 3 一个接一个的很快开始执行；Task 1 在 Task 0 执行了一会之后才开始执行；Task 3 在 Task 2 之后执行，但是它比 Task 2 更早结束。

什么时候开始执行一个 task 这是完全由 GCD 决定的。如果一个 task 的执行时间和另一个 task 重叠了，那么是否应该在另一个 core 上执行（如果有可用的 core），或者是进行 context switch 这也完全是 GCD 决定的。

GCD 提供了三种主要的队列（queues）:

> * **Main queue**: 在主线程上执行并且是一个 serial queue。
> * **Global queues**: 系统共有的 concurrent queues。有四种不同优先级的队列: high, default, low, and background。
> * **Custom queues**: 用户自定义的队列，可以是 serial 或者 concurrent 的。

当把 tasks 提交给 global concurrent 队列时，你并不是直接指明优先级。相反你使用 Quality of Service (QoS)，QoS 代表任务的重要性，也就是优先级。

具体的 QoS:

> **User-interactive**: This represents tasks that must complete immediately in order to provide a nice user experience. Use it for UI updates, event handling and small workloads that require low latency. The total amount of work done in this class during the execution of your app should be small. This should run on the main thread.

> **User-initiated**: The user initiates these asynchronous tasks from the UI. Use them when the user is waiting for immediate results and for tasks required to continue user interaction. They execute in the high priority global queue.

> **Utility**: This represents long-running tasks, typically with a user-visible progress indicator. Use it for computations, I/O, networking, continuous data feeds and similar tasks. This class is designed to be energy efficient. This will get mapped into the low priority global queue.

> **Background**: This represents tasks that the user is not directly aware of. Use it for prefetching, maintenance, and other tasks that don’t require user interaction and aren’t time-sensitive. This will get mapped into the background priority global queue.

## Synchronous vs. Asynchronous

你可以使用 GCD 来分派任务，同步和异步都可以。

一个同步的函数会在整个任务结束之后才把控制返回给调用者，你可以这样使用：

    DispatchQueue.sync(execute:)

一个异步的函数会马上把控制返回给调用者，会让任务开始但不会等待它结束。因此异步的函数并不会阻塞当前线程对下一个函数的执行。你可以这样使用：

    DispatchQueue.async(execute:)


## Managing Tasks

对于本文来说，你可以直接把 task 当作是 closure。每个提交给 DispatchQueue 的 task 都是一个 DispatchWorkItem。你可以设置它的行为比如 QoS，以及是否会 spawn 一个新的线程。

## Handling Background Tasks

让我们回过头来看我们的 app。

打开 **PhotoDetailViewController.swift**，注意到 **viewDidLoad()** 方法中的这两行：

    let overlayImage = faceOverlayImageFrom(image)
    fadeInNewImage(overlayImage)

由于这两行任务比较重，并且是在 **viewDidLoad()** 里，所以很可能会影响用户体验，必须要等完成了才返回控制。现在我们修改成这样：

```swift
// 1
DispatchQueue.global(qos: .userInitiated).async { [weak self] in
  guard let self = self else {
    return
  }
  let overlayImage = self.faceOverlayImageFrom(self.image)

  // 2
  DispatchQueue.main.async { [weak self] in
    // 3
    self?.fadeInNewImage(overlayImage)
  }
}
```

以下是具体说明：

1. 你把这段代码移到了一个 background global queue 里，并且异步地执行。这可以让 **viewDidLoad()** 很快就结束并返回，并且让 loading 更流畅。同时 the face detection processing 已经开始了，但可能还没有结束。
2. 在这个时刻，the face detection processing 已经结束了并且你得到了一个新的 image，而你需要用这个 image 来更新你的 UIImageView。你在 main queue 里添加了另一个 closure。注意，所有和 UI 有关的代码都必须在主线程！
3. 最后，你调用 **fadeInNewImage(_:)** 来更新 UI。

总结来说，当你需要执行网络有关，以及对 CPU 负载比较大的 task 的时候你可以使用异步，这可以不阻塞当前的线程。

以下是一个快速的异步队列使用指南：

> **Main Queue**: This is a common choice to update the UI after completing work in a task on a concurrent queue. To do this, you code one closure inside another. Targeting the main queue and calling async guarantees that this new task will execute sometime after the current method finishes.

> **Global Queue**: This is a common choice to perform non-UI work in the background.

> **Custom Serial Queue**: A good choice when you want to perform background work serially and track it. This eliminates resource contention and race conditions since you know only one task at a time is executing. Note that if you need the data from a method, you must declare another closure to retrieve it or consider using sync.

## Delaying Task Execution

DispatchQueue 能够让 task 延时执行。不要把这个延时功能用在解决 race conditions 或者其他时间有关的 bug。当你想在某个时间运行 task 的时候使用这个延时功能（嗯，别想歪了）。

比如你有一个 app，很有可能用户第一次使用打开 app 不知道应该做什么。如果没有照片的话，给用户一些提示会是一个很好的设计，你也应该考虑用户视线的转移。一个两秒的延时应该比较合适。

打开 **PhotoCollectionViewController.swift** 并且实现 **showOrHideNavPrompt()** 方法:

```swift
// 1
let delayInSeconds = 2.0

// 2
DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { [weak self] in
  guard let self = self else {
    return
  }

  if PhotoManager.shared.photos.count > 0 {
    self.navigationItem.prompt = nil
  } else {
    self.navigationItem.prompt = "Add photos with faces to Googlyify them!"
  }

  // 3
  self.navigationController?.viewIfLoaded?.setNeedsLayout()
}
```

以下是每一步的意图：

1. 阐明延时多久。
2. 等到时间到了异步执行之后的代码块，更新图片数以及 prompt。
3. 强行让 navigation bar layout，当设置完 prompt 之后。

**showOrHideNavPrompt()** 在 **viewDidLoad()** 中被执行，以及当 **UICollectionView** reloads 的时候。

编译并且运行，如下：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/GCD/img/4.png)

为什么不使用 Timer？当你有重复的 task 的时候你可以考虑使用它，以下是两个使用 dispatch queue’s asyncAfter() 的原因：

一个是可读性，使用 DispatchQueue 的 asyncAfter()，你直接加一个 closure 就可以了。Timer 的话就更为复杂以及没有那么容易理解。

另一个原因是 Timer 基于 run loops，你必须保证在正确的 run loops 上运行，使用  DispatchQueue 会比较简单。

## Managing Singletons

一个常见的关于 singleton 的问题就是：它们可能不是线程安全的。因为 singleton 可能经常被多个 controller 同时访问，我们的 **PhotoManager** 类就是一个 singleton，下来我们具体来看这个问题。

线程安全的代码可以被多线程或者并发的 task 访问，并且不引起类似 data corruption 或者 app crash 各种各样的问题。有两种线程安全的问题需要考虑：当 singleton 的实例初始化的时候，以及当读或者写这个实例的时候。

初始化比较容易处理，Swift 会初始化静态变量当它们第一次被访问的时候，并且会保证这样的操作是原子的。Swift 会保证初始化的代码是线程安全的。

打开 **PhotoManager.swift** 看看我们是如何初始化 singleton 的:

    class PhotoManager {
    private init() {}
    static let shared = PhotoManager()
    }

private 关键字保证了只有一个 PhotoManager 的实例。你需要处理该类的属性被多线程访问的数据同步问题。

## Handling the Readers-Writers Problem

在 Swift 里，任何被 let 修饰的变量都是常量，因此它们是只读的并且是线程安全的（只能读不会改当然安全了）。如果是 var 修饰的变量的话，那就不是默认线程安全的了，比如声明为 mutable 的 Array 或者 Dictionary。

尽管多个线程可以同时读取一个 mutable 的 Array 实例，但如果同时有一个线程在修改这个实例，那么结果就是无法预测的了。当前我们的 singleton 并不能防止这种情况的发生。

具体看 **PhotoManager.swift** 中的 **addPhoto(_:)** 方法：

```swift
func addPhoto(_ photo: Photo) {
  unsafePhotos.append(photo)
  DispatchQueue.main.async { [weak self] in
    self?.postContentAddedNotification()
  }
}
```

这是读写操作中的写操作，继续往下看：

```swift
private var unsafePhotos: [Photo] = []

var photos: [Photo] {
  return unsafePhotos
}
```

这里的 getter 属性就是读写操作中的读操作。调用者会得到一份 copy，但这并不保证别的线程同时在修改它。

这就是软件开发中的非常经典的 Readers-Writers Problem。GCD 提供了一种非常优雅的解决方案，使用 dispatch barrier 来创造 read/write 锁。Dispatch barriers 是一类函数，并且能够让并行队列展现出 serial-style 的行为。

当你提交一个 DispatchWorkItem 到 dispatch queue 的时候，你可以设置 flags 来表示它是这个队列中在某个时段独占线程执行的 item。也就是说其他所有在这个 barrier 之前提交给队列的 items 都应该已经完成了，当这个 barrier workitem 开始执行的时候。

当轮到这个 DispatchWorkItem 的执行时，barrier 会执行并且保证队列里只有这一个 workitem 在执行，只有当这个 item 结束后才会返回原来的模式。

下面的图更为直观和便于理解：

![image](https://github.com/byelaney/Swift-4.2-Guide/blob/master/GCD/img/5.png)

当 barrier 在执行的时候，这时能把 queue 当作是 serial queue，只有一个 barrier 在执行，一旦执行完之后 queue 就又变回原来的 concurrent queue 了。

谨慎使用 barrier 如果是在 global background concurrent queues，因为这些 queues 是 shared resources。在 serial queue 里没必要使用 barrier，因为本身就是顺序执行的。在 custom concurrent queue 里使用 barrier 是一个不错的选择。

我们选择在 custom concurrent queue 处理 barrier function，并且把读写函数分离。该 concurrent queue 会允许多线程同时读取。

打开 **PhotoManager.swift**，作如下修改：

```swift
private let concurrentPhotoQueue =
  DispatchQueue(
    label: "com.raywenderlich.GooglyPuff.photoQueue",
    attributes: .concurrent)
```

修改 **addPhoto(_:)** 方法：

```swift
func addPhoto(_ photo: Photo) {
  concurrentPhotoQueue.async(flags: .barrier) { [weak self] in
    // 1
    guard let self = self else {
      return
    }

    // 2
    self.unsafePhotos.append(photo)

    // 3
    DispatchQueue.main.async { [weak self] in
      self?.postContentAddedNotification()
    }
  }
}
```

以下是具体说明:

1. 你使用了一个 barrier 来异步分发“写”操作，当它在执行的时候，队列里会保证只有它在执行。
2. 将对象添加到数组中。
3. 最后你发出一个通知，告知照片已经被添加了。该操作必须在主线程里因为它要做 UI 相关的操作，所以你使用 **DispatchQueue.main.async**。

好了写操作结束了，下来轮到读操作了。

为了保证写操作的线程安全，你需要在 concurrentPhotoQueue queue 里进行读操作，只有在添加完成后你才应该读取返回数据，所以我们使用 **sync**。

当你需要追踪 dispatch barriers 的完成情况时，或者当你需要等待某个操作完成后才继续，这时我们就可以用 **sync**。

你需要非常的小心，因为这可能涉及到另一个问题，**deadlock situation**。

两个或多个线程，如果它们都在彼此等待对方完成某些任务，那么这就会造成死锁。第一个线程在等第二个线程结束，而第二个线程也在等第一个线程结束。

以下是使用 **sync** 的场景:

>* Main Queue: Be **VERY** careful for the same reasons as above; this situation also has potential for a deadlock condition. This is especially bad on the main queue because the whole app will become unresponsive.
>* Global Queue: This is a good candidate to sync work through dispatch barriers or when waiting for a task to complete so you can perform further processing.
>* Custom Serial Queue: Be VERY careful in this situation; if you’re running in a queue and call sync targeting the same queue, you’ll definitely create a deadlock.

修改 **PhotoManager.swift**：

```swift
var photos: [Photo] {
  var photosCopy: [Photo]!

  // 1
  concurrentPhotoQueue.sync {

    // 2
    photosCopy = self.unsafePhotos
  }
  return photosCopy
}
```

具体说明：

1. 在 concurrentPhotoQueue 里同步地执行读操作。
2. 保存下 photo array 的副本并且返回。

That‘s it！现在你的 **PhotoManager singleton** 已经是线程安全的了！
