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
#import "ASIDownloadCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "customEventCollectionViewCell.h"
#import "customGroupFooter.h"


@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//@property (nonatomic , strong) NSArray *responseArray;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic,strong) NSArray *groups;
@property (nonatomic,strong) NSMutableArray *mutableGroups;
@property (nonatomic,strong) NSArray *news;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSArray *firstSection;
@property (nonatomic,strong) NSArray *secondSection;
@property (nonatomic,strong) NSArray *thirdSection;
@property (nonatomic,strong) NSArray *fourthSection;
@property (nonatomic,strong) NSArray *fifthSection;
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
@property (nonatomic,strong) NSMutableArray *groupSections;
@property (nonatomic) NSInteger offlineGroupsFlag;
@property (nonatomic) NSInteger offlineNewsFlag;
@property (nonatomic) NSInteger newsFlag;
@property (nonatomic) BOOL offline;
@property (nonatomic) BOOL loadCache;
@property (nonatomic,strong) ASINetworkQueue *queue;

@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self viewDidLoadClone];
    self.offlineNewsFlag = 1;
    

    self.groupImages = [[NSMutableArray alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    [self.userDefaults synchronize];
    self.pullToRefreshFlag = 0;
    self.newsFlag = 0;
    self.offline = 0;
//    [self.btnUnReadMsgs setHidden:YES];
    
//    [self.groupsCollectionView registerClass:[cellGroupsCollectionView class] forCellWithReuseIdentifier:@"royal"];
//    [self.groupsCollectionView registerClass:[cellGroupsCollectionView class] forCellWithReuseIdentifier:@"Cell"];
//    [self.groupsCollectionView registerClass:[customGroupFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"adFooter"];
    
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.navigationBar.hidden = YES;
    
//    self.navigationItem.backBarButtonItem = nil;
//    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
//                                        nil] forState:UIControlStateNormal];
//    backbutton.tintColor = [UIColor whiteColor];
//    self.navigationItem.backBarButtonItem = backbutton;
    self.view.backgroundColor = [UIColor blackColor];

   //self.groupsCollectionView.collectionViewLayout = [[UICollectionViewRightAlignedLayout alloc] init];
    [self.groupsCollectionView setTransform:CGAffineTransformMakeScale(-1, 1)];
    [self.newsCollectionView setPagingEnabled:YES];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    
    if (internetStatus != NotReachable) {
        self.offline = false;
        self.loadCache = true;
        self.news = [self.userDefaults objectForKey:@"news"];
        [self.newsCollectionView reloadData];
        self.events = [self.userDefaults objectForKey:@"events"];
        [self.eventsTableView reloadData];
    }
    else {
        self.offline = true;
        self.loadCache = false;
        
        self.news = [self.userDefaults objectForKey:@"news"];
        [self.newsCollectionView reloadData];
        self.events = [self.userDefaults objectForKey:@"events"];
        [self.eventsTableView reloadData];
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
        //Not functional any more
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
        [self.btnInvitationsBuy setEnabled:NO];
        
        
//        self.eventsTableView.allowsSelection = NO;
        self.eventsTableView.userInteractionEnabled = NO ;
        self.newsCollectionView.allowsSelection = NO;
//        self.groupsCollectionView.allowsSelection = NO;

        
    }else{
        [self.btnBuyInvitations setEnabled:YES];
        //        [self.btnMyAccount setEnabled:NO];
        [self.btnMyMessages setEnabled:YES];
        [self.btnSearch setEnabled:YES];
        [self.btnSupport setEnabled:YES];
        [self.btnInvitationsBuy setEnabled:YES];
        self.segueFlag = 0;
        [self.myProfileLabel setText:@"حسابي"];
        
//        self.eventsTableView.allowsSelection = YES;
        self.eventsTableView.userInteractionEnabled = YES;
        self.newsCollectionView.allowsSelection = YES;
        self.groupsCollectionView.allowsSelection = YES;
    }
    
    
    
    NSArray *groups = [self.userDefaults objectForKey:@"groups"];

    if (groups != nil) {
//        self.offlineGroupsFlag = 1 ;
        self.groups = groups;
    
        self.firstSection= [self.groups subarrayWithRange:NSMakeRange(0, 19)];
        self.secondSection =[self.groups subarrayWithRange:NSMakeRange(19, 20)];
        self.thirdSection = [self.groups subarrayWithRange:NSMakeRange(39, 20)];
         self.fourthSection = [self.groups subarrayWithRange:NSMakeRange(59, 20)];
         self.fifthSection = [self.groups subarrayWithRange:NSMakeRange(76,self.groups.count - 76)];
        self.groupSections = [[NSMutableArray alloc]init];
        [self.groupSections addObject:self.fifthSection];[self.groupSections addObject:self.secondSection];[self.groupSections addObject:self.thirdSection];[self.groupSections addObject:self.fourthSection];[self.groupSections addObject:self.fifthSection];
//
//        
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
                                            @"limit":[NSString stringWithFormat:@"%d",4]}]};
    NSMutableDictionary *getNewsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getNews",@"key", nil];
    
    NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":@"-1",
                                                                             @"catID":@"-1",
                                                                             @"start":@"0",@"limit":@"4"}]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    
    NSDictionary *getUnReadInbox = @{@"FunctionName":@"unReadInbox" , @"inputs":@[@{@"ReciverID":[NSString stringWithFormat:@"%ld",self.userID],
                                                                                    //                                                                             @"catID":@"-1",
                                                                                    //                                                                             @"start":@"0",@"limit":@"3"
                                                                                    }]};
    NSMutableDictionary *getUnReadInboxTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"unReadInbox",@"key", nil];
    
