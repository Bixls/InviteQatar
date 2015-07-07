//
//  EventViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController

@property (nonatomic,strong) NSDictionary *event;
@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;
@property (weak, nonatomic) IBOutlet UILabel *eventSubject;
@property (weak, nonatomic) IBOutlet UIImageView *creatorPicture;

@property (weak, nonatomic) IBOutlet UILabel *creatorName;

@property (weak, nonatomic) IBOutlet UILabel *eventDate;

- (IBAction)btnViewAttendeesPressed:(id)sender;

@end
