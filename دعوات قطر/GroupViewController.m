//
//  GroupViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "GroupViewController.h"
#import "ASIHTTPRequest.h"
#import <UIKit/UIKit.h>
#import "groupCollectionViewCell.h"
#import "GroupsFooterCollectionReusableView.h"
#import "AllSectionsViewController.h"
#import "EventViewController.h"
#import "GroupNewsCollectionViewCell.h"
#import "NewsViewController.h"
@interface GroupViewController ()

@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSArray *news;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSDictionary *selectedNews;
@property (nonatomic,strong) NSString *eventImageURL;
@property (nonatomic,strong) NSString *eventName;
@property (nonatomic,strong) NSString *eventPlace;
@property (nonatomic,strong) NSString *eventOwner;
@property (nonatomic,strong) NSString *eventTime;

@property (nonatomic) NSInteger groupID;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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

    self.groupID = [self.group[@"id"]integerValue];
    NSLog(@"%ld",(long)self.groupID);
    
    NSDictionary *getEventsDict = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                                                 @"catID":@"-1",
                                                                                 @"start":@"0",@"limit":@"3"}]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    [self postRequest:getEventsDict withTag:getEventsTag];
    
    NSDictionary *getNews = @{
                              @"FunctionName":@"GetNewsList" ,
                              @"inputs":@[@{@"GroupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                            @"start":@"0",
                                            @"limit":@"3"}]};
    NSLog(@"%@",getNews);
    NSMutableDictionary *getNewsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getNews",@"key", nil];

    
    [self postRequest:getNews withTag:getNewsTag];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 0) {
        return self.events.count;
    }else if (collectionView.tag==1){
        return self.news.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    if (collectionView.tag==0) {
        groupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        NSDictionary *currentEvent = self.events[indexPath.item];
        cell.subject.text = [currentEvent objectForKey:@"subject"];;
        cell.creator.text = [currentEvent objectForKey:@"CreatorName"];;
        cell.time.text = [currentEvent objectForKey:@"TimeEnded"];;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",currentEvent[@"EventPic"]];
            // NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            UIImage *img = [[UIImage alloc]initWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                cell.profilePic.image = img ;
            });
        });
        
        return cell;

    }
    if (collectionView.tag == 1){
        GroupNewsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewsCell" forIndexPath:indexPath];
        if (self.news.count > 0) {
            NSDictionary *oneNews = self.news[indexPath.row];
            cell.newsSubject.text = oneNews[@"Subject"];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background Thread
                NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",oneNews[@"Image"]];
                // NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                UIImage *img = [[UIImage alloc]initWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    cell.newsImage.image = img ;
                });
            });
            
        }
        return cell;
    }
    return nil;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind== UICollectionElementKindSectionFooter && collectionView.tag == 0) {
        GroupsFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        //footer.btnSeeMore.tag = indexPath.section;
        reusableview = footer;
    }
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 0) {
        self.selectedEvent = self.events[indexPath.item];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"showEvent" sender:self];
    }else if (collectionView.tag==1){
        self.selectedNews = self.news[indexPath.item];
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"showNews" sender:self];
    }
  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSections"]) {
        AllSectionsViewController *allSectionsController = segue.destinationViewController;
        allSectionsController.groupID = self.groupID;
    }else if ([segue.identifier isEqualToString:@"showEvent"]){
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }else if ([segue.identifier isEqualToString:@"showNews"]){
        NewsViewController *newsController = segue.destinationViewController;
        newsController.news = self.selectedNews;
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Connection setup

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
    if ([key isEqualToString:@"getEvents"]) {
        self.events = array;
        [self.collectionView reloadData];
    }else if ([key isEqualToString:@"getNews"]){
        self.news = array;
        NSLog(@"NEWS %@",self.news);
        [self.newsCollectionView reloadData];
    }
    NSLog(@"%@",array);
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



@end
