//
//  UserViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController

@property (nonatomic,strong)NSDictionary *user;
@property(nonatomic) NSInteger otherUserID;
@property(nonatomic) NSInteger eventOrMsg;

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userGroup;

@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imgSendMessage;

- (IBAction)btnSendMessagePressed:(id)sender;

@end
