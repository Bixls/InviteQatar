//
//  WelcomePageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "WelcomePageViewController.h"

@interface WelcomePageViewController ()

@property (nonatomic,strong)NSUserDefaults *userDefaults ;
@property (nonatomic) NSInteger activateFlag;
@end

@implementation WelcomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.hidden = YES;
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.activateFlag = [self.userDefaults integerForKey:@"activateFlag"];
    if (self.activateFlag == 1) {
        [self performSegueWithIdentifier:@"activateAccount" sender:self];
    }
}

- (IBAction)btnGuestPressed:(id)sender {
    [self.userDefaults setInteger:1 forKey:@"Visitor"];
    [self.userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end


//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                             forBarMetrics:UIBarMetricsDefault];

//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;