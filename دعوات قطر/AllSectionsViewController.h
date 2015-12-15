//
//  AllSectionsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"
#import "FooterContainerViewController.h"

@interface AllSectionsViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,headerContainerDelegate,FooterContainerDelegate>

@property (nonatomic) NSInteger groupID;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

- (IBAction)btnSeeMorePressed:(id)sender;

@end
