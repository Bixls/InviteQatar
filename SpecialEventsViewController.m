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
#import "ServiceViewController.h"

@interface SpecialEventsViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;


@property (nonatomic,strong) NetworkConnection *getEventsConnection;
@property (nonatomic,strong) NSArray *specialEvents;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *selectedService;
@property (nonatomic,strong) UIImage *selectedServiceImage;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;

@end

@implementation SpecialEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.view.backgroundColor = [UIColor blackColor];
//    NSLog(@"%ld",(long)self.eventType);
    self.start = 0;
    self.limit = 5000;
    
    switch (self.eventType) {
        case 1:
        {
         self.mainTitle.text = @"قاعات الافراح";
            break;
            
        }
        case 2:{
            self.mainTitle.text = @"شركات الخيام";
            break;
        }
        case 3:{
            self.mainTitle.text = @"المطابخ الشعبيه";
            break;
        }
        case 4:{
            self.mainTitle.text = @"الفرق الشعبيه";
            break;
        }
        case 5:{
            self.mainTitle.text = @"شامل";
            break;
        }
            
        default:
            break;
    }
    
    [self addOrRemoveFooter];
    
}

-(void)addOrRemoveFooter {
    BOOL remove = [[self.userDefaults objectForKey:@"removeFooter"]boolValue];
    [self removeFooter:remove];
    
}

-(void)removeFooter:(BOOL)remove{
    self.footerContainer.clipsToBounds = YES;
    if (remove == YES) {
        self.footerHeight.constant = 0;
    }else if (remove == NO){
        self.footerHeight.constant = 492;
    }
    [self.userDefaults setObject:[NSNumber numberWithBool:remove] forKey:@"removeFooter"];
    [self.userDefaults synchronize];
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

-(NSString *)arabicNumberFromEnglish:(NSInteger)num {
    NSNumber *someNumber = [NSNumber numberWithInteger:num];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}

#pragma mark - KVO 

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"response"]) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.specialEvents = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
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
        NSString *likes = [NSString stringWithFormat:@"%ld",(long)[event[@"Likes"]integerValue]];
        NSString *views = [NSString stringWithFormat:@"%ld",(long)[event[@"views"]integerValue]];

        cell.eventLikes.text = likes;
        cell.eventViews.text = views;
        cell.eventTitle.text = event[@"title"];
        
        NSURL *imgURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%@",event[@"image"]]];
        
        [cell.eventImage sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.eventImage.image = image;
        }];
        
        self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height;
        
        return cell;
    }
    
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.specialEvents[indexPath.row]) {
        SpecialEventsCollectionViewCell *Cell = (SpecialEventsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        self.selectedService = self.specialEvents[indexPath.row];
        self.selectedServiceImage = Cell.eventImage.image;
        [self performSegueWithIdentifier:@"showService" sender:self];
    }
    
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((self.collectionView.bounds.size.width - 5 )/2, 233);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 3 ;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showService"]) {
        ServiceViewController *serviceViewController = segue.destinationViewController;
        serviceViewController.service = self.selectedService;
        serviceViewController.serviceImage = self.selectedServiceImage;
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Buttons
- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
