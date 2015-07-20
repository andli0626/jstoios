//
//  JstoPhoto_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//  jstophoto 分别调用 拍照 图库 相册

#import "JstoPhoto_ViewController.h"
#import "ShowCode_ViewController.h"

@interface JstoPhoto_ViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSString *callbackmethod;
    NSString *htmlstr;
}
@property(nonatomic,retain) UIWebView *mWebView;

@end

@implementation JstoPhoto_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    _mWebView.delegate = self;
    [self.view addSubview:_mWebView];
    
    //加载本地HTML
    NSString *html      = [[NSBundle mainBundle] pathForResource:@"js to photo" ofType:@"html"];
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

/********************************************************** 调用拍照，图库，相册 **********************************************************/
-(void)camera:(NSString *)param{
    callbackmethod = param;
    [self doAction:(UIImagePickerControllerSourceTypeCamera)];
}

-(void)photolibrary:(NSString *)param{
    callbackmethod = param;
    [self doAction:(UIImagePickerControllerSourceTypePhotoLibrary)];
}
-(void)album:(NSString *)param{
    callbackmethod = param;
    [self doAction:(UIImagePickerControllerSourceTypeSavedPhotosAlbum)];
}

- (void)doAction:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        imagePicker.sourceType = sourceType;
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"照片获取失败"
                                                     message:@"没有可用的照片来源"
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10)
                                 inView:self.view
               permittedArrowDirections:UIPopoverArrowDirectionAny
                               animated:YES];
    } else {
        [self presentModalViewController:imagePicker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"正在处理图片..." message:@"\n\n"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:nil, nil];
        
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loading.center = CGPointMake(139.5, 75.5);
        [av addSubview:loading];
        [loading startAnimating];
        [av show];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSString *base64 = [UIImagePNGRepresentation(originalImage) base64Encoding];
            [self performSelectorOnMainThread:@selector(doCallback:) withObject:base64 waitUntilDone:NO];
            [av dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    
    [picker dismissModalViewControllerAnimated:YES];
}
/**********************************************************************************************************************************/

//回调JS方法
- (void)doCallback:(NSString *)data
{
    [_mWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');", callbackmethod, data]];
}


@end


