//
//  AllSectionsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "AllSectionsViewController.h"
#import "ASIHTTPRequest.h"
#import "AllSectionsCellCollectionView.h"
#import "AllSectionHeaderCollectionReusableView.h"
#import "AllSectionFooterCollectionReusableView.h"
#import "SecEventsViewController.h"
#import "EventViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
#import "customEventCollectionViewCell.h"

@interface AllSectionsViewController ()

@property (nonatomic,strong) NSArray *allSections;
@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic) int skeletonSections;
@property (nonatomic) NSMutableDictionary *sectionContent;
@property (nonatomic) int flag;
@property (nonatomic) NSInteger secCount;
@property (nonatomic) NSInteger backFLag;
@property (nonatomic) NSInteger selectedSection;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSString *selectedSectionName;
@property (nonatomic,strong) UIActivityIndicatorView *userPicSpinner;

@end

@implementation AllSectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationItem.backBarButtonItem = nil;
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.view.backgroundColor = [UIColor blackColor];
    self.secCount = 0;
    self.flag = 0;
    self.sectionContent = [[NSMutableDictionary alloc]init];
    self.backFLag = 0 ;
    //Get All sections first
    [self.navigationItem setHidesBackButton:YES];
    self.userPicSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.userPicSpinner.hidesWhenStopped = YES;
    self.userPicSpinner.center = self.view.center;
    [self.view addSubview:self.userPicSpinner];
    [self.userPicSpinner startAnimating];
}

-(void)viewDidAppear:(BOOL)animated{


    if (self.backFLag != 1) {
        NSDictionary *getAllSections = @{@"FunctionName":@"getEventCategories" , @"inputs":@[@{
                                                                                                 }]};
        NSMutableDictionary *getAllSectionsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getSections",@"key", nil];
        [self postRequest:getAllSections withTag:getAllSectionsTag];
        self.backFLag = 1 ;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

-(NSString *)GenerateArabicDateWithDate:(NSString *)englishDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [formatter dateFromString:englishDate];
    NSString *arabicDate = [formatter stringFromDate:dateString];
    NSString *date = [arabicDate substringToIndex:16];
    return [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",section]];
    if (content.count > 0) {
        return content.count;
    }else{
        return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
     return self.sectionContent.count;
}

-(customEventCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier = @"eventCell";
//    
//    AllSectionsCellCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    
//    if (self.allSections.count) {
//        NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
//        if (content) {
////            NSLog(@"%@",self.sectionContent);
////            NSLog(@"%@",content);
//            if (content.count>0) {
//                NSDictionary *event = content[indexPath.row];
//                cell.eventName.text = event[@"subject"];
//                cell.eventCreator.text = event[@"CreatorName"];
//                cell.eventDate.text = [self GenerateArabicDateWithDate:event[@"TimeEnded"]];
//                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",event[@"EventPic"]];
//                NSURL *imgURL = [NSURL URLWithString:imgURLString];
//                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//                [cell.eventPicture sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                    spinner.center = cell.eventPicture.center;
//                    spinner.hidesWhenStopped = YES;
//                    [cell addSubview:spinner];
//                    [spinner startAnimating];
//                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                    cell.eventPicture.image = image;
//                    [spinner stopAnimating];
////                    NSLog(@"Cache Type %ld",(long)cacheType);
//                }];
//
//            }
//        }
//
//        // NSArray *content = [self.sectionContent objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section+1]] ;
//    }
//    return cell;
    
    customEventCollectionViewCell *cell = (customEventCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
    
    if (self.allSections.count) {
        NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        if (content.count > 0) {
            
            NSDictionary *tempEvent = content[indexPath.row];
            
            cell.eventName.text =tempEvent[@"subject"];
            cell.eventCreator.text = tempEvent[@"CreatorName"];
            
            cell.likesNumber.text = [self arabicNumberFromEnglish:[tempEvent[@"Likes"]integerValue]];
            cell.viewsNumber.text = [self arabicNumberFromEnglish:[tempEvent[@"views"]integerValue]];
            
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
            [formatter setLocale:qatarLocale];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",tempEvent[@"TimeEnded"]]];
            NSString *date = [formatter stringFromDate:dateString];
            NSString *dateWithoutSeconds = [date substringToIndex:16];
            cell.eventDate.text = [dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            
            cell.eventPic.layer.masksToBounds = YES;
            cell.eventPic.layer.cornerRadius = cell.eventPic.bounds.size.width/2;
            
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            UIActivityIndicatorView *eventsSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [cell.eventPic sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                eventsSpinner.center = cell.eventPic.center;
                eventsSpinner.hidesWhenStopped = YES;
                [cell addSubview:eventsSpinner];
                [eventsSpinner startAnimating];
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                cell.eventPic.image = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [eventsSpinner stopAnimating];
                });
                
            }];
            
            self.collectionViewHeight.constant = collectionView.contentSize.height;
            UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
            [aFlowLayout setSectionInset:UIEdgeInsetsMake(5, 0, 5, 0)];
        }
    }
    
    return cell;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        AllSectionHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        if (content.count>0) {
            NSDictionary *event = content[0];
            NSInteger catID = [event[@"catID"]integerValue];
            for (int i = 0; i < self.allSections.count; i++) {
                NSDictionary *section = self.allSections[i];
                if ([section[@"catID"]integerValue]==catID) {
                    header.headerLabel.text = section[@"catName"];
                }
            }
        }
        reusableview = header;
    }
    
    if (kind== UICollectionElementKindSectionFooter) {
        AllSectionFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        footer.btnSeeMore.tag = indexPath.section;
        reusableview = footer;
    }
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSection = indexPath.section ;
    NSArray *content = [self.sectionContent objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]] ;
    self.selectedEvent = content[indexPath.row];
    [self performSegueWithIdentifier:@"enterEvent" sender:self];
}

