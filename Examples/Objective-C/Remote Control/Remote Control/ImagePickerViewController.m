//
//  ImageViewController.m
//  Remote Control
//
//  Created by Calvin on 7/7/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "AdminViewTabBarController.h"

@interface ImagePickerViewController ()

@property (nonatomic, retain) UIButton *currentButton;

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)imageButtonPressed:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    [self.currentButton setImage:[UIImage imageNamed:@"radioButtonOff"]
                        forState:UIControlStateNormal];
    
    [selectedButton setImage:[UIImage imageNamed:@"radioButtonOn"]
                    forState:UIControlStateNormal];
    
    self.currentButton = selectedButton;
    
    if (self.tabBarController) {
        AdminViewTabBarController *tabBarController = (AdminViewTabBarController *)self.tabBarController;
        [tabBarController sendObject:@(selectedButton.tag) sender:self];
    }
}


@end
