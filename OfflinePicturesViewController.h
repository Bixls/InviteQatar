//
//  OfflinePicturesViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 11,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol offlinePicturesViewControllerDelegate <NSObject>

-(void)selectedPicture:(UIImage *)image;

@end

@interface OfflinePicturesViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,weak) id <offlinePicturesViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)btnDismissPressed:(id)sender;

@end
