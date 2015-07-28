//
//  GroupViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface GroupViewController : UIViewController  <UICollectionViewDataSource,UICollectionViewDelegate,ASIHTTPRequestDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *newsCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@property (strong,nonatomic) NSDictionary *group;


@property (weak, nonatomic) IBOutlet UIImageView *groupPic;
@property (weak, nonatomic) IBOutlet UITextView *groupDescription;



@end
