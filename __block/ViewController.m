//
//  ViewController.m
//  __block
//
//  Created by sifudemac1 on 15/9/17.
//  Copyright (c) 2015年 sifudemac1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
// 递归锁
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
// 死锁
//    NSLock *lock = [[NSLock alloc] init];
//    在这种情况下，我们就可以使用NSRecursiveLock。它可以允许同一线程多次加锁，而不会造成死锁。递归锁会跟踪它被lock的次数。每次成功的lock都必须平衡调用unlock操作。只有所有达到这种平衡，锁最后才能被释放，以供其它线程使用。
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
            static void (^RecursiveMethod)(int);
         
            RecursiveMethod = ^(int value) {
             
                    [lock lock];
                    if (value > 0) {
                 
                            NSLog(@"value = %d", value);
                            sleep(2);
                            RecursiveMethod(value - 1);
                        }
                    [lock unlock];
                };
         
            RecursiveMethod(5);
    });
    // 只有递归锁达到平衡状态时才允许其他线程使用这个锁
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        sleep(10);
        // 尝试去请求一个递归锁
        BOOL flag = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        if (flag) {
            NSLog(@"lock before date");
            
            [lock unlock];
        } else {
            NSLog(@"fail to lock before date");
        }
    });
    
    __block NSString *name;
    //以下被注释的GCD会造成线程死锁
//    dispatch_sync(dispatch_get_main_queue(), ^{
//       name =@"李龙";
//    });
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        name =@"东海";
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        name =@"龙王";
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        name =@"三太子";
    });
    NSLog(@"猜猜输出的是%@",name);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
