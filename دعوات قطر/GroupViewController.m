//
//  GroupViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "GroupViewController.h"

#import <UIKit/UIKit.h>
#import "groupCollectionViewCell.h"
#import "GroupsFooterCollectionReusableView.h"
#import "AllSectionsViewController.h"
#import "EventViewController.h"
#import "GroupNewsCollectionViewCell.h"
#import "NewsViewController.h"
#import <SVPullToRefresh.h>
#import "GroupUsersTableViewCell.h"
#import "UserViewController.h"
#import "Reachability.h"


@interface GroupViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;

@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSArray *news;
@property (nonatomic,strong) NSMutableArray *users;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSDictionary *selectedNews;
@property (nonatomic,strong) NSString *eventImageURL;
@property (nonatomic,strong) NSString *eventName;
@property (nonatomic,strong) NSString *eventPlace;
@property (nonatomic,strong) NSString *eventOwner;
@property (nonatomic,strong) NSString *eventTime;
@property (nonatomic,strong) NSDictionary *selectedUser;
@property (nonatomic) NSInteger groupID;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;

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
    self.view.backgroundColor = [UIColor blackColor];
    self.users = [[NSMutableArray alloc]init];
    self.start = 0;
    self.limit = 10;
    self.groupID = [self.group[@"id"]integerValue];
//    NSLog(@"%ld",(long)self.groupID);
    [self.navigationItem setHidesBackButton:YES];
    
    //Hide all UI elements
    //[self.groupFrame setHidden:YES];
   // [self.groupPic setHidden:YES];
    [self.lblLatestEvents setHidden:YES];
    [self.lblLatestNews setHidden:YES];
    [self.lblUsers setHidden:YES];
    [self.btnSeeMoreUsers setHidden:YES];
    [self.imgSeeMoreUsers setHidden:YES];
    [self.lblNewsError setHidden:YES];
    [self.lblEventsError setHidden:YES];
    [self.lblMembersError setHidden:YES];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.group[@"ProfilePic"]];
            NSLog(@"%@",imgURLString);
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.groupPic.image = image;
            });
        });

    }
    else {
        //there-is-no-connection warning
        [self.groupFrame setHidden:YES];
        [self.groupPic setHidden:YES];
        [self.groupDescription setHidden:YES];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSDictionary *getGroupInfo = @{@"FunctionName":@"getGroupbyID" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.groupID],}]};
    NSMutableDictionary *getGroupInfoTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getGroupInfo",@"key", nil];
    [self postRequest:getGroupInfo withTag:getGroupInfoTag];
    
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
    
    NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                   @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",self.groupID],
                                                 @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                 @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]}]}; // needs to be changed
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
    [self postRequest:getUSersDict withTag:getUsersTag];
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
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
        [formatter setLocale:qatarLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",currentEvent[@"TimeEnded"]]];
        NSString *date = [formatter stringFromDate:dateString];
        NSString *dateWithoutSeconds = [date substringToIndex:16];

        cell.time.text = [dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"];;
        if ([[currentEvent objectForKey:@"VIP"]integerValue] == 0) {
            [cell.vipImage setHidden:YES];
            [cell.vipLabel setHidden:YES];
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",currentEvent[@"EventPic"]];
            // NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            UIImage *img = [[UIImage alloc]initWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                cell.profilePic.image = img ;
            });
        });
        self.verticalLayoutConstraint.constant = self.collectionView.contentSize.height;
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

    if (self.events.count > 0) {
        if (kind== UICollectionElementKindSectionFooter && collectionView.tag == 0) {
            GroupsFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
            //footer.btnSeeMore.tag = indexPath.section;
            [footer.btnSeeMore setHidden:NO];
            [footer.imgSeeMore setHidden:NO];
            reusableview = footer;
        }
        return reusableview;
    }else{
        if (kind== UICollectionElementKindSectionFooter && collectionView.tag == 0) {
            GroupsFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
            //footer.btnSeeMore.tag = indexPath.section;
            [footer.btnSeeMore setHidden:YES];
            [footer.imgSeeMore setHidden:YES];
            reusableview = footer;
        }
        
        return reusableview;
    }

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



