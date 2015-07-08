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
@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//@property (nonatomic , strong) NSArray *responseArray;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *groups;
@property (nonatomic,strong) NSArray *news;
@property (nonatomic,strong) NSArray *events;


@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
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
    
    self.imageArray = @[[UIImage imageNamed:@"3emadi.png"],[UIImage imageNamed:@"3etebi.png"],[UIImage imageNamed:@"elka3bi.png"],[UIImage imageNamed:@"elna3emi.png"],[UIImage imageNamed:@"eltamimi.png"],[UIImage imageNamed:@"ka7tani.png"],[UIImage imageNamed:@"kbesi.png"],[UIImage imageNamed:@"mare5i.png"],[UIImage imageNamed:@"eldosri.png"],[UIImage imageNamed:@"elhawager.png"],[UIImage imageNamed:@"elmra.png"],[UIImage imageNamed:@"elmasnad.png"]];
    
    NSDictionary *getGroups = @{
                               @"FunctionName":@"getGroupList" ,
                               @"inputs":@[@{@"limit":[NSNumber numberWithInt:3]}]};
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
        return self.imageArray.count;
    }else{
        return self.news.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *cellIdentifier = @"Cell";
    
    if (collectionView.tag == 0) {
        cellGroupsCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        cell.groupPP.image = self.imageArray[indexPath.row];
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

#pragma mark - TableView DataSource 


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.events.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GroupCell";
    
    HomeEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[HomeEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *tempEvent = self.events[indexPath.item];
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
        //reload
    }else if([key isEqualToString:@"getNews"]){
        self.news = responseArray;
        [self.newsCollectionView reloadData];
    }else if ([key isEqualToString:@"getEvents"]){
        self.events = responseArray;
        [self.eventsTableView reloadData];
        //reload
    }
//    if ([self.responseArray isEqualToArray:[self.userDefaults objectForKey:@"groupArray"]]) {
//        //do nothing
//    }else{
//        [self.userDefaults setObject:self.responseArray forKey:@"groupArray"];
//        [self.userDefaults synchronize];
//        //[self.tableView reloadData];
//    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}


@end
