//
//  TestViewController.m
//  MBaseProject
//
//  Created by Wisdom on 2017/12/21.
//  Copyright © 2017年 Wisdom. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self test7];

}

-(void)test1{
    /*
     1、什么是GCD？
     全称是Grand CentraDispatch,可译为“伟大的中枢调度器”，纯C语言，提供了非常多强大的函数
     2、GCD的优势
     GCD是苹果公司为多核的并行运算提出的解决方案
     GCD会自动利用更多的CUP内核(比如双核、四核)
     GCD会自动管理线程的生命周期(创建线程、调度任务、销毁线程)，相比NSThread需要手动管理线程生命周期
     只需要告诉GCD想要执行什么任务，不需要编写任何线程管理代码
     3、GCD中有2个核心概念：任务、队列
        任务：执行什么操作
        队列：用来存放任务
        队列的类型：并发队列与串行队列
        将任务添加到队列中，GCD会自动将队列中的任务取出，放到对应的线程中执行，任务的取出遵循队列的 FIFO原则：先进先出，后进后出
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"线程1：%@",[NSThread currentThread]);
        dispatch_sync(queue, ^{
            NSLog(@"线程2：%@",[NSThread currentThread]);
        });
    });
    /*
     dispatch_sync:只能在当前线程中执行任务，不具备开启新线程的能力
     注意：使用sync函数往当前串行队列中添加任务，会卡在当前的串行队列
     */
    /*
     线程1：<NSThread: 0x7b80be10>{number = 3, name = (null)}
     线程2：<NSThread: 0x7b80be10>{number = 3, name = (null)}
     */
}

-(void)test2{
    /*
     如果是在主线程中调用同步函数+主队列，那么会导致死锁
     导致死锁的原因：
     sync函数是在主线程中执行的，并且会等待block执行完毕，先调用
     block是添加到主队列的，也需要在主线程中执行，后调用
     */
    //主队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    /*
     如果是调用同步函数，那么会等同步函数中的任务执行完毕，才会执行后面的代码
     注意：如果dispatch_sync方法是在主线程中调用的，并且传入的队列是主队列，那么会导致死锁
     */
    dispatch_sync(queue, ^{
        NSLog(@"线程3：%@",[NSThread currentThread]);
        //此处崩溃
    });
    
}

-(void)test3{
    /*
     异步+主队列：不会创建新的线程，并且任务是在主线程中执行
     主队列：只要将任务添加到主队列中，那么任务一定会在主线程中执行
     无论是调用(同步函数---会崩溃)还是异步函数
     */
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"线程4：%@",[NSThread currentThread]);
    });
    // 线程4：<NSThread: 0x78f3e580>{number = 1, name = main}
    
}

-(void)test4{
    /*
     同步 + 并发 ：不会开启新的线程
     */
    
    //1、创建一个并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //2、将任务添加到队列中
    dispatch_sync(queue, ^{
        NSLog(@"线程5：%@",[NSThread currentThread]);
    });
    // 线程5：<NSThread: 0x7b11e0e0>{number = 1, name = main}
    
}

-(void)test5{
    /*
     异步+串行 ：会开启新的线程，但是只会开启一个新的线程
     注意：如果调用 异步函数，那么不用等到函数中的任务执行完毕，就会执行后面的代码
     */
    
    //1、创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_SERIAL);
    /*
     能够创建新线程的原因：我们是使用“异步”函数调用，只创建1个子线程的原因，我们的队列是串行队列
     */
    
    //2、将任务添加到队列中
    dispatch_async(queue, ^{
        NSLog(@"任务1：%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2：%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3：%@",[NSThread currentThread]);
    });
    NSLog(@"任务4：%@",[NSThread currentThread]);
    
    /*
     任务4：<NSThread: 0x7c05b170>{number = 1, name = main}
     任务1：<NSThread: 0x7b663450>{number = 3, name = (null)}
     任务2：<NSThread: 0x7b663450>{number = 3, name = (null)}
     任务3：<NSThread: 0x7b663450>{number = 3, name = (null)}
     */
}

-(void)test6{
    /*
     执行任务
     dispatch_async
     dispatch_sync
     */
    
    /*
     第一个参数:队列名称
     第二个参数：告诉系统需要创建一个并发队列还是串行队列
     DISPATCH_QUEUE_SERIAL :串行
     DISPATCH_QUEUE_CONCURRENT:并发
     */
    
//    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_SERIAL);
    
    
}

-(void)test7{
//    [self XQ_syncConcurrent];
    [self XQ_asyncConcurrent];
}

#pragma mark--1、并发队列 + 同步执行 不会开启新的线程，执行完一个任务，再执行下一个任务
-(void)XQ_syncConcurrent{
    
    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--1---------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--2---------%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--3---------%@",[NSThread currentThread]);
        }
    });
    /*
        从并发队列+同步执行中可以看到，所有任务都是在主线程中执行的，由于只有一个线程，所以任务只能一个一个执行
     */
    
    /*
     2018-01-12 15:22:18.850 MBaseProject[1812:138071] 线程--1---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.850 MBaseProject[1812:138071] 线程--1---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.850 MBaseProject[1812:138071] 线程--1---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.851 MBaseProject[1812:138071] 线程--2---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.851 MBaseProject[1812:138071] 线程--2---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.851 MBaseProject[1812:138071] 线程--2---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.852 MBaseProject[1812:138071] 线程--3---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.852 MBaseProject[1812:138071] 线程--3---------<NSThread: 0x7da16200>{number = 1, name = main}
     2018-01-12 15:22:18.852 MBaseProject[1812:138071] 线程--3---------<NSThread: 0x7da16200>{number = 1, name = main}
     */
}

#pragma mark--2、并发队列 + 异步执行 可以同时开启多个线程，任务交替执行
-(void)XQ_asyncConcurrent{
    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--1-----%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--2-----%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--3-----%@",[NSThread currentThread]);
        }
    });
    
    /*
     在并发队列+异步执行中看出，除了主线程，又开启了三个线程，并且任务是交替着同时执行的
     */
    
    /*
     2018-01-12 15:39:39.181 MBaseProject[1902:145743] 线程--2-----<NSThread: 0x7a124800>{number = 4, name = (null)}
     2018-01-12 15:39:39.181 MBaseProject[1902:145758] 线程--1-----<NSThread: 0x7a1326d0>{number = 3, name = (null)}
     2018-01-12 15:39:39.181 MBaseProject[1902:145741] 线程--3-----<NSThread: 0x7a133ac0>{number = 5, name = (null)}
     2018-01-12 15:39:39.181 MBaseProject[1902:145743] 线程--2-----<NSThread: 0x7a124800>{number = 4, name = (null)}
     2018-01-12 15:39:39.182 MBaseProject[1902:145758] 线程--1-----<NSThread: 0x7a1326d0>{number = 3, name = (null)}
     2018-01-12 15:39:39.182 MBaseProject[1902:145741] 线程--3-----<NSThread: 0x7a133ac0>{number = 5, name = (null)}
     2018-01-12 15:39:39.182 MBaseProject[1902:145743] 线程--2-----<NSThread: 0x7a124800>{number = 4, name = (null)}
     2018-01-12 15:39:39.182 MBaseProject[1902:145758] 线程--1-----<NSThread: 0x7a1326d0>{number = 3, name = (null)}
     2018-01-12 15:39:39.182 MBaseProject[1902:145741] 线程--3-----<NSThread: 0x7a133ac0>{number = 5, name = (null)}

     */
    
}



@end
