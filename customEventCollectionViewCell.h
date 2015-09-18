//
//  customEventCollectionViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 17,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customEventCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventPic;
@property (weak, nonatomic) IBOutlet UILabel *likesNumber;
@property (weak, nonatomic) IBOutlet UILabel *viewsNumber;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventCreator;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;


@end