#pragma mark - Table View 


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.users.count > 0 ) {
        return self.users.count  ;
    }else{
        return 0;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"userCell";
    
    if (indexPath.row < self.users.count) {
        GroupUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[GroupUsersTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *tempUser = self.users[indexPath.row];
        if (tempUser != nil) {
            cell.userName.text = tempUser[@"name"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempUser[@"ProfilePic"]];
                NSURL *imgURL = [NSURL URLWithString:imgURLString];
                NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
                UIImage *image = [[UIImage alloc]initWithData:imgData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.userPic.image = image;
                });
                
            });
            
            self.tableVerticalLayoutConstraint.constant = self.usersTableView.contentSize.height;
            return cell ;

        }
        
    }
        //else if (indexPath.row == self.users.count){
//        GroupUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seeMore" forIndexPath:indexPath];
//        if (cell==nil) {
//            cell=[[GroupUsersTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        //self.tableVerticalLayoutConstraint.constant = self.collectionView.contentSize.height;
//        return cell;
//    }
    return nil;


}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedUser = self.users[indexPath.row];
    [self performSegueWithIdentifier:@"user" sender:self];
}

#pragma mark - Segue

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
    }else if ([segue.identifier isEqualToString:@"user"]) {
        UserViewController *userController = segue.destinationViewController;
        userController.user = self.selectedUser;
        
    }
    
}

#pragma mark - resize image
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Connection setup

-(void)getUsers{
    NSDictionary *getUSersDict = @{@"FunctionName":@"getUsersbyGroup" ,
                                   @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",self.groupID],
                                                 @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                 @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]}]}; // needs to be changed
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
    [self postRequest:getUSersDict withTag:getUsersTag];
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
    if ([key isEqualToString:@"getEvents"]) {
        self.events = array;
        if (self.events.count > 0) {
            [self.lblLatestEvents setHidden:NO];
            [self.collectionView reloadData];
        }else{
            // Atala3 label
            NSLog(@"No Events!");
            //[self.lblEventsError setHidden:NO];
            //[self.lblLatestEvents setHidden:NO];
           // [self.lblEventsError removeFromSuperview];
            //[self.lblLatestEvents removeFromSuperview];
            [self.lblEventsError setHidden:NO];
            [self.lblLatestEvents setHidden:NO];
            [self.collectionView removeFromSuperview];
            
        }
       
    }else if ([key isEqualToString:@"getNews"]){
        self.news = array;
      //  NSLog(@"NEWS %@",self.news);
        if (self.news.count > 0) {
            [self.lblLatestNews setHidden:NO];
            [self.newsCollectionView reloadData];
        }else{
            NSLog(@"No News!");
            
            [self.lblLatestNews setHidden:NO];
            [self.lblNewsError setHidden:NO];
            [self.newsCollectionView removeFromSuperview];
            //[self.lblNewsError removeFromSuperview];
            //[self.lblLatestNews removeFromSuperview];
         //   [self.lblNewsError setHidden:NO];
           // [self.lblLatestNews setHidden:NO];
        }
        
        
    }else if ([key isEqualToString:@"getGroupInfo"]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if (array.count>0) {
            NSDictionary *dict = array[0];
            NSLog(@"%@",dict);
            
            self.groupDescription.text = dict[@"Description"];
            if (self.groupDescription.text.length > 0) {
                [self.groupFrame setHidden:NO];
                [self.groupPic setHidden:NO];
                [self.groupDescription setHidden:NO];
                NSLog(@"%@",dict[@"Description"]);
            }
            
        }
     
    }else if ([key isEqualToString:@"getUsers"]) {
        [self.users addObjectsFromArray:array];
        NSLog(@"%@",self.users);
        self.start = self.users.count;
        if (self.users.count > 0) {
            [self.lblUsers setHidden:NO];
            [self.btnSeeMoreUsers setHidden:NO];
            [self.imgSeeMoreUsers setHidden:NO];
            [self.usersTableView reloadData];
        }else{
            NSLog(@"NO Users!");
            //[self.lblMembersError setHidden:NO];
            
        }
        
    }
    
    NSLog(@"%@",array);
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error.userInfo);
    NSString *errorType = error.userInfo[@"NSLocalizedDescription"];
    if ([errorType isEqualToString:@"A connection failure occurred"]) {
        //
    }
    
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)seeMoreBtnPresed:(id)sender {
    self.start = self.users.count;
    [self getUsers];
}


@end
