//
//  EventViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseDateViewController.h"
#import "NetworkConnection.h"

@interface EventViewController : UIViewController <chooseDateViewControllerDelegate , NetworkConnectionDelegate , UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentsHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

@property (weak, nonatomic) IBOutlet UITextField *CommentsTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgSendComments;
@property (weak, nonatomic) IBOutlet UILabel *eventLikes;
@property (weak, nonatomic) IBOutlet UILabel *eventViews;



@property (nonatomic)NSInteger isVIP;
@property (nonatomic)NSInteger eventID;
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
@property (weak, nonatomic) IBOutlet UIImageView *imgTitle;

@property (weak, nonatomic) IBOutlet UIImageView *imgGoing;
@property (weak, nonatomic) IBOutlet UIImageView *imgComments;
@property (weak, nonatomic) IBOutlet UIImageView *imgGoingList;
@property (weak, nonatomic) IBOutlet UIButton *btnEditEvent;
@property (weak, nonatomic) IBOutlet UIImageView *imgEditEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnInviteOthers;
@property (weak, nonatomic) IBOutlet UIImageView *imgInviteOthers;

@property (weak, nonatomic) IBOutlet UIImageView *imgRemindMe;
@property (weak, nonatomic) IBOutlet UIButton *btnRemindMe;
@property (weak, nonatomic) IBOutlet UIImageView *imgPicFrame;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLike;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;

- (IBAction)btnSendCommentPressed:(id)sender;
- (IBAction)btnViewAttendeesPressed:(id)sender;
- (IBAction)btnShowCommentsPressed:(id)sender;
- (IBAction)btnGoingPressed:(id)sender;
- (IBAction)btnEditEventPressed:(id)sender;
- (IBAction)btnShowUserPressed:(id)sender;
- (IBAction)btnInviteOthersPressed:(id)sender;
- (IBAction)btnRemindMePressed:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *eventTime;

@end
