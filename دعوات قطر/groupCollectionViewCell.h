//
//  groupCollectionViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface groupCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *creator;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *vipImage;
@property (weak, nonatomic) IBOutlet UILabel *vipLabel;

@end
