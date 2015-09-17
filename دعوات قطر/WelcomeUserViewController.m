//
//  WelcomeUserViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 14,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "WelcomeUserViewController.h"

@interface WelcomeUserViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicator;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@property (strong,nonatomic) NetworkConnection *downloadImageConnection;


@end

@implementation WelcomeUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.userNameLabel.text = self.userName;
    self.groupNameLabel.text = self.groupName;

    self.downloadImageConnection = [[NetworkConnection alloc]init];
    self.downloadImageConnection.delegate = self;


}

-(void)viewDidAppear:(BOOL)animated{
//    [self.downloadImageConnection downloadImageWithID:self.imageID];
    [self.downloadImageConnection downloadImageWithID:self.imageID withCacheNameSpace:@"profile" withKey:@"profilePic" withWidth:150 andHeight:150];
    [self.imageActivityIndicator startAnimating];
}

#pragma mark - Network Connection Delegate

-(void)downloadedImage:(UIImage *)image{
    [self.imageActivityIndicator stopAnimating];
    [self.imageActivityIndicator setHidden:YES];
    self.userImage.image = image;
    
}

- (IBAction)logoPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
