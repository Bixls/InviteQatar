//
//  FullImageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 1,10//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import "FullImageViewController.h"

@interface FullImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *largeImage;
@end

@implementation FullImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.largeImage.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
