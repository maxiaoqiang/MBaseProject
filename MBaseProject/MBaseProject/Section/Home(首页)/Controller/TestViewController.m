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
    
    [self XQ_dispatch_group_async];
    
   
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

#pragma mark--3、串行队列 + 同步执行 ，不会开启新的线程，在当前线程执行任务，任务是串行的，执行完一个任务，再执行下一个任务
-(void)XQ_syncSerial{
    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--1--%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--2--%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--3--%@",[NSThread currentThread]);
        }
    });
    /*
     在串行队列 + 同步执行可以看到，所有任务都是在主线程执行的，并没有开启新的线程，
     而且由于串行队列，所以按顺序一个一个执行
     */
    
    /*
     2018-01-15 09:11:43.625 MBaseProject[929:28261] 线程--1--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.625 MBaseProject[929:28261] 线程--1--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.625 MBaseProject[929:28261] 线程--1--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.625 MBaseProject[929:28261] 线程--2--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.625 MBaseProject[929:28261] 线程--2--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.626 MBaseProject[929:28261] 线程--2--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.626 MBaseProject[929:28261] 线程--3--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.626 MBaseProject[929:28261] 线程--3--<NSThread: 0x7a730bb0>{number = 1, name = main}
     2018-01-15 09:11:43.626 MBaseProject[929:28261] 线程--3--<NSThread: 0x7a730bb0>{number = 1, name = main}

     */
    
}

#pragma mark--4、串行队列 + 异步执行，会开启新的线程，但是因为任务是串行的，执行下一个任务
-(void)XQ_asyncSerial{
    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"线程--1--%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"线程--2--%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"线程--3--%@",[NSThread currentThread]);
        }
    });
    /*
    在串行队列 + 异步执行可以看到，开启了一条新线程，但是任务还是串行，多以任务是一个一个执行
     */
    /*
     2018-01-15 09:35:36.922 MBaseProject[1036:39639] 线程--1--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.923 MBaseProject[1036:39639] 线程--1--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.923 MBaseProject[1036:39639] 线程--1--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.923 MBaseProject[1036:39639] 线程--2--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.923 MBaseProject[1036:39639] 线程--2--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.924 MBaseProject[1036:39639] 线程--2--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.924 MBaseProject[1036:39639] 线程--3--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.924 MBaseProject[1036:39639] 线程--3--<NSThread: 0x79776990>{number = 3, name = (null)}
     2018-01-15 09:35:36.924 MBaseProject[1036:39639] 线程--3--<NSThread: 0x79776990>{number = 3, name = (null)}

     */
}

#pragma mark--5、主队列 + 同步执行， 互等卡主不可行（在主线程中调用）
-(void)XQ_syncMain{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--1--%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--2--%@",[NSThread currentThread]);
        }
    });
    dispatch_sync(queue, ^{
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--3--%@",[NSThread currentThread]);
        }
    });
    /*
     崩溃了！！！
     在主线程中使用主队列 + 同步执行，任务不再执行
     这是因为我们在主线程中执行这段代码，我们把任务放到了主队了中，也就是放到了主线程的队列中。而对于同步执行有个特点，就是对于任务是立马执行的，那么当我们把第一个任务放进主队列中，它就会立马执行，但是主线程正在处理XQ_syncMain方法，所以任务需要等XQ_syncMain执行完才能执行，而XQ_syncMain执行到第一个任务的时候，又要等第一个任务执行完才能执行第二个和第三个
     */
    
    
    /*
     要是如果不在主线程中调用，而在其他线程中调用会如何？？？
     不会开启新线程，执行完一个任务，再执行下一个任务(在其他线程中调用)
     
     dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_CONCURRENT);
     dispatch_async(queue, ^{
     [self XQ_syncMain];
     });
     
     在其他线程中使用主队列 + 同步执行可以看到：所有任务都是在主线程中执行的，并没有开启新的线程，而且由于主队列是串行队列，所以按顺序一个一个执行，
     另一方面可以看出，任务并不是马上执行，而是将所有任务添加到队列之后才开始同步执行
     
     
     2018-01-15 10:09:22.503 MBaseProject[1162:54515] 线程--1--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.504 MBaseProject[1162:54515] 线程--1--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.504 MBaseProject[1162:54515] 线程--1--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.505 MBaseProject[1162:54515] 线程--2--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.506 MBaseProject[1162:54515] 线程--2--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.506 MBaseProject[1162:54515] 线程--2--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.506 MBaseProject[1162:54515] 线程--3--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.506 MBaseProject[1162:54515] 线程--3--<NSThread: 0x7a649030>{number = 1, name = main}
     2018-01-15 10:09:22.507 MBaseProject[1162:54515] 线程--3--<NSThread: 0x7a649030>{number = 1, name = main}

     
     */
    
}

