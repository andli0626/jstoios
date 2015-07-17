//
//  ViewController.m
//  jstoios
//
//  Created by AndLi on 15/7/16.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//

#import "ViewController.h"
#import "NavTitleButton.h"

#import <PgySDK/PgyManager.h>

@interface ViewController ()<UIAlertViewDelegate>
{
    NSString *version;
    NSString *downloadURL;
    NSString *message;
    NSString *newversion;
    NSString *appUrl;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"js to ios";
    
    NSDictionary *dic = [[NSBundle mainBundle]infoDictionary];
    version = [dic objectForKey:@"CFBundleShortVersionString"];
    

    NavTitleButton *titleView = [[NavTitleButton alloc]init];
    titleView.height = 35;
    [titleView setTitle:[NSString stringWithFormat:@"jstoios V%@",version] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleView;
    
    [self checkUpdate];
}

#warning *************************************** 整合蒲公英自动更新代码 *********************************************************

//检查更新
- (void)checkUpdate
{
    //  有回调的检查更新
    [[PgyManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(updateMethod:)];
    
    //    无回调的检查更新，如果有新版本，则会提示用户更新，确认更新后会自动安装新版本
    //    [[PgyManager sharedPgyManager] checkUpdate];
}

//检查更新的返回结果
- (void)updateMethod:(NSDictionary *)response
{
    if (response[@"downloadURL"]) {
        appUrl      = response[@"appUrl"];
        message     = response[@"releaseNote"];
        newversion  = response[@"versionName"];
        downloadURL = response[@"downloadURL"];
        
        if([newversion isEqualToString:version]){
            return;
        }
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"更新"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(showUpdateAlert)];
        self.navigationItem.rightBarButtonItem = item;
        [self showUpdateAlert];
    }
}

//更新提示对话框
-(void)showUpdateAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"发现新版本 V%@",newversion]
                                                        message:[NSString stringWithFormat:@"%@",message]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定",
                              nil];
    
    [alertView show];
}

//对话框点击事件处理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
        {
            [self down];
        }
            break;
            
        default:
            break;
    }
}

//下载操作
-(void)down{
    NSURL *url = [NSURL URLWithString:downloadURL];
    [[UIApplication sharedApplication]openURL:url];
}

#warning *************************************** 整合蒲公英自动更新代码 *********************************************************


@end
