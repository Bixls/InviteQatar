//
//  HomePageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "HomePageViewController.h"
#import "ASIHTTPRequest.h"
#import "cellGroupsCollectionView.h"
#import "HomeNewsCollectionViewCell.h"
#import "HomeEventsTableViewCell.h"
#import "EventViewController.h"
#import "GroupViewController.h"
#import "NewsViewController.h"
#import "AllSectionsViewController.h"
#import <SVPullToRefresh.h>

@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//@property (nonatomic , strong) NSArray *responseArray;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *groups;
@property (nonatomic,strong) NSArray *news;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSDictionary *selectedGroup;
@property (nonatomic,strong) NSDictionary *selectedNews;
@property (nonatomic)NSInteger pullToRefreshFlag;
@property (nonatomic)NSInteger userID;
@property (nonatomic)NSInteger unReadMsgs;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic) NSInteger segueFlag;
@property (nonatomic,strong) NSMutableArray *groupImages;
@property (nonatomic) NSInteger offlineGroupsFlag;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupImages = [[NSMutableArray alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    [self.userDefaults synchronize];
    self.pullToRefreshFlag = 0;
    [self.btnUnReadMsgs setHidden:YES];
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

   //self.groupsCollectionView.collectionViewLayout = [[UICollectionViewRightAlignedLayout alloc] init];
    [self.groupsCollectionView setTransform:CGAffineTransformMakeScale(-1, 1)];

}

-(void)viewDidAppear:(BOOL)animated {
    
    if ([self.userDefaults integerForKey:@"signedIn"] == 0 && [self.userDefaults integerForKey:@"Guest"]==0 && [self.userDefaults integerForKey:@"Visitor"] == 0) {
        [self performSegueWithIdentifier:@"welcomeSegue" sender:self];
        self.segueFlag = 0;
        [self.myProfileLabel setText:@"حسابي"];
        
    }
    if ([self.userDefaults integerForKey:@"Guest"]==1) {
        [self.btnBuyInvitations setEnabled:NO];
        self.segueFlag = 2;
        [self.myProfileLabel setText:@"حسابي"];
        //[self.btnMyAccount setEnabled:NO];
        [self.btnMyMessages setEnabled:NO];
        [self.btnSearch setEnabled:NO];
        [self.btnSupport setEnabled:NO];
        
        self.eventsTableView.allowsSelection = NO;
        self.newsCollectionView.allowsSelection = NO;
        self.groupsCollectionView.allowsSelection = NO;
        
    }else if ([self.userDefaults integerForKey:@"Visitor"] == 1){
        [self.btnBuyInvitations setEnabled:NO];
        //        [self.btnMyAccount setEnabled:NO];
        self.segueFlag = 1;
        [self.myProfileLabel setText:@"خروج"];
        [self.btnMyMessages setEnabled:NO];
        [self.btnSearch setEnabled:NO];
        [self.btnSupport setEnabled:NO];
        
        self.eventsTableView.allowsSelection = NO;
        self.newsCollectionView.allowsSelection = NO;
        self.groupsCollectionView.allowsSelection = NO;
        
    }else{
        [self.btnBuyInvitations setEnabled:YES];
        //        [self.btnMyAccount setEnabled:NO];
        [self.btnMyMessages setEnabled:YES];
        [self.btnSearch setEnabled:YES];
        [self.btnSupport setEnabled:YES];
        self.segueFlag = 0;
        [self.myProfileLabel setText:@"حسابي"];
        
        self.eventsTableView.allowsSelection = YES;
        self.newsCollectionView.allowsSelection = YES;
        self.groupsCollectionView.allowsSelection = YES;
    }
    
    NSArray *groups = [self.userDefaults objectForKey:@"groups"];
    if (groups != nil) {
        self.offlineGroupsFlag = 1 ;
        self.groups = groups;
        [self.groupsCollectionView reloadData];
    }
   
    
    NSDictionary *getGroups = @{
                                @"FunctionName":@"getGroupList" ,
                                @"inputs":@[@{@"limit":[NSNumber numberWithInteger:5000]}]};
    NSMutableDictionary *getGroupsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getGroups",@"key", nil];
    NSDictionary *getNews = @{
                              @"FunctionName":@"GetNewsList" ,
                              @"inputs":@[@{@"GroupID":[NSString stringWithFormat:@"%d",-1],
                                            @"start":[NSString stringWithFormat:@"%d",0],
                                            @"limit":[NSString stringWithFormat:@"%d",3]}]};
    NSMutableDictionary *getNewsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getNews",@"key", nil];
    
    NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":@"-1",
                                                                             @"catID":@"-1",
                                                                             @"start":@"0",@"limit":@"3"}]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    
    NSDictionary *getUnReadInbox = @{@"FunctionName":@"unReadInbox" , @"inputs":@[@{@"ReciverID":[NSString stringWithFormat:@"%ld",self.userID],
                                                                                    //                                                                             @"catID":@"-1",
                                                                                    //                                                                             @"start":@"0",@"limit":@"3"
                                                                                    }]};
    NSMutableDictionary *getUnReadInboxTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"unReadInbox",@"key", nil];
    
    [self postRequest:getGroups withTag:getGroupsTag];
    [self postRequest:getNews withTag:getNewsTag];
    [self postRequest:getEvents withTag:getEventsTag];
    [self postRequest:getUnReadInbox withTag:getUnReadInboxTag];
    
    
    self.scrollView.showsPullToRefresh;
    [self.scrollView addPullToRefreshWithActionHandler:^{
        [self postRequest:getGroups withTag:getGroupsTag];
        [self postRequest:getNews withTag:getNewsTag];
        [self postRequest:getEvents withTag:getEventsTag];
        [self postRequest:getUnReadInbox withTag:getUnReadInboxTag];
        
    }];
    
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

