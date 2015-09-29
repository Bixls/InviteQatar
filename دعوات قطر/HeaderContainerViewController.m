//
//  HeaderContainerViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 29,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import "HeaderContainerViewController.h"

@interface HeaderContainerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *homePageButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation HeaderContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)homePageBtnPressed:(id)sender {
    [self.delegate homePageBtnPressed];
}

- (IBAction)backBtnPressed:(id)sender {
    [self.delegate backBtnPressed];
}


@end
