//
//  AllSectionsCellTableViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllSectionsCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;

@property (weak, nonatomic) IBOutlet UILabel *eventName;

@property (weak, nonatomic) IBOutlet UILabel *eventCreator;

@property (weak, nonatomic) IBOutlet UILabel *eventDate;

@end
