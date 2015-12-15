//
//  SpecialEventsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 20,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderContainerViewController.h"
#import "FooterContainerViewController.h"

@interface SpecialEventsViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,headerContainerDelegate,FooterContainerDelegate>

@property (nonatomic) NSInteger eventType;


@end
