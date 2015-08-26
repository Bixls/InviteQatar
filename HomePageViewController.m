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
#import <sys/sysctl.h>
#import "Reachability.h"
@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//@property (nonatomic , strong) NSArray *responseArray;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *groups;  
@property (nonatomic,strong) NSArray *news;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSMutableArray *newsCollectionViewConstraints;
@property (nonatomic,strong) NSMutableArray *eventsTableViewConstaints;
@property (nonatomic,strong) NSMutableArray *lblLatestEventsConstraints;
@property (nonatomic,strong) NSMutableArray *groupsCollectionViewConstraints;
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
@property (nonatomic) NSInteger offlineNewsFlag;
@property (nonatomic) NSInteger newsFlag;
@property (nonatomic) NSInteger offline;
@property (nonatomic,strong) ASINetworkQueue *queue;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self viewDidLoadClone];
    //self.offlineNewsFlag = 1;
    self.newsCollectionViewConstraints = [[NSMutableArray alloc]init];
    self.lblLatestEventsConstraints = [[NSMutableArray alloc]init];
    self.eventsTableViewConstaints = [[NSMutableArray alloc]init];
    self.groupsCollectionViewConstraints = [[NSMutableArray alloc]init];
    self.groupImages = [[NSMutableArray alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    [self.userDefaults synchronize];
    self.pullToRefreshFlag = 0;
    self.newsFlag = 0;
    self.offline = 0;
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
    [self.newsCollectionView setPagingEnabled:YES];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
      //  self.offline = 0;
    }
    else {
        //there-is-no-connection warning
        //self.offline = 1;
        self.newsCollectionViewConstraints = [NSMutableArray new];
        
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.newsCollectionView || con.secondItem == self.newsCollectionView) {
                [self.newsCollectionViewConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.btnInvitationNum.constraints) {
            if (con.firstItem == self.newsCollectionView || con.secondItem == self.newsCollectionView) {
                [self.newsCollectionViewConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.lblLatestEvents.constraints) {
            if (con.firstItem == self.newsCollectionView || con.secondItem == self.newsCollectionView) {
                [self.newsCollectionViewConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.newsCollectionView.constraints) {
            if (con.firstItem == self.newsCollectionView || con.secondItem == self.newsCollectionView) {
                [self.newsCollectionViewConstraints addObject:con];
            }
        }
        
        // Events
        
        self.eventsTableViewConstaints = [NSMutableArray new];
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.eventsTableView || con.secondItem == self.eventsTableView) {
                [self.eventsTableViewConstaints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.lblLatestEvents.constraints) {
            if (con.firstItem == self.eventsTableView || con.secondItem == self.eventsTableView) {
                [self.eventsTableViewConstaints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.eventsTableView.constraints) {
            if (con.firstItem == self.eventsTableView || con.secondItem == self.eventsTableView) {
                [self.eventsTableViewConstaints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.groupsCollectionView.constraints) {
            if (con.firstItem == self.eventsTableView || con.secondItem == self.eventsTableView) {
                [self.eventsTableViewConstaints addObject:con];
            }
        }
        
        
        //Label
        
        self.lblLatestEventsConstraints = [NSMutableArray new];
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.lblLatestEvents || con.secondItem == self.lblLatestEvents) {
                [self.lblLatestEventsConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.lblLatestEvents.constraints) {
            if (con.firstItem == self.lblLatestEvents || con.secondItem == self.lblLatestEvents) {
                [self.lblLatestEventsConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.newsCollectionView.constraints) {
            if (con.firstItem == self.lblLatestEvents || con.secondItem == self.lblLatestEvents) {
                [self.lblLatestEventsConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.eventsTableView.constraints) {
            if (con.firstItem == self.lblLatestEvents || con.secondItem == self.lblLatestEvents) {
                [self.lblLatestEventsConstraints addObject:con];
            }
        }
        
        
        
        self.groupsCollectionViewConstraints = [NSMutableArray new];
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.groupsCollectionView || con.secondItem == self.groupsCollectionView) {
                [self.groupsCollectionViewConstraints addObject:con];
            }
        }

        for (NSLayoutConstraint *con in self.groupsCollectionView.constraints) {
            if (con.firstItem == self.groupsCollectionView || con.secondItem == self.groupsCollectionView) {
                [self.groupsCollectionViewConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.btnInvitationsBuy.constraints) {
            if (con.firstItem == self.groupsCollectionView || con.secondItem == self.groupsCollectionView) {
                [self.groupsCollectionViewConstraints addObject:con];
            }
        }
        for (NSLayoutConstraint *con in self.eventsTableView.constraints) {
            if (con.firstItem == self.groupsCollectionView || con.secondItem == self.groupsCollectionView) {
                [self.groupsCollectionViewConstraints addObject:con];
            }
        }
        
        
        [self.newsCollectionView removeFromSuperview];
        [self.eventsTableView removeFromSuperview];
        [self.lblLatestEvents removeFromSuperview];

   
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }


}

-(void)viewDidLoadClone{
    [super viewDidLoad];
    
    self.offlineNewsFlag = 1;
    self.newsCollectionViewConstraints = [[NSMutableArray alloc]init];
    self.lblLatestEventsConstraints = [[NSMutableArray alloc]init];
    self.eventsTableViewConstaints = [[NSMutableArray alloc]init];
    self.groupImages = [[NSMutableArray alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    [self.userDefaults synchronize];
    self.pullToRefreshFlag = 0;
    self.newsFlag = 0;
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
    [self.newsCollectionView setPagingEnabled:YES];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        
    }
    else {
        //there-is-no-connection warning
        
        self.newsCollectionViewConstraints = [NSMutableArray new];
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.newsCollectionView || con.secondItem == self.newsCollectionView) {
                [self.newsCollectionViewConstraints addObject:con];
            }
        }
        
        self.eventsTableViewConstaints = [NSMutableArray new];
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.eventsTableView || con.secondItem == self.eventsTableView) {
                [self.eventsTableViewConstaints addObject:con];
            }
        }
        
        self.lblLatestEventsConstraints = [NSMutableArray new];
        for (NSLayoutConstraint *con in self.myView.constraints) {
            if (con.firstItem == self.lblLatestEvents || con.secondItem == self.lblLatestEvents) {
                [self.lblLatestEventsConstraints addObject:con];
            }
        }
        
        
        [self.newsCollectionView removeFromSuperview];
        [self.eventsTableView removeFromSuperview];
        [self.lblLatestEvents removeFromSuperview];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }

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
//        self.offlineGroupsFlag = 1 ;
        self.groups = groups;
        [self.groupsCollectionView reloadData];
    }
//
    
//    NSArray *news = [self.userDefaults objectForKey:@"news"];
//
//    if (news != nil) {
//        //self.offlineNewsFlag = 1 ;
//        self.news = news;
//        [self.newsCollectionView reloadData];
//    }
    
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
    
    //        [self.newsCollectionView addConstraints:self.newsCollectionViewConstraints];
    //        [self.view addSubview:self.newsCollectionView];
    //        [self.lblLatestEvents addConstraints:self.lblLatestEventsConstraints];
    //        [self.view addSubview:self.lblLatestEvents];
    //        [self.eventsTableView addConstraints:self.eventsTableViewConstaints];
    //        [self.view addSubview:self.eventsTableView];
    
    
    self.scrollView.showsPullToRefresh;
    [self.scrollView addPullToRefreshWithActionHandler:^{
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            [self.groupsCollectionView removeFromSuperview];
            
            [self.newsCollectionView addConstraints:self.newsCollectionViewConstraints];
            [self.myView addSubview:self.newsCollectionView];
            [self.newsCollectionView setNeedsDisplay];
            
            [self.lblLatestEvents addConstraints:self.lblLatestEventsConstraints];
            [self.myView addSubview:self.lblLatestEvents];
            [self.lblLatestEvents setNeedsDisplay];
            
            [self.eventsTableView addConstraints:self.eventsTableViewConstaints];
            [self.myView addSubview:self.eventsTableView];
            [self.eventsTableView setNeedsDisplay];
//
            
            
//            [self.groupsCollectionView addConstraints:self.groupsCollectionViewConstraints];
//            [self.myView addSubview:self.groupsCollectionView];
//            [self.groupsCollectionView setNeedsDisplay];
            

            
            
            //[self viewDidLoadClone];
//            [self viewDidLoad];
//            [self viewWillAppear:YES];
//            [self viewDidAppear:YES];
//            [self.view setNeedsDisplay];
//            [self.myView setNeedsDisplay];
        }
        else {
            //there-is-no-connection warning
            self.offline = 1;
            [self.newsCollectionView removeFromSuperview];
            [self.eventsTableView removeFromSuperview];
            [self.lblLatestEvents removeFromSuperview];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        self.newsFlag = 0 ;
        [self downloadNewsImages];
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
        
        NSData *encodedObject =[self.userDefaults objectForKey:tempGroup[@"ProfilePic"]];
        NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        
        if (imgData != nil) {
            UIImage *img =  [UIImage imageWithData:imgData];
            if ([tempGroup[@"Royal"]integerValue] == 1) {
                cell.royalPP.image = img;
            }else{
                cell.groupPP.image = img;
            }
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempGroup[@"ProfilePic"]];
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
                    if (encodedDate != nil) {
                        [self.userDefaults setObject:encodedDate forKey:tempGroup[@"ProfilePic"]];
                        [self.userDefaults synchronize];
                    }
                    
                });
            });

        }
        
            
        
//        if (self.offlineGroupsFlag ==0) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempGroup[@"ProfilePic"]];
//                NSLog(@"%@",imgURLString);
//                NSURL *imgURL = [NSURL URLWithString:imgURLString];
//                NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
//                UIImage *image = [[UIImage alloc]initWithData:imgData];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([tempGroup[@"Royal"]integerValue] == 1) {
//                        cell.royalPP.image = image;
//                    }else{
//                         cell.groupPP.image = image;
//                    }
//                    NSData *imageData = UIImagePNGRepresentation(image);
//                    NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
//                    if (encodedDate != nil) {
//                        [self.userDefaults setObject:encodedDate forKey:tempGroup[@"ProfilePic"]];
//                        [self.userDefaults synchronize];
//                    }
//                    
//                });
//            });
//
//        }else if (self.offlineGroupsFlag == 1){
//
//            NSData *encodedObject =[self.userDefaults objectForKey:tempGroup[@"ProfilePic"]];
//            if (encodedObject) {
//                NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
//                UIImage *img =  [UIImage imageWithData:imgData];
//                if ([tempGroup[@"Royal"]integerValue] == 1) {
//                    cell.royalPP.image = img;
//                }else{
//                    cell.groupPP.image = img;
//                }
//                
//            }
//        }
        [cell.contentView setTransform:CGAffineTransformMakeScale(-1, 1)];
        self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;
       return cell;
    }else if (collectionView.tag == 1){
        
       // NSString * kCellReuseIdentifier = [NSString stringWithFormat:@"collectionViewCell%ld",(long)indexPath.row];
        HomeNewsCollectionViewCell *cell = (HomeNewsCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"NewsCell" forIndexPath:indexPath];
        
        NSDictionary *tempNews = self.news[indexPath.item];
        cell.newsSubject.text =tempNews[@"Subject"];
        if (self.offlineNewsFlag ==0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempNews[@"Image"]];
//                NSLog(@"%@",imgURLString);
                NSURL *imgURL = [NSURL URLWithString:imgURLString];
                NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [[UIImage alloc]initWithData:imgData];
                    cell.newsImage.image = image;
                    NSData *imageData = UIImagePNGRepresentation(image);
                    NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                    [self.userDefaults setObject:encodedDate forKey:tempNews[@"Image"]];
                    [self.userDefaults synchronize];
                    self.newsFlag++;
                    if (self.newsFlag == 3) {
                        self.offlineNewsFlag = 1 ;
                    }
                });
            });
            
        }else if (self.offlineNewsFlag == 1){
            
            NSData *encodedObject =[self.userDefaults objectForKey:tempNews[@"Image"]];
            if (encodedObject) {
                NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
                UIImage *img =  [UIImage imageWithData:imgData];
                cell.newsImage.image = img;
                
            }
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempNews[@"Image"]];
//            NSURL *imgURL = [NSURL URLWithString:imgURLString];
//            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
//            UIImage *image = [[UIImage alloc]initWithData:imgData];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.newsImage.image = image;
//            });
//
//        });

        
        return cell;
    }
    
    return nil ;
}

