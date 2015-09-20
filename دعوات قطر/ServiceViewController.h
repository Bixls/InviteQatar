//
//  ServiceViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 20,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceViewController : UIViewController

@property (nonatomic,strong) NSDictionary *service;
@property (nonatomic,strong) UIImage *serviceImage;

@property (weak, nonatomic) IBOutlet UIImageView *serviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *serviceLikes;
@property (weak, nonatomic) IBOutlet UILabel *serviceViews;
@property (weak, nonatomic) IBOutlet UITextView *serviceDescription;

@property (weak, nonatomic) IBOutlet UILabel *serviceTitle;


@end