#pragma mark--6、主队列 + 异步执行，只在主线程中执行任务，执行完一个任务，再执行下一个任务
-(void)XQ_AsyncMain{
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"线程--1--%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"线程--2--%@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"线程--3--%@",[NSThread currentThread]);
        }
    });
    
    /*
     我们发现所有任务都在主线程中，虽然是异步执行，具备开启线程的能力，但因为是主队列，所以所有任务都在主线程中，并且一个一个执行
     任务并不是马上执行，而是将所有任务添加到队列之后才开始同步执行
     */
    
    /*
     2018-01-15 10:28:24.297 MBaseProject[1228:63288] 线程--1--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.297 MBaseProject[1228:63288] 线程--1--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.298 MBaseProject[1228:63288] 线程--1--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.298 MBaseProject[1228:63288] 线程--2--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.298 MBaseProject[1228:63288] 线程--2--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.298 MBaseProject[1228:63288] 线程--2--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.298 MBaseProject[1228:63288] 线程--3--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.299 MBaseProject[1228:63288] 线程--3--<NSThread: 0x7c216060>{number = 1, name = main}
     2018-01-15 10:28:24.299 MBaseProject[1228:63288] 线程--3--<NSThread: 0x7c216060>{number = 1, name = main}

     */
}

#pragma mark--7、GCD线程之间的通讯，在iOS开发过程中，我们一般在主线程里面进行UI刷新，例如：点击、滚动、拖拽等事件，我们通常把一些耗时的操作放在其他线程，比如图片下载，文件上传等耗时操作，而当我们有时候在其他线程完成了耗时操作时，需要回到主线程，那么就用到了线程之间的通讯
-(void)XQ_asyncMain2{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /*在此执行耗时操作*/
        for (int i = 0; i < 3; i ++) {
            NSLog(@"线程--1--%@",[NSThread currentThread]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"线程--2--%@",[NSThread currentThread]);
        });
    });
    
    /*
     可以看出在其他线程中先执行操作，执行完了之后回到主线程执行相应的操作
     */
    /*
     2018-01-15 11:02:37.954 MBaseProject[1298:75576] 线程--1--<NSThread: 0x7d17f4a0>{number = 3, name = (null)}
     2018-01-15 11:02:37.954 MBaseProject[1298:75576] 线程--1--<NSThread: 0x7d17f4a0>{number = 3, name = (null)}
     2018-01-15 11:02:37.954 MBaseProject[1298:75576] 线程--1--<NSThread: 0x7d17f4a0>{number = 3, name = (null)}
     2018-01-15 11:02:37.958 MBaseProject[1298:75521] 线程--2--<NSThread: 0x7d179130>{number = 1, name = main}
     */
    
}

#pragma mark--8、GCD的栅栏方法dispatch_barrier_async我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于栅一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组可以包含一个或者多个任务。这就需要用到dispatch_barrier_async方法在两个操作间形成栅栏
-(void)XQ_barrier{
    dispatch_queue_t queue = dispatch_queue_create("com.ws", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"线程--1--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"线程--2--%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"--这里是栅栏，执行完前面的所有任务，才能继续栅栏后面的任务--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
       });
    dispatch_async(queue, ^{
        NSLog(@"线程--2--%@",[NSThread currentThread]);
    });
    /*
     可以看出在执行完栅栏前面的操作之后，才执行栅栏后面的操作
     */
    
    /*
     2018-01-15 11:43:00.860 MBaseProject[1470:93496] 线程--1--<NSThread: 0x79751ec0>{number = 3, name = (null)}
     2018-01-15 11:43:00.860 MBaseProject[1470:93498] 线程--2--<NSThread: 0x7aa51720>{number = 4, name = (null)}
     2018-01-15 11:43:00.860 MBaseProject[1470:93498] --这里是栅栏，执行完前面的所有任务，才能继续栅栏后面的任务--<NSThread: 0x7aa51720>{number = 4, name = (null)}
     2018-01-15 11:43:00.861 MBaseProject[1470:93498] 线程--3--<NSThread: 0x7aa51720>{number = 4, name = (null)}
     2018-01-15 11:43:00.861 MBaseProject[1470:93496] 线程--2--<NSThread: 0x79751ec0>{number = 3, name = (null)}

     */
}

