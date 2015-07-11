//
//  NewsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UIViewController

@property(nonatomic,strong) NSDictionary *news;

@property (weak, nonatomic) IBOutlet UILabel *newsSubject;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *newsDate;
@property (weak, nonatomic) IBOutlet UILabel *newsTime;

@property (weak, nonatomic) IBOutlet UITextView *newsDescription;


@end
