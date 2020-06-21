---
title: 按照顺序打印
date: 2020-06-21 10:41:56
tags:
---
没错，我又开了个坑。这次的问题是 [按顺序打印](https://leetcode-cn.com/problems/print-in-order/)。大意就是有 one two three 三个线程同时在跑，一定要让 two 在 one 后面、three 在 two 后面执行。
### 题目
本来觉得用 Go 的 channel 应该是最好写的。
```go
var oneDone chan //one 结束就 oneDone <-
var twoDone chan //two 结束就 twoDone <-
```
可惜并没有 Go。所以，要不 Java ? 

#### 阻塞队列
那么要做到和 channel 类似的效果，首先就是确保 BlockingQueue 能在没有元素 pop 的时候能阻塞。查一下 api 有个 take () 方法
```java
/**
 * Retrieves and removes the head of this queue, waiting if necessary
 * until an element becomes available.
 *
 * @return the head of this queue
 * @throws InterruptedException if interrupted while waiting
 */
E take () throws InterruptedException;
```

已通过代码
```java
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

class Foo {
    private BlockingQueue<Integer> one;
    private BlockingQueue<Integer> two;

    public Foo () {
        one = new LinkedBlockingQueue<>();
        two = new LinkedBlockingQueue<>();
    }

    public void first (Runnable printFirst) throws InterruptedException {

        //printFirst.run () outputs "first". Do not change or remove this line.
        printFirst.run();
        one.add(1);
    }

    public void second (Runnable printSecond) throws InterruptedException {

        //printSecond.run () outputs "second". Do not change or remove this line.
        one.take();
        printSecond.run ();
        two.add(1);
    }

    public void third (Runnable printThird) throws InterruptedException {

        //printThird.run () outputs "third". Do not change or remove this line.
        two.take();
        printThird.run();
    }
}
```
这道题的本质是要在 * 并发执行的过程中，保证部分单元的执行顺序 *。也就是某个执行单元在条件没有达到的时候，保持阻塞，让出 CPU。

#### 互斥锁

#### 信号量
> 信号量（英语：semaphore）又称为信号标，是一个同步对象，用于保持在 0 至指定最大值之间的一个计数值。当线程完成一次对该 semaphore 对象的等待（wait）时，该计数值减一；当线程完成一次对 semaphore 对象的释放（release）时，计数值加一。当计数值为 0，则线程等待该 semaphore 对象不再能成功直至该 semaphore 对象变成 signaled 状态。semaphore 对象的计数值大于 0，为 signaled 状态；计数值等于 0，为 nonsignaled 状态.
semaphore 对象适用于控制一个仅支持有限个用户的共享资源，是一种不需要使用忙碌等待（busy waiting）的方法。
信号量的概念是由荷兰计算机科学家艾兹赫尔・戴克斯特拉（Edsger W. Dijkstra）发明的，广泛的应用于不同的操作系统中。在系统中，给予每一个进程一个信号量，代表每个进程目前的状态，未得到控制权的进程会在特定地方被强迫停下来，等待可以继续进行的信号到来。如果信号量是一个任意的整数，通常被称为计数信号量（Counting semaphore），或一般信号量（general semaphore）；如果信号量只有二进制的 0 或 1，称为二进制信号量（binary semaphore）。在 linux 系统中，二进制信号量（binary semaphore）又称互斥锁（Mutex）。 -- 维基百科

Java 里面信号量有两个重要的行为，acquire 和 release。对此分别有以下描述
```java
/**
 * Acquires a permit from this semaphore, blocking until one is
 * available, or the thread is {@linkplain Thread#interrupt interrupted}.
 *
 * <p>Acquires a permit, if one is available and returns immediately,
 * reducing the number of available permits by one.
 *
 * <p>If no permit is available then the current thread becomes
 * disabled for thread scheduling purposes and lies dormant until
 * one of two things happens:
 * <ul>
 * <li>Some other thread invokes the {@link #release} method for this
 * semaphore and the current thread is next to be assigned a permit; or
 * <li>Some other thread {@linkplain Thread#interrupt interrupts}
 * the current thread.
 * </ul>
 *
 * <p>If the current thread:
 * <ul>
 * <li>has its interrupted status set on entry to this method; or
 * <li>is {@linkplain Thread#interrupt interrupted} while waiting
 * for a permit,
 * </ul>
 * then {@link InterruptedException} is thrown and the current thread's
 * interrupted status is cleared.
 *
 * @throws InterruptedException if the current thread is interrupted
 */
public void acquire() throws InterruptedException {
    sync.acquireSharedInterruptibly(1);
}
```

```java
/**
 * Releases a permit, returning it to the semaphore.
 *
 * <p>Releases a permit, increasing the number of available permits by
 * one.  If any threads are trying to acquire a permit, then one is
 * selected and given the permit that was just released.  That thread
 * is (re) enabled for thread scheduling purposes.
 *
 * <p>There is no requirement that a thread that releases a permit must
 * have acquired that permit by calling {@link #acquire}.
 * Correct usage of a semaphore is established by programming convention
 * in the application.
 */
public void release() {
    sync.releaseShared (1);
}
```

```java
import java.util.concurrent.Semaphore;

class Foo {
    private Semaphore s1;
    private Semaphore s2;

    public Foo() {
        s1 = new Semaphore(0);
        s2 = new Semaphore(0);
    }

    public void first (Runnable printFirst) throws InterruptedException {
        printFirst.run();
        s1.release();
    }

    public void second (Runnable printSecond) throws InterruptedException {
        s1.acquire();
        printSecond.run();
        s2.release();
    }

    public void third (Runnable printThird) throws InterruptedException {
        s2.acquire();
        printThird.run();
    }
}
```

### Wait 和 Notify
先说结论，用这种写法的是 Java 大佬。[传送门](https://leetcode-cn.com/problems/print-in-order/solution/gou-zao-zhi-xing-ping-zhang-shi-xian-by-pulsaryu/)

```java
class Foo {
    private boolean firstFinished;
    private boolean secondFinished;
    private Object lock = new Object();

    public Foo() {
    }

    public void first (Runnable printFirst) throws InterruptedException {
        synchronized(lock) {
            printFirst.run();
            firstFinished = true;
            lock.notifyAll();
        }
    }

    public void second(Runnable printSecond) throws InterruptedException {
        synchronized(lock) {
            while (!firstFinished) {
                lock.wait();
            }
            printSecond.run();
            secondFinished = true;
            lock.notifyAll();
        }
    }

    public void third(Runnable printThird) throws InterruptedException {

        synchronized(lock) {
            while (!secondFinished) {
                lock.wait();
            }
            printThird.run();
        }
    }
}
```
这里面牵涉到了几个 Java 并发体系的概念。对象锁和 syncronize、Object#Wait、Object#Notify。
