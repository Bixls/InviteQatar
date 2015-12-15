//
//  MyEventsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"
#import "FooterContainerViewController.h"

@interface MyEventsViewController : UIViewController <headerContainerDelegate,FooterContainerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *eventsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventsCollectionViewHeight;

@end
