//
//  SpecialEventsCollectionViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 20,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpecialEventsCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventLikes;
@property (weak, nonatomic) IBOutlet UILabel *eventViews;
@property (weak, nonatomic) IBOutlet UILabel *eventTitle;



@end
