//
//  TestNewsCollectionViewCell.h
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestNewsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *newsCollectionView;

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UIImageView *groupImage;

@end
