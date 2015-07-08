//
//  ViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ViewController.h"
#import "TestNewsCollectionViewCell.h"
#import "testCollectionViewCell.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *newsArray;
@property (nonatomic,strong) NSArray *eventsArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageArray = @[[UIImage imageNamed:@"3emadi.png"],[UIImage imageNamed:@"3etebi.png"],[UIImage imageNamed:@"elka3bi.png"],[UIImage imageNamed:@"elna3emi.png"],[UIImage imageNamed:@"eltamimi.png"],[UIImage imageNamed:@"ka7tani.png"],[UIImage imageNamed:@"kbesi.png"],[UIImage imageNamed:@"mare5i.png"],[UIImage imageNamed:@"eldosri.png"],[UIImage imageNamed:@"elhawager.png"],[UIImage imageNamed:@"elmra.png"],[UIImage imageNamed:@"elmasnad.png"]];
    self.imageArray = @[[UIImage imageNamed:@"3emadi.png"],[UIImage imageNamed:@"3etebi.png"],[UIImage imageNamed:@"elka3bi.png"]];
     self.eventsArray = @[[UIImage imageNamed:@"3emadi.png"],[UIImage imageNamed:@"3etebi.png"],[UIImage imageNamed:@"elka3bi.png"]];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //UICollectionViewCell *cell = [UICollectionViewCell ]
    if (collectionView.tag == 0) {
        return 2;
        //return self.imageArray.count + 3 + 2;
    }else{
        return 3;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1) {
        testCollectionViewCell *cell4 = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewsCell" forIndexPath:indexPath];
        cell4.newsImage.image = self.newsArray[0];
        return cell4;
    }
    if (indexPath.item == 0) {
         TestNewsCollectionViewCell *cell0 = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell0" forIndexPath:indexPath];
        return cell0;
    }
    if (indexPath.item == 1) {
        TestNewsCollectionViewCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell1" forIndexPath:indexPath];
        return cell1;
    }
    
    
//    TestNewsCollectionViewCell *cell2 = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell2" forIndexPath:indexPath];
//    TestNewsCollectionViewCell *cell3 = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell3" forIndexPath:indexPath];
//    
//   
////    }else if (cell2){
////        cell2.eventImage.image = self.eventsArray[indexPath.item];
////        return cell2;
////    }else if (cell3){
////        cell3.groupImage.image = self.imageArray[indexPath.item];
////        return cell3;
////    }
//
    return nil;
}


@end
