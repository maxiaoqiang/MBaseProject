//
//  HomeViewController.m
//  MBaseProject
//
//  Created by Wisdom on 2017/12/21.
//  Copyright © 2017年 Wisdom. All rights reserved.
//

#import "HomeViewController.h"
#import "MConst.h"
#import "HomeLabel.h"
#import "MHeader.h"
#import "TestViewController.h"


@interface HomeViewController ()



@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"1--%@",[NSThread currentThread]);

//    [NSThread detachNewThreadSelector:@selector(calculate) toTarget:self withObject:nil];
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(add) object:nil];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [self calculate];
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [operation2 addDependency:operation1];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue setMaxConcurrentOperationCount:3];
    
    
    NSLog(@"2--%@",[NSThread currentThread]);


}

-(void)calculate{
    NSLog(@"3--%@",[NSThread currentThread]);

}


-(void)add{
    NSLog(@"加减乘除");
}


@end
