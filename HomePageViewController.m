//
//  HomePageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "HomePageViewController.h"

@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 1000.0)];
}




@end