#pragma mark - Collection View methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 0) {
        return self.groups.count;
    }else{
        return self.news.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *cellIdentifier = @"Cell";
     cellGroupsCollectionView *cell = [[cellGroupsCollectionView alloc]init];
    
    if (collectionView.tag == 0) {
        NSDictionary *tempGroup = self.groups[indexPath.item];
        
        if (indexPath.item == 1  ) {
            for (int i = 0 ; i < self.groups.count; i++) {
                tempGroup = self.groups[i];
                if ([tempGroup[@"Royal"]integerValue] == 1) {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"royal" forIndexPath:indexPath];
                    break;
                }
            }
        }else{
             cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        }
        
        if (self.offlineGroupsFlag ==0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempGroup[@"ProfilePic"]];
                NSLog(@"%@",imgURLString);
                NSURL *imgURL = [NSURL URLWithString:imgURLString];
                NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
                UIImage *image = [[UIImage alloc]initWithData:imgData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([tempGroup[@"Royal"]integerValue] == 1) {
                        cell.royalPP.image = image;
                    }else{
                         cell.groupPP.image = image;
                    }
                    NSData *imageData = UIImagePNGRepresentation(image);
                    NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                    [self.userDefaults setObject:encodedDate forKey:tempGroup[@"ProfilePic"]];
                    [self.userDefaults synchronize];
                    
//                    [self.groupImages addObject:@"plus"];
//                    [self.userDefaults setObject:self.groupImages forKey:@"groupImages"];
//                    [self.userDefaults synchronize];
                });
            });

        }else if (self.offlineGroupsFlag == 1){
            //self.groupImages = [self.userDefaults objectForKey:@"groupImages"];
//            if (self.groupImages.count >0) {
                //NSDictionary *tempGroup = self.groups[indexPath.item];
                NSData *encodedObject =[self.userDefaults objectForKey:tempGroup[@"ProfilePic"]];
                if (encodedObject) {
                    NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
                    UIImage *img =  [UIImage imageWithData:imgData];
                    if ([tempGroup[@"Royal"]integerValue] == 1) {
                        cell.royalPP.image = img;
                    }else{
                        cell.groupPP.image = img;
                    }
//                }
              
            }
        }
        [cell.contentView setTransform:CGAffineTransformMakeScale(-1, 1)];
        self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;
       return cell;
    }else if (collectionView.tag == 1){
        HomeNewsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewsCell" forIndexPath:indexPath];
        NSDictionary *tempNews = self.news[indexPath.item];
        cell.newsSubject.text =tempNews[@"Subject"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempNews[@"Image"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.newsImage.image = image;
            });

        });
        cell.newsImage.image = nil;
        
        return cell;
    }
    
    return nil ;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 0) {
        self.selectedGroup = self.groups[indexPath.item];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
        NSLog(@"%@",self.selectedGroup);
        [self performSegueWithIdentifier:@"group" sender:self];
    }else if (collectionView.tag == 1){
        self.selectedNews = self.news[indexPath.item];
        NSLog(@"Seleected news %@",self.selectedNews);
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"news" sender:self];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    if (collectionView.tag == 0) {
//        return CGSizeMake(collectionView.frame.size.width/3,84);
//    }
//    return CGSizeMake(298, 142);
    
    if (collectionView.tag ==0 && indexPath.item ==1) {
        return CGSizeMake(145, 121);
    }else if(collectionView.tag == 0){
        return CGSizeMake(69, 84);
    }
    
    return CGSizeMake(298, 142);
}

