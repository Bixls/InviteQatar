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
@property (weak, nonatomic) IBOutlet UIButton *btnComments;
@property (weak, nonatomic) IBOutlet UIButton *btnGoing;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;



- (IBAction)btnViewAttendeesPressed:(id)sender;
- (IBAction)btnShowCommentsPressed:(id)sender;
- (IBAction)btnGoingPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *eventTime;

@end
