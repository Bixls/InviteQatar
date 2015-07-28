//
//  HomePageViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UICollectionViewRightAlignedLayout.h>

@interface HomePageViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDelegateRightAlignedLayout>


@property (weak, nonatomic) IBOutlet UICollectionView *groupsCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;

@property (weak, nonatomic) IBOutlet UIButton *btnMyAccount;
@property (weak, nonatomic) IBOutlet UIButton *btnMyMessages;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSupport;
@property (weak, nonatomic) IBOutlet UIButton *btnBuyInvitations;

@property (weak, nonatomic) IBOutlet UICollectionView *newsCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnUnReadMsgs;
@property (weak, nonatomic) IBOutlet UIButton *btnInvitationNum;
@property (weak, nonatomic) IBOutlet UIButton *btnVIPNum;
@property (weak, nonatomic) IBOutlet UILabel *myProfileLabel;

- (IBAction)btnSeeMorePressed:(id)sender;

- (IBAction)btnSupportPressed:(id)sender;

- (IBAction)myProfileBtnPressed:(id)sender;


@end
