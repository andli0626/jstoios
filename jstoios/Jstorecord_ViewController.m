//
//  Jstorecord_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/21.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//

#import "Jstorecord_ViewController.h"
#import "JstoPhoto_ViewController.h"
#import "ShowCode_ViewController.h"

#import "Record_ViewController.h"

@interface Jstorecord_ViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,getRecPathDelegate>
{
    NSString *callbackmethod;
    NSString *htmlstr;
    
    NSString *recpath;
}
@property(nonatomic,retain) UIWebView *mWebView;
@end

@implementation Jstorecord_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    _mWebView.delegate = self;
    [self.view addSubview:_mWebView];
    
    //加载本地HTML
    NSString *html      = [[NSBundle mainBundle] pathForResource:@"js to record" ofType:@"html"];
    //UTF8编码，解决中文乱码
    htmlstr   = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:nil];
    
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


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //请求URL
    NSString *requestString = [[request URL] absoluteString];
    //定义解析规则：js-call://:参数一:参数二
    //参数一：方法名
    //参数二：方法参数
    NSString *protocol = @"js-call://";
    
    if ([requestString hasPrefix:protocol]) {
        NSString *requestContent = [requestString substringFromIndex:[protocol length]];
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        //动态执行js方法
        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:",[vals objectAtIndex:0]]);
        [self performSelector:sel withObject:[vals objectAtIndex:1]];
        return NO;
    }
    return YES;
}


-(void)record:(NSString *)param{

    callbackmethod = param;

    //打开录音界面
    
    Record_ViewController *view =[[Record_ViewController alloc]init];
    view.delegate = self;
    [self presentViewController:view
                       animated:YES
                     completion:^(void){
                         NSLog(@"开启录音界面");
    }];
}

-(void)getRecPath:(NSString *)path{
    recpath = path;
    NSLog(@"代理获取录音路径  %@",recpath);
    //回传参数
    [self doCallback:recpath];
}

//回调JS方法
- (void)doCallback:(NSString *)path
{
    //读取录音文件
    NSData *recdata = [NSData dataWithContentsOfFile:path];
    NSString *data = [recdata base64Encoding];//转为base64
    
    [_mWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');", callbackmethod, path]];
}


@end



