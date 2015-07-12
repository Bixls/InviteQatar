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


@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.pullToRefreshFlag = 0;
    
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

    [self postRequest:getGroups withTag:getGroupsTag];
    [self postRequest:getNews withTag:getNewsTag];
    [self postRequest:getEvents withTag:getEventsTag];
    
    self.scrollView.showsPullToRefresh;
    [self.scrollView addPullToRefreshWithActionHandler:^{
        [self postRequest:getGroups withTag:getGroupsTag];
        [self postRequest:getNews withTag:getNewsTag];
        [self postRequest:getEvents withTag:getEventsTag];
    }];
    
}

-(void)viewDidAppear:(BOOL)animated {
    if ([self.userDefaults integerForKey:@"signedIn"] == 0 && [self.userDefaults integerForKey:@"Guest"]==0) {
        [self performSegueWithIdentifier:@"welcomeSegue" sender:self];
    }
    if ([self.userDefaults integerForKey:@"Guest"]==1) {
        [self.btnBuyInvitations setEnabled:NO];
        //        [self.btnMyAccount setEnabled:NO];
        [self.btnMyMessages setEnabled:NO];
        [self.btnSearch setEnabled:NO];
        [self.btnSupport setEnabled:NO];
    }else{
        [self.btnBuyInvitations setEnabled:YES];
        //        [self.btnMyAccount setEnabled:NO];
        [self.btnMyMessages setEnabled:YES];
        [self.btnSearch setEnabled:YES];
        [self.btnSupport setEnabled:YES];
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
    
    if (collectionView.tag == 0) {
        cellGroupsCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        NSLog(@"%ld",indexPath.item);
        NSDictionary *tempGroup = self.groups[indexPath.item];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempGroup[@"ProfilePic"]];
            NSLog(@"%@",imgURLString);
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.groupPP.image = image;
                
            });
        });
       return cell;
    }else{
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
        NSDictionary *tempEvent = self.events[indexPath.row];
        cell.eventSubject.text =tempEvent[@"subject"];
        cell.eventCreator.text = tempEvent[@"CreatorName"];
        cell.eventDate.text = tempEvent[@"TimeEnded"];
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
        self.groups = responseArray;
        NSLog(@"Groupssss %@",self.groups);
        self.pullToRefreshFlag ++;
        [self.groupsCollectionView reloadData];
    }else if([key isEqualToString:@"getNews"]){
        self.news = responseArray;
        [self.newsCollectionView reloadData];
        self.pullToRefreshFlag ++;
    }else if ([key isEqualToString:@"getEvents"]){
        self.events = responseArray;
        [self.eventsTableView reloadData];
        self.pullToRefreshFlag ++;
        //reload
    }
//    if ([self.responseArray isEqualToArray:[self.userDefaults objectForKey:@"groupArray"]]) {
//        //do nothing
//    }else{
//        [self.userDefaults setObject:self.responseArray forKey:@"groupArray"];
//        [self.userDefaults synchronize];
//        //[self.tableView reloadData];
//    }
    if (self.pullToRefreshFlag == 3) {
        [self.scrollView.pullToRefreshView stopAnimating];
    
        self.pullToRefreshFlag = 0;
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}


- (IBAction)btnSeeMorePressed:(id)sender {
    [self performSegueWithIdentifier:@"seeMore" sender:self];
}

- (IBAction)btnSupportPressed:(id)sender {
    [self performSegueWithIdentifier:@"support" sender:self];
}
@end
