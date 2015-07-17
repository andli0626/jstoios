//
//  Jstofile_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//  通过加载input控件，js实现文件上传功能

#import "Jstofile_ViewController.h"

@interface Jstofile_ViewController ()<UIWebViewDelegate>
{
    UIWebView *mWebView;
}
@end
@implementation Jstofile_ViewController
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"js to file";
    
    mWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    mWebView.delegate = self;
    [self.view addSubview:mWebView];
    
    //加载本地html
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"js to file.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [mWebView loadRequest:request];
    
}

@end