//
//  EventViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController


@property (nonatomic) NSInteger selectedType;
@property (nonatomic) NSInteger selectedMessageID;
@property (nonatomic,strong) NSDictionary *event;
@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;
@property (weak, nonatomic) IBOutlet UILabel *eventSubject;
@property (weak, nonatomic) IBOutlet UIImageView *creatorPicture;

@property (weak, nonatomic) IBOutlet UILabel *creatorName;

@property (weak, nonatomic) IBOutlet UILabel *eventDate;
@property (weak, nonatomic) IBOutlet UIButton *btnComments;
@property (weak, nonatomic) IBOutlet UIButton *btnGoing;
@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnAttendees;

@property (weak, nonatomic) IBOutlet UIImageView *imgGoing;
@property (weak, nonatomic) IBOutlet UIImageView *imgComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgGoingList;
@property (weak, nonatomic) IBOutlet UIButton *btnEditEvent;
@property (weak, nonatomic) IBOutlet UIImageView *imgEditEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnInviteOthers;
@property (weak, nonatomic) IBOutlet UIImageView *imgInviteOthers;



- (IBAction)btnViewAttendeesPressed:(id)sender;
- (IBAction)btnShowCommentsPressed:(id)sender;
- (IBAction)btnGoingPressed:(id)sender;
- (IBAction)btnEditEventPressed:(id)sender;
- (IBAction)btnShowUserPressed:(id)sender;
- (IBAction)btnInviteOthersPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *eventTime;

@end
