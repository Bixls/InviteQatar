//
//  WelcomeUserViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 14,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkConnection.h"

@interface WelcomeUserViewController : UIViewController <NetworkConnectionDelegate>

@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic) NSInteger imageID;


@end
