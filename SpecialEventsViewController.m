//
//  SpecialEventsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 20,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SpecialEventsViewController.h"
#import "SpecialEventsCollectionViewCell.h"
#import "NetworkConnection.h"

@interface SpecialEventsViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;


@property (nonatomic,strong) NetworkConnection *getEventsConnection;
@property (nonatomic,strong) NSArray *specialEvents;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;

@end

@implementation SpecialEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
//    NSLog(@"%ld",(long)self.eventType);
    self.start = 0;
    self.limit = 5000;
    
}

-(void)viewDidAppear:(BOOL)animated{
    self.getEventsConnection = [[NetworkConnection alloc]init];
    [self.getEventsConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.getEventsConnection getSpecialEventWithType:self.eventType startFrom:self.start limit:self.limit];
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.getEventsConnection removeObserver:self forKeyPath:@"response"];
    
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

#pragma mark - KVO 

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"response"]) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.specialEvents = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        NSLog(@"%@",self.specialEvents);
        [self.collectionView reloadData];
        
    }
    
}

#pragma mark - Collection View 

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.specialEvents.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   SpecialEventsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (self.specialEvents.count > 0) {
        
        NSDictionary *event = self.specialEvents[indexPath.row];
        cell.eventLikes.text = event[@"Likes"];
        cell.eventViews.text = event[@"views"];
        cell.eventTitle.text = event[@"title"];
        
        NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",event[@"image"]]];
        
        [cell.eventImage sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.eventImage.image = image;
        }];
        
        self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height;
        
        return cell;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((self.collectionView.bounds.size.width - 5 )/2, 233);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 3 ;
}



#pragma mark - Buttons
- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
