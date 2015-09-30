//
//  customGroupFooter.h
//  دعوات قطر
//
//  Created by Adham Gad on 18,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "adSpace.h"

@interface customGroupFooter : UICollectionReusableView

@property (weak, nonatomic) IBOutlet adSpace *adView;

@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;


@end
