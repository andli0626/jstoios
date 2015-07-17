//
//  Jstofile_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//  通过加载input控件，js实现文件上传功能

#import "Jstofile_ViewController.h"
#import "ShowCode_ViewController.h"

@interface Jstofile_ViewController ()<UIWebViewDelegate>
{
    NSString *htmlstr;
}
@property(nonatomic,retain) UIWebView *mWebView;
@end
@implementation Jstofile_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"js to file";
    
    _mWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    _mWebView.delegate = self;
    [self.view addSubview:_mWebView];
    
    NSString *html      = [[NSBundle mainBundle] pathForResource:@"js to file" ofType:@"html"];
    htmlstr             = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    
    [_mWebView loadHTMLString:htmlstr baseURL:nil];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"查看源码"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showCode)];
    self.navigationItem.rightBarButtonItem = item;
}

//显示源码
-(void)showCode{
    ShowCode_ViewController *view = [[ShowCode_ViewController alloc]init];
    view.isurl    = @"0";
    view.content  = htmlstr;
    [self.navigationController pushViewController:view
                                         animated:YES];
}

@end
