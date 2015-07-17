//
//  Jstoalbum_ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//

#import "Jstophoto_url_ViewController.h"
#import "NSData+Base64.h"
#import "ShowCode_ViewController.h"

@interface Jstophoto_url_ViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSString *callback;
    NSString *urlstr;
}
@property(nonatomic,retain) UIWebView *mWebView;
@end

@implementation Jstophoto_url_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, AppWidth, AppHeight)];
    _mWebView.delegate = self;
    [self.view addSubview:_mWebView];
    
    urlstr = @"https://dn-jstoios.qbox.me/js%20to%20photo.html";
    NSURL *url = [NSURL URLWithString:@"https://dn-jstoios.qbox.me/js%20to%20photo.html"];
    NSString *strHtml = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [_mWebView loadHTMLString:strHtml baseURL:nil];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"查看源码"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(showCode)];
    self.navigationItem.rightBarButtonItem = item;
}

//显示源码
-(void)showCode{
    ShowCode_ViewController *view = [[ShowCode_ViewController alloc]init];
    view.isurl = @"1";
    view.content   = urlstr;
    [self.navigationController pushViewController:view
                                         animated:YES];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSString *protocol = @"js-call://";
    if ([requestString hasPrefix:protocol]) {
        NSString *requestContent = [requestString substringFromIndex:[protocol length]];
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        if ([[vals objectAtIndex:0] isEqualToString:@"camera"]) {
            callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypeCamera];
        } else if([[vals objectAtIndex:0] isEqualToString:@"photolibrary"]) {
            callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypePhotoLibrary];
        } else if([[vals objectAtIndex:0] isEqualToString:@"album"]) {
            callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        }
        else {
            [webView stringByEvaluatingJavaScriptFromString:@"alert('未定义/lwme.cnblogs.com');"];
        }
        return NO;
    }
    return YES;
}

- (void)doAction:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        imagePicker.sourceType = sourceType;
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"照片获取失败" message:@"没有可用的照片来源" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

- (void)doCallback:(NSString *)data
{
    [_mWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');", callback, data]];
}
@end


