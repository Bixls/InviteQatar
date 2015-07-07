//
//  UserViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "UserViewController.h"

@interface UserViewController ()

@property(nonatomic) NSInteger userID;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userName.text = self.user[@"name"];
    self.userID = [self.user[@"id"]integerValue];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *userImage = [[UIImage alloc]initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.userPicture.image = userImage;
        });
    });

}



@end
