//
//  MessagesFirstTableViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesFirstTableViewCell : UITableViewCell 


@property (weak, nonatomic) IBOutlet UILabel *msgSender;

@property (weak, nonatomic) IBOutlet UILabel *msgSubject;

@property (weak, nonatomic) IBOutlet UIImageView *msgImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondMsgImage;
@property (weak, nonatomic) IBOutlet UIButton *btnRemindMe;
@property (weak, nonatomic) IBOutlet UIImageView *btnRemindMeFrame;

@end
