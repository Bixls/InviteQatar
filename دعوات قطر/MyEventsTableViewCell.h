//
//  MyEventsTableViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEventsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;
@property (weak, nonatomic) IBOutlet UILabel *eventSubject;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UIImageView *vipImage;
@property (weak, nonatomic) IBOutlet UILabel *vipLabel;


@end
