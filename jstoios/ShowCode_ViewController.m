//
//  ShowCode_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//

#import "ShowCode_ViewController.h"

@interface ShowCode_ViewController ()

@end


@implementation ShowCode_ViewController
@synthesize isurl;
@synthesize content;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"页面源码";
    
    if ([isurl isEqualToString:@"1"]) {
        NSURL *url = [NSURL URLWithString:content];
        content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    }
    
    UITextView *textview = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    textview.text = content;
    textview.font = [UIFont systemFontOfSize:14];
    textview.textColor = [UIColor blackColor];
    textview.editable = false;
    [self.view addSubview:textview];
}



@end