//    NSArray *mutableGroups = [self.userDefaults objectForKey:@"mutableGroups"];
//    if (mutableGroups != nil) {
//        //        self.offlineGroupsFlag = 1 ;
//        self.mutableGroups = mutableGroups;
//        [self.groupsCollectionView reloadData];
//    }else{
//        [self postRequest:getGroups withTag:getGroupsTag];
//    }
    
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        self.offline = false;
        [self postRequest:getGroups withTag:getGroupsTag];
        [self postRequest:getNews withTag:getNewsTag];
        [self postRequest:getEvents withTag:getEventsTag];
        [self postRequest:getUnReadInbox withTag:getUnReadInboxTag];
    }
    else {
        self.offline = true;

    }

    self.scrollView.showsPullToRefresh;
    
    [self.scrollView addPullToRefreshWithActionHandler:^{
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            self.offline = false;
            [self downloadNewsImages];
            [self postRequest:getGroups withTag:getGroupsTag];
            [self postRequest:getNews withTag:getNewsTag];
            [self postRequest:getEvents withTag:getEventsTag];
            [self postRequest:getUnReadInbox withTag:getUnReadInboxTag];
        }
        else {
            self.offline = true;
            [self.scrollView.pullToRefreshView stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        self.newsFlag = 0 ;

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

//-(void)clearProfileCaching{
//
//    SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:@"profile"];
//    [imageCache clearMemory];
//    [imageCache clearDisk];
//}

#pragma mark - Collection View methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (collectionView.tag == 0) {
        return 5;
    }else{
        return 1;
    }
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 0 && self.groups.count > 0) {
        switch (section) {
            case 0:
            {
                return self.firstSection.count;
                break;
            }
            case 1:
            {
                return self.secondSection.count;
                break;
            }
            case 2:
            {
                return self.thirdSection.count;
                break;
            }
            case 3:
            {
                return self.fourthSection.count;
                break;
            }
            case 4:
            {
                return self.fifthSection.count;
                break;
            }
            default:
                return 0;
                break;
        }
    }else if (collectionView.tag == 1){
        return self.news.count;
    }else if (collectionView.tag == 2){
        return self.events.count;
    }else {
        return 0;
    }
}

