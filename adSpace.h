//
//  adSpace.h
//  دعوات قطر
//
//  Created by Adham Gad on 17,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface adSpace : UIView

@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIImageView *adSpaceSC;
@property (weak, nonatomic) IBOutlet UIButton *largeAd;
@property (weak, nonatomic) IBOutlet UIButton *rightAd;
@property (weak, nonatomic) IBOutlet UIButton *leftAd;

@end
