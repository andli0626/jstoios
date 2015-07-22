//
//  Jstorecord_ViewController.h
//  jstoios
//
//  Created by AndLi on 15/7/17.
//  Copyright (c) 2015年 AndLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol getRecPathDelegate <NSObject>

-(void)getRecPath:(NSString *)path;

@end

@interface Record_ViewController : UIViewController

@property(nonatomic,retain) id<getRecPathDelegate> delegate;

@end
