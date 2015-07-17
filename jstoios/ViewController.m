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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"js to ios";
    
    NSDictionary *dic = [[NSBundle mainBundle]infoDictionary];
    NSString *version = [dic objectForKey:@"CFBundleShortVersionString"];

    _versionLabel.hidden =YES;
    

    NavTitleButton *titleView = [[NavTitleButton alloc]init];
    titleView.height = 35;
    [titleView setTitle:[NSString stringWithFormat:@"jstoios V%@",version] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleView;
    
    [self checkUpdate];
}

/**
 *  检查更新
 */
- (void)checkUpdate
{
    //  有回调的检查更新
    [[PgyManager sharedPgyManager] checkUpdateWithDelegete:self selector:@selector(updateMethod:)];
    
    //    无回调的检查更新，如果有新版本，则会提示用户更新，确认更新后会自动安装新版本
    //    [[PgyManager sharedPgyManager] checkUpdate];
}

/**
 *  检查更新回调
 *
 *  @param response 检查更新的返回结果
 */
- (void)updateMethod:(NSDictionary *)response
{
    if (response[@"downloadURL"]) {
        
        NSString *message = response[@"releaseNote"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"好的"
                                                  otherButtonTitles:nil,
                                  nil];
        
        [alertView show];
    }
    
    //    调用checkUpdateWithDelegete后可用此方法来更新本地的版本号，如果有更新的话，在调用了此方法后再次调用将不提示更新信息。
    //    [[PgyManager sharedPgyManager] updateLocalBuildNumber];
}

@end