#pragma mark--9、GCD的延时执行方法dispatch_after,当我们需要延迟执行一段代码时，就需要用到GCD的dispatch_after方法
-(void)XQ_dispatch_after{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //2s后执行这里的代码
        NSLog(@"%@",[NSThread currentThread]);
    });
    /*
     <NSThread: 0x60000007f100>{number = 1, name = main}
     */
}


#pragma mark--10、GCD的一次性代码(只执行一次)，dispatch_once我们在创建单例或者有整个程序运行过程中只执行一次的代码时，我们就用到了GCD的dispatch_once方法，使用dispatch_once函数能保证某段代码在程序中只被执行一次
-(void)XQ_dispatch_once{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"---只执行一次代码---");
    });
}


#pragma mark--11、GCD的快速迭代方法 dispatch_apply通常我们会用for循环遍历，但是GCD给我们提供了快速迭代的方法dispatch_apply，使我们可以同时遍历
-(void)XQ_dispatch_apply{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_apply(5, queue, ^(size_t index) {
        NSLog(@"循环%zd--%@",index,[NSThread currentThread]);
    });
    
    /*
     从输出结果中前边的时间中可以看出，几乎是同时遍历的
     */
    /*
     2018-01-16 11:26:47.993237+0800 MBaseProject[3094:180114] 循环1--<NSThread: 0x604000263a40>{number = 4, name = (null)}
     2018-01-16 11:26:47.993251+0800 MBaseProject[3094:180116] 循环2--<NSThread: 0x600000270780>{number = 5, name = (null)}
     2018-01-16 11:26:47.993251+0800 MBaseProject[3094:180120] 循环0--<NSThread: 0x60000026f040>{number = 3, name = (null)}
     2018-01-16 11:26:47.993414+0800 MBaseProject[3094:180114] 循环4--<NSThread: 0x604000263a40>{number = 4, name = (null)}
     2018-01-16 11:26:47.993281+0800 MBaseProject[3094:180035] 循环3--<NSThread: 0x6040000667c0>{number = 1, name = main}

     */
    
}

#pragma mark--12、GCD的队列组dispatch_group。。。有时候我们会有这样的需求：分别异步执行两个耗时操作，然后当两个耗时操作都执行完毕后再回到主线程执行操作，这时我们可以用到GCD队列组。我们可以先把任务放到队列中，然后将队列放入队列组中，调用队列组的dispatch_group_notify回到主线程执行操作
-(void)XQ_dispatch_group_async{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
       //执行1个耗时的异步操作
        NSLog(@"--执行第一个耗时的异步操作--");
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        //执行1个耗时的异步操作
        NSLog(@"--执行第二个耗时的异步操作--");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //等到前面的异步执行完毕后，回到主线程
        NSLog(@"--等前面的异步操作都执行完毕后，回到主线程--");
    });
    NSLog(@"我是外部的代码");
    
    /*
     2018-01-16 11:50:47.838269+0800 MBaseProject[3217:204307] 我是外部的代码
     2018-01-16 11:50:47.838270+0800 MBaseProject[3217:204365] --执行第二个耗时的异步操作--
     2018-01-16 11:50:47.838270+0800 MBaseProject[3217:204367] --执行第一个耗时的异步操作--
     2018-01-16 11:50:47.872322+0800 MBaseProject[3217:204307] --等前面的异步操作都执行完毕后，回到主线程--

     */
}




@end