#pragma mark - TableView DataSource 


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.events.count > 0) {
        return self.events.count + 1;
    }else{
        return 0;
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GroupCell";
    
    if (indexPath.row < self.events.count) {
        HomeEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[HomeEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *tempEvent = self.events[indexPath.row];
        cell.eventSubject.text =tempEvent[@"subject"];
        cell.eventCreator.text = tempEvent[@"CreatorName"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
        [formatter setLocale:qatarLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",tempEvent[@"TimeEnded"]]];
        NSString *date = [formatter stringFromDate:dateString];
        NSString *dateWithoutSeconds = [date substringToIndex:16];
        cell.eventDate.text = dateWithoutSeconds;
        NSLog(@"%@",date);
        //cell.eventDate.text = tempEvent[@"TimeEnded"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempEvent[@"EventPic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.eventImage.image = image;
            });
            
        });
        
        
        return cell ;
    }else if (indexPath.row == self.events.count){
        HomeEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[HomeEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

#pragma mark - Tableview delegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.eventsTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.events.count) {
        self.selectedEvent = self.events[indexPath.row];
        [self performSegueWithIdentifier:@"event" sender:self];
    }
 
}

#pragma mark - Segue 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"event"]) {
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }else if ([segue.identifier isEqualToString:@"group"]){
        GroupViewController *groupController = segue.destinationViewController;
        groupController.group = self.selectedGroup;
    }else if ([segue.identifier isEqualToString:@"news"]){
        NewsViewController *newsController = segue.destinationViewController;
        newsController.news = self.selectedNews;
    }else if ([segue.identifier isEqualToString:@"seeMore"]){
        AllSectionsViewController *allSectionsController=  segue.destinationViewController;
        allSectionsController.groupID = -1;
    }
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
    
    
    NSString *responseString = [request responseString];

    NSData *responseData = [request responseData];
    NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@",responseArray);
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getGroups"]) {
//        NSLog(@"Groupssss %@",self.groups);
        self.pullToRefreshFlag ++;
        if ([responseArray isEqualToArray:[self.userDefaults objectForKey:@"groups"]]) {
            //do nothing
        }else{
            self.offlineGroupsFlag = 0;
            self.groups = responseArray;
            [self.groupsCollectionView reloadData];
            [self.userDefaults setObject:self.groups forKey:@"groups"];
            [self.userDefaults synchronize];
        }
        
       // self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;
        
    }else if([key isEqualToString:@"getNews"]){
        self.news = responseArray;
        [self.newsCollectionView reloadData];
        self.pullToRefreshFlag ++;
    }else if ([key isEqualToString:@"getEvents"]){
        self.events = responseArray;
        [self.eventsTableView reloadData];
        self.pullToRefreshFlag ++;
        //reload
    }else if ([key isEqualToString:@"unReadInbox"]){
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.unReadMsgs = [dict[@"unReaded"]integerValue];
        [self.btnUnReadMsgs setHidden:NO];
        [self.btnUnReadMsgs setTitle:[NSString stringWithFormat:@"%ld",(long)self.unReadMsgs] forState:UIControlStateNormal];
        self.pullToRefreshFlag ++;
    }//    if ([self.responseArray isEqualToArray:[self.userDefaults objectForKey:@"groupArray"]]) {
//        //do nothing
//    }else{
//        [self.userDefaults setObject:self.responseArray forKey:@"groupArray"];
//        [self.userDefaults synchronize];
//        //[self.tableView reloadData];
//    }
    if (self.pullToRefreshFlag == 5) {
        [self.scrollView.pullToRefreshView stopAnimating];
        self.pullToRefreshFlag = 0;
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
    [self.scrollView.pullToRefreshView stopAnimating];
    self.pullToRefreshFlag = 0;

}


- (IBAction)btnSeeMorePressed:(id)sender {
    [self performSegueWithIdentifier:@"seeMore" sender:self];
}

- (IBAction)btnSupportPressed:(id)sender {
    [self performSegueWithIdentifier:@"support" sender:self];
}

- (IBAction)myProfileBtnPressed:(id)sender {
    if (self.segueFlag == 0) {
        [self performSegueWithIdentifier:@"profile" sender:self];
    }else if (self.segueFlag == 1){
        [self.userDefaults setInteger:0 forKey:@"Guest"];
        [self.userDefaults setInteger:0 forKey:@"signedIn"];
        [self.userDefaults setInteger:0 forKey:@"userID"];
        [self.userDefaults setInteger:0 forKey:@"Visitor"];
        [self performSegueWithIdentifier:@"welcomeSegue" sender:self];
        
    }else if (self.segueFlag == 2){
        [self performSegueWithIdentifier:@"activate" sender:self];
    }
}
@end
