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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img3Height;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn2Height;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn3Height;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img2Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img3Width;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn2Width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn3Width;

@end
