//
//  HomeEventsTableViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeEventsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventSubject;
@property (weak, nonatomic) IBOutlet UILabel *eventCreator;

@property (weak, nonatomic) IBOutlet UILabel *eventDate;

@end
