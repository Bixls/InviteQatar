//
//  AllSectionsCellCollectionView.h
//  دعوات قطر
//
//  Created by Adham Gad on 5,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllSectionsCellCollectionView : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;

@property (weak, nonatomic) IBOutlet UILabel *eventName;

@property (weak, nonatomic) IBOutlet UILabel *eventCreator;

@property (weak, nonatomic) IBOutlet UILabel *eventDate;

@end