-(void)downloadNewsImages {
    
    for (int i = 0; i < self.news.count; i++) {
        NSDictionary *tempNews = self.news[i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempNews[@"Image"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *imageData = UIImagePNGRepresentation(image);
                NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                [self.userDefaults setObject:encodedDate forKey:tempNews[@"Image"]];
                [self.userDefaults synchronize];
                //self.newsFlag++;
//                if (self.newsFlag == 0) {
//                    self.offlineNewsFlag = 1 ;
//                }
            });
        });
        [self.newsCollectionView reloadData];
    }
    
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
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    if (collectionView.tag ==0 && indexPath.item ==1 && ![[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]) {
        return CGSizeMake(145, 121);
    }else if(collectionView.tag == 0 && indexPath.row ==1 && [[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]){
        //return CGSizeMake(145 * 2, 121);
        return CGSizeMake(200, 121);
    }else if(collectionView.tag == 0 && ![[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]){
        return CGSizeMake(69, 84);
    }else if(collectionView.tag == 0 && [[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]){
        return CGSizeMake(70, 84);
    }
    
    
    NSLog(@"%@",[self platformType:platform]);
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 27, 142);
}

- (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
//298
//
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
        cell.eventDate.text = [dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        
        NSLog(@"%@",date);
        //cell.eventDate.text = tempEvent[@"TimeEnded"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.eventImage.image = image;
            });
            
        });
        
        self.tableVerticalLayoutConstraint.constant = self.eventsTableView.contentSize.height;
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
    
    if (![self queue]) {
        [self setQueue:[[ASINetworkQueue alloc]init]];
        self.queue.delegate = self;
        [self.queue setQueueDidFinishSelector:@selector(queueDidFinishSelector)];
    }
    
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
    //[request startAsynchronous];
    [self.queue addOperation:request];
    [self.queue go];
    //[request startAsynchronous];
    

}

