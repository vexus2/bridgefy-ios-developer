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

@property (weak, nonatomic) IBOutlet UIButton *image1Button;
@property (weak, nonatomic) IBOutlet UIButton *image2Button;
@property (weak, nonatomic) IBOutlet UIButton *image3Button;

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
    
    [self.image1Button setImage:[UIImage imageNamed:@"radioButtonOff"] forState:UIControlStateNormal];
    [self.image2Button setImage:[UIImage imageNamed:@"radioButtonOff"] forState:UIControlStateNormal];
    [self.image3Button setImage:[UIImage imageNamed:@"radioButtonOff"] forState:UIControlStateNormal];
    
    [selectedButton setImage:[UIImage imageNamed:@"radioButtonOn"] forState:UIControlStateNormal];
    
    if (self.tabBarController) {
        AdminViewTabBarController *tabBarController = (AdminViewTabBarController *)self.tabBarController;
        [tabBarController sendObject:@(selectedButton.tag) sender:self];
    }
}


@end