- (CGSize)collectionView:(customGroupFooter *)collectionView layout:(customGroupFooter*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
  return CGSizeMake((self.groupsCollectionView.bounds.size.width), 200);
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

     cellGroupsCollectionView *cell = [[cellGroupsCollectionView alloc]init];
    
    if (collectionView.tag == 0 ) {
        NSDictionary *tempGroup = [[NSDictionary alloc]init];
        //self.groups[indexPath.item];
        switch (indexPath.section) {
            case 0:{
                tempGroup = self.firstSection[indexPath.row];
                
                if (indexPath.item == 1  ) {
                    for (int i = 0 ; i < self.groups.count; i++) {
                        tempGroup = self.groups[i];
                        if ([tempGroup[@"Royal"]integerValue] == 1) {
                            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"royal" forIndexPath:indexPath];
                            break;
                        }
                    }
                }
                else {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
                }
                break;
            }
                
            case 1:{
                
                tempGroup = self.secondSection[indexPath.row];
//                tempGroup = tempArray[indexPath.row];
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
                
                break;
            }
                
            case 2:{
                
               tempGroup = self.thirdSection[indexPath.row];
//                tempGroup = tempArray[indexPath.row];
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
                break;
            }
                
            case 3:{
                tempGroup = self.fourthSection[indexPath.row];
//                tempGroup = tempArray[indexPath.row];
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
                break;
            }
                
            case 4:{
//                if (indexPath.item + 79 < self.groups.count) {
                    tempGroup = self.fifthSection[indexPath.row];
//                    tempGroup = tempArray[indexPath.row];
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//                }
              
                break;
            }
                
            default:
                break;
        }
        

        if ([tempGroup[@"Royal"]integerValue] == 1) {
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempGroup[@"ProfilePic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell.royalPP sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                //spinner.center = cell.royalPP.center;
                //spinner.hidesWhenStopped = YES;
                //[cell addSubview:spinner];
                //[spinner startAnimating];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                cell.royalPP.image = image;
//                [spinner stopAnimating];
            }];
            
        }else{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",tempGroup[@"ProfilePic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell.groupPP sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                spinner.center = cell.groupPP.center;
//                spinner.hidesWhenStopped = YES;
//                [cell addSubview:spinner];
//                [spinner startAnimating];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                cell.groupPP.image = image;
//                [spinner stopAnimating];
            }];
            
        }
//        NSData *encodedObject =[self.userDefaults objectForKey:tempGroup[@"ProfilePic"]];
//
//        NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
//        
//        if (imgData != nil) {
//            UIImage *img =  [UIImage imageWithData:imgData];
//            if ([tempGroup[@"Royal"]integerValue] == 1) {
//                cell.royalPP.image = img;
//            }else{
//                cell.groupPP.image = img;
//            }
//        }else{
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempGroup[@"ProfilePic"]];
////                NSLog(@"%@",imgURLString);
//                NSURL *imgURL = [NSURL URLWithString:imgURLString];
//                NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
//                UIImage *image = [[UIImage alloc]initWithData:imgData];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if ([tempGroup[@"Royal"]integerValue] == 1) {
//                        cell.royalPP.image = image;
//                    }else{
//                        cell.groupPP.image = image;
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
//        }
        
        
        [cell.contentView setTransform:CGAffineTransformMakeScale(-1, 1)];
        self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;
       return cell;
    }
