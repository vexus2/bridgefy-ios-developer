//
//  AdminViewBarViewController.m
//  Remote Control
//
//  Created by Calvin on 7/7/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import "AdminViewTabBarController.h"

@interface AdminViewTabBarController () <UITabBarDelegate>

@end

@implementation AdminViewTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Admin panel";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendObject:(id)object sender:(id)sender {
    [self.mvc sendObject:object sender:sender];
}

@end
