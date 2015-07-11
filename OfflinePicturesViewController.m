//
//  OfflinePicturesViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 11,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "OfflinePicturesViewController.h"
#import "OfflinePicturesCollectionViewCell.h"
@interface OfflinePicturesViewController ()

@property (nonatomic,strong) NSArray *imageArray;

@end

@implementation OfflinePicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArray = @[[UIImage imageNamed:@"3emadi.png"],[UIImage imageNamed:@"3etebi.png"],[UIImage imageNamed:@"elka3bi.png"],[UIImage imageNamed:@"elna3emi.png"],[UIImage imageNamed:@"eltamimi.png"],[UIImage imageNamed:@"ka7tani.png"],[UIImage imageNamed:@"kbesi.png"],[UIImage imageNamed:@"mare5i.png"],[UIImage imageNamed:@"eldosri.png"],[UIImage imageNamed:@"elhawager.png"],[UIImage imageNamed:@"elmra.png"],[UIImage imageNamed:@"elmasnad.png"]];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OfflinePicturesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.picture.image = self.imageArray[indexPath.item];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate selectedPicture:self.imageArray[indexPath.row]];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnDismissPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
