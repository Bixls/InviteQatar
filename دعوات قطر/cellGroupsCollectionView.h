//
//  cellGroupsCollectionView.h
//  دعوات قطر
//
//  Created by Adham Gad on 2,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "adSpace.h"

@interface cellGroupsCollectionView : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *groupPP;
@property (weak, nonatomic) IBOutlet UIImageView *royalPP;
@property (weak, nonatomic) IBOutlet adSpace *adPic;


@end
