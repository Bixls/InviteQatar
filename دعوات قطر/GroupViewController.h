//
//  GroupViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "HeaderContainerViewController.h"

@interface GroupViewController : UIViewController  <UICollectionViewDataSource,UICollectionViewDelegate,ASIHTTPRequestDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,headerContainerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *eventsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventsCollectionViewHeight;

@property (weak, nonatomic) IBOutlet UICollectionView *newsCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@property (strong,nonatomic) NSDictionary *group;


@property (weak, nonatomic) IBOutlet UIImageView *groupPic;
@property (weak, nonatomic) IBOutlet UITextView *groupDescription;
@property (weak, nonatomic) IBOutlet UIImageView *groupFrame;
@property (weak, nonatomic) IBOutlet UILabel *lblLatestEvents;
@property (weak, nonatomic) IBOutlet UILabel *lblLatestNews;
@property (weak, nonatomic) IBOutlet UILabel *lblUsers;
@property (weak, nonatomic) IBOutlet UIButton *btnSeeMoreUsers;
@property (weak, nonatomic) IBOutlet UIImageView *imgSeeMoreUsers;
@property (weak, nonatomic) IBOutlet UILabel *lblNewsError;
@property (weak, nonatomic) IBOutlet UILabel *lblEventsError;
@property (weak, nonatomic) IBOutlet UILabel *lblMembersError;



@end
