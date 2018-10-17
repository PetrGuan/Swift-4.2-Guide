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