-(void)queueDidFinishSelector {
   [self.scrollView.pullToRefreshView stopAnimating];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    
    NSString *responseString = [request responseString];

    NSData *responseData = [request responseData];
    NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@",responseArray);
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getGroups"]) {
        self.pullToRefreshFlag ++;
        
        if ([self arraysContainSameObjects:responseArray andOtherArray:[self.userDefaults objectForKey:@"groups"]]) {
            //do nothing
            NSLog(@"THEY ARE EQUAL");
//            self.offlineGroupsFlag = 0;
//            [self.userDefaults setObject:self.groups forKey:@"groups"];
//            [self.userDefaults synchronize];
//            [self.groupsCollectionView reloadData];
//            self.groups = responseArray;
//            [self.userDefaults setObject:self.groups forKey:@"groups"];
//            [self.userDefaults synchronize];
//            [self.groupsCollectionView reloadData];
//            self.offlineGroupsFlag = 0;
//            self.groups = responseArray;
//            [self.groupsCollectionView reloadData];

        }else{
//            self.offlineGroupsFlag = 0;
            self.groups = responseArray;
            [self.userDefaults setObject:self.groups forKey:@"groups"];
            [self.userDefaults synchronize];
            [self.groupsCollectionView reloadData];

        }
//        if ([responseArray isEqualToArray:[self.userDefaults objectForKey:@"groups"]]) {
//            //do nothing
//            //[self.groupsCollectionView reloadData];
////            [self.userDefaults setObject:self.groups forKey:@"groups"];
////            [self.userDefaults synchronize];
////            [self.groupsCollectionView reloadData];
//        }else{
//            self.offlineGroupsFlag = 0;
//            self.groups = responseArray;
//            [self.groupsCollectionView reloadData];
//            [self.userDefaults setObject:self.groups forKey:@"groups"];
//            [self.userDefaults synchronize];
//        }
        
    }else if([key isEqualToString:@"getNews"]){
        
        self.pullToRefreshFlag ++;
        //self.offlineNewsFlag = 0;
        self.news = responseArray;
       // [self.newsCollectionView reloadData];
        [self downloadNewsImages];
        [self.userDefaults setObject:self.news forKey:@"news"];
        [self.userDefaults synchronize];

    }else if ([key isEqualToString:@"getEvents"]){
        self.events = responseArray;
        [self.eventsTableView reloadData];
        self.pullToRefreshFlag ++;

    }else if ([key isEqualToString:@"unReadInbox"]){
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.unReadMsgs = [dict[@"unReaded"]integerValue];
        [self.btnUnReadMsgs setHidden:NO];
        [self.btnUnReadMsgs setTitle:[NSString stringWithFormat:@"%ld",(long)self.unReadMsgs] forState:UIControlStateNormal];
        self.pullToRefreshFlag ++;
    }
    


}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

#pragma mark - Compare Method 

- (BOOL)arraysContainSameObjects:(NSArray *)array1 andOtherArray:(NSArray *)array2 {
    // quit if array count is different
    if ([array1 count] != [array2 count]) return NO;
    
    BOOL bothArraysContainTheSameObjects = YES;
    for (NSDictionary *objectInArray1 in array1) {
        BOOL objectFoundInArray2 = NO;
        for (NSDictionary *objectInArray2 in array2) {
            if ([objectInArray1 isEqualToDictionary:objectInArray2]) {
                objectFoundInArray2 = YES;
                break;
            }
        }
        if (!objectFoundInArray2) {
            bothArraysContainTheSameObjects = NO;
            break;
        }
    }
    
    return bothArraysContainTheSameObjects;
}

#pragma mark - Buttons

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