//    else if (collectionView.tag == 0) {
//        cellGroupsCollectionView *cell = [[cellGroupsCollectionView alloc]init];
//        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"adSpace" forIndexPath:indexPath];
//        self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;
//        return cell;
//        
//    }
    else if (collectionView.tag == 1){
        
    
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
            
        }else if (self.offlineNewsFlag == 1 || self.offline == true || self.loadCache == true){
            
            NSData *encodedObject =[self.userDefaults objectForKey:tempNews[@"Image"]];
            if (encodedObject) {
                NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
                UIImage *img =  [UIImage imageWithData:imgData];
                cell.newsImage.image = img;
                
            }
        }

        
        return cell;
    }else if (collectionView.tag == 2){
        
        customEventCollectionViewCell *cell = (customEventCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
        
        NSDictionary *tempEvent = self.events[indexPath.row];
        
        cell.eventName.text =tempEvent[@"subject"];
        cell.eventCreator.text = tempEvent[@"CreatorName"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
        [formatter setLocale:qatarLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",tempEvent[@"TimeEnded"]]];
        NSString *date = [formatter stringFromDate:dateString];
        NSString *dateWithoutSeconds = [date substringToIndex:16];
        cell.eventDate.text = [dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        //Likes w Comments hena
        cell.eventPic.layer.masksToBounds = YES;
        cell.eventPic.layer.cornerRadius = cell.eventPic.bounds.size.width/2;

            if (self.offline == false) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
                    NSURL *imgURL = [NSURL URLWithString:imgURLString];
                    NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
                    UIImage *image = [[UIImage alloc]initWithData:imgData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.eventPic.image = image;
                        NSData *imageData = UIImagePNGRepresentation(image);
                        NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                        [self.userDefaults setObject:encodedDate forKey:[NSString stringWithFormat:@"Event%@",tempEvent[@"EventPic"]]];
                        [self.userDefaults synchronize];
                    });
                    
                });
                
            }else if (self.offline == true || self.loadCache == true){
                NSData *encodedObject =[self.userDefaults objectForKey:[NSString stringWithFormat:@"Event%@",tempEvent[@"EventPic"]]];
                if (encodedObject) {
                    NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
                    UIImage *img =  [UIImage imageWithData:imgData];
                    cell.eventPic.image = img;
                    
                }
            }
            
            return cell ;
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
                
            });
        });
        [self.newsCollectionView reloadData];
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind== UICollectionElementKindSectionFooter) {
        customGroupFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"adFooter" forIndexPath:indexPath];
        self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;
        [footer.adView setTransform:CGAffineTransformMakeScale(-1, 1)];
    
        reusableview = footer;
    }
    return reusableview;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 0) {
        self.selectedGroup = self.groups[indexPath.item];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"group" sender:self];
    }else if (collectionView.tag == 1){
        self.selectedNews = self.news[indexPath.item];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"news" sender:self];
    }else if (collectionView.tag == 2){
        self.selectedEvent = self.events[indexPath.item];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"event" sender:self];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if (collectionView.tag == 0) {
        if (collectionView.tag ==0 && indexPath.item ==1 && indexPath.section == 0 && ![[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]) {
            return CGSizeMake(137.5, 121);
        }else if(collectionView.tag == 0 && indexPath.row ==1 && indexPath.section == 0 && [[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]){
            return CGSizeMake(200, 121);
        }else if(collectionView.tag == 0 && ![[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]){
            //return CGSizeMake(69, 84);
            return CGSizeMake((self.groupsCollectionView.bounds.size.width - 15)/4, 84);
        }else if(collectionView.tag == 0 && [[self platformType:platform] isEqualToString:@"iPhone 6 Plus"]){
            return CGSizeMake(70, 84);
        }
    }
//    else if (collectionView.tag == 0){
//        return CGSizeMake(self.groupsCollectionView.bounds.size.width, 100);
//    }
    else if (collectionView.tag == 2){
        return CGSizeMake((self.eventCollectionView.bounds.size.width - 5)/2, 210);
    }
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 27, 142);
}
//iPhone 6 Plus
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {

    return 5 ;
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
//    NSLog(@"%@",responseArray);
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    if ([key isEqualToString:@"getGroups"]) {
        self.pullToRefreshFlag ++;
        self.groups = responseArray;
        if ([self arraysContainSameObjects:responseArray andOtherArray:[self.userDefaults objectForKey:@"groups"]]) {
            
        }else{

            [self.userDefaults setObject:self.groups forKey:@"groups"];
            
            self.firstSection= [self.groups subarrayWithRange:NSMakeRange(0, 19)];
            self.secondSection =[self.groups subarrayWithRange:NSMakeRange(19, 20)];
            self.thirdSection = [self.groups subarrayWithRange:NSMakeRange(39, 20)];
            self.fourthSection = [self.groups subarrayWithRange:NSMakeRange(59, 20)];
            self.fifthSection = [self.groups subarrayWithRange:NSMakeRange(76,self.groups.count - 76)];
            
            self.groupSections = [[NSMutableArray alloc]init];
            [self.groupSections addObject:self.fifthSection];[self.groupSections addObject:self.secondSection];[self.groupSections addObject:self.thirdSection];[self.groupSections addObject:self.fourthSection];[self.groupSections addObject:self.fifthSection];

            [self.userDefaults synchronize];
            [self.groupsCollectionView reloadData];

        }


        
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
        [self.userDefaults setObject:self.events forKey:@"events"];
        [self.userDefaults synchronize];
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
//    NSLog(@"%@",error);
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
