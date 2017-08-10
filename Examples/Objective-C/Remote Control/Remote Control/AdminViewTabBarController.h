//
//  AdminViewBarViewController.h
//  Remote Control
//
//  Created by Calvin on 7/7/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AdminViewTabBarController : UITabBarController

@property (weak, nonatomic) MainViewController *mvc;
- (void)sendObject:(id)object sender:(id)sender;

@end
