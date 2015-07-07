//
//  HomePageViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *groupsCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileBarBtn;

@end