-(NSString *)arabicNumberFromEnglish:(NSInteger)num {
    NSNumber *someNumber = [NSNumber numberWithInteger:num];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"enterSection"]) {
        SecEventsViewController *secEventsController = segue.destinationViewController;
        secEventsController.selectedSection = self.selectedSection;
        secEventsController.groupID = self.groupID;
        secEventsController.sectionName = self.selectedSectionName;
    }else if ([segue.identifier isEqualToString:@"enterEvent"]){
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }
}


#pragma mark - Connection Setup

-(void)getEvents {
    
    for (int i =0 ; i <self.allSections.count ; i++) {
        NSDictionary *section = self.allSections[i];
        NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                                                 @"catID":[NSString stringWithFormat:@"%@",section[@"catID"]],
                                                                                 @"start":@"0",
                                                                                 @"limit":@"5"}]};//Default values
        NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",section[@"catID"]],@"key", nil];
        
        [self postRequest:getEvents withTag:getEventsTag];
    }
    

}


-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict{
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    NSString *urlString = @"http://bixls.com/Qatar/" ;
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.username =@"admin";
    request.password = @"admin";
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Authorization" value:authValue];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    request.allowCompressedResponse = NO;
    request.useCookiePersistence = NO;
    request.shouldCompressRequestBody = NO;
    request.userInfo = dict;
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    [request startAsynchronous];
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    //NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    if ([key isEqualToString:@"getSections"]) {
        self.allSections = array ;
//        NSLog(@"%@",array);
        [self getEvents];
        
    }
    
    for (int i = 0 ; i <self.allSections.count; i++) {
        NSDictionary *section = self.allSections[i];
        if ([key isEqualToString:section[@"catID"]]) {
            if (array.count>0) {
                self.skeletonSections = 1;
//                NSLog(@"arraay %@",array);
                [self.sectionContent setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)self.secCount]];
                self.secCount++;
                [self.collectionView reloadData];
            }
        }
    }
    
//    NSLog(@"%@",self.sectionContent);
    self.flag++;
    if (self.flag == self.allSections.count) {
        [self.collectionView reloadData];
    }
     [self.userPicSpinner stopAnimating];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    //NSLog(@"%@",error);
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSeeMorePressed:(id)sender {
    UIButton *pressedBtn = (UIButton *)sender;
    NSInteger *tempSection = pressedBtn.tag;
    NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)tempSection]];
    NSDictionary *event = content[0];
    NSInteger catID = [event[@"catID"]integerValue];
    for (int i = 0; i < self.allSections.count; i++) {
        NSDictionary *section = self.allSections[i];
        if ([section[@"catID"]integerValue]==catID) {
            self.selectedSection =catID;
            self.selectedSectionName = section[@"catName"];
        }
    }
//    NSLog(@"Section : %ld",(long)self.selectedSection);
    
}


@end
