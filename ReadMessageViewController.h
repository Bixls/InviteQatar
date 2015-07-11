//
//  ReadMessageViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadMessageViewController : UIViewController

@property(nonatomic)NSInteger messageID;
@property(nonatomic)NSInteger profilePicNumber;
@property(nonatomic)NSInteger messageType;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *messageSubject;

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@property (weak, nonatomic) IBOutlet UILabel *labelSubject;
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;


@end
