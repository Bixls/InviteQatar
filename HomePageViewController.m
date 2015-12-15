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
#import "SpecialEventsViewController.h"
#import "WelcomePageViewController.h"
#import "AppDelegate.h"

@interface HomePageViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventCollectionViewConstraint;

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
@property (nonatomic)BOOL reloadFlag;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic) NSInteger segueFlag;
@property (nonatomic,strong) NSMutableArray *groupImages;
@property (nonatomic,strong) NSMutableArray *groupSections;
@property (nonatomic,strong) NSMutableArray *sectionsToHide;
@property (nonatomic) NSInteger offlineGroupsFlag;
@property (nonatomic) NSInteger offlineNewsFlag;
@property (nonatomic) NSInteger newsFlag;
@property (nonatomic) NSInteger selectedSpecialEventType;
@property (nonatomic) BOOL offline;
@property (nonatomic) BOOL loadCache;
@property (nonatomic,strong) ASINetworkQueue *queue;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NetworkConnection *adsConnection;
@property (nonatomic,strong) NSMutableArray *footerAds;
@property (nonatomic,strong) NSArray *allAds;
@property (nonatomic) NSInteger counter;
@property (nonatomic,strong) NetworkConnection *footerImgConnection;
@property (nonatomic,strong) NSMutableDictionary *sectionAds;
@property (nonatomic,strong) NSMutableDictionary *sectionGroups;
@property (nonatomic) NSInteger footerContentHeight;
@property (nonatomic) BOOL enableReloading;
@property (weak, nonatomic) IBOutlet UIView *msgsNotificationView;
@property (weak, nonatomic) IBOutlet UIView *invitationsNotificationsView;
@property (weak, nonatomic) IBOutlet UIView *container0;
@property (weak, nonatomic) IBOutlet UIView *container1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *container0Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *container1Height;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;



@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.reloadFlag = YES;
    self.offlineNewsFlag = 1;
    self.counter = 0;
    self.footerContentHeight = 10;
    self.enableReloading = YES;
    self.groupImages = [[NSMutableArray alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    [self.userDefaults synchronize];
    self.pullToRefreshFlag = 0;
    self.newsFlag = 0;
    self.offline = 0;
    
    self.sectionsToHide = [[NSMutableArray alloc]init];
    self.myView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin;
    
    [self.noEventsLabel setHidden:YES];
    [self.showAllEventsLabel setHidden:YES];
    [self.showAllEventsBtn setHidden:YES];
    [self.noNewsLabel setHidden:YES];
    
    self.navigationController.navigationBar.hidden = YES;
    self.sectionAds = [[NSMutableDictionary alloc]init];
    self.sectionGroups = [[NSMutableDictionary alloc]init];
    self.view.backgroundColor = [UIColor blackColor];

    [self.groupsCollectionView setTransform:CGAffineTransformMakeScale(-1, 1)];
    [self.eventCollectionView setTransform:CGAffineTransformMakeScale(-1, 1)];
    [self.newsCollectionView setPagingEnabled:YES];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    
    if (internetStatus != NotReachable) {
        self.offline = false;
        self.loadCache = true;
        self.news = [self.userDefaults objectForKey:@"news"];
        [self.newsCollectionView reloadData];
        self.events = [self.userDefaults objectForKey:@"events"];
        if (self.events.count > 0) {
            [self.showAllEventsBtn setHidden:NO];
            [self.showAllEventsLabel setHidden:NO];
        }
    
    }
    else {
        self.offline = true;
        self.loadCache = false;
        
        self.news = [self.userDefaults objectForKey:@"news"];
        [self.newsCollectionView reloadData];
        self.events = [self.userDefaults objectForKey:@"events"];
        if (self.events.count > 0) {
            [self.showAllEventsBtn setHidden:NO];
            [self.showAllEventsLabel setHidden:NO];
        }
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }
    

    self.VIPPointsNumber.text = @"";
    [self.msgsNotificationView setHidden:YES];
    [self.invitationsNotificationsView setHidden:YES];

    [self addOrRemoveFooter];
   
    //[self.groupsCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:NULL];

}

-(void)addOrRemoveFooter {
    BOOL remove = [[self.userDefaults objectForKey:@"removeFooter"]boolValue];
    [self removeFooter:remove];
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
//{
//    if (self.sectionsToHide.count > 0 && self.reloadFlag == YES) {
//        self.counter = 0 ;
//        self.reloadFlag = NO;
//        [self.groupsCollectionView reloadData];
//        
//    }
//}



-(void)viewDidAppear:(BOOL)animated {
    [self.userDefaults removeObjectForKey:@"invitees"];
    [self emptyMarkedGroups];
    [self.userDefaults synchronize];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];

    
    NSDictionary *getInvNum = [[NSDictionary alloc]init];
    NSDictionary *getInvNumTag = [[NSDictionary alloc]init];
    
    
    
//    if ([self.userDefaults integerForKey:@"activateFlag"] == 1) {
//        
//        //[self performSegueWithIdentifier:@"activateAccount" sender:self];
//        [self performSegueWithIdentifier:@"welcomeSegue" sender:self];
//        
//    }else if ([self.userDefaults integerForKey:@"signedIn"] == 0 && [self.userDefaults integerForKey:@"Guest"]==0 && [self.userDefaults integerForKey:@"Visitor"] == 0) {
//        [self performSegueWithIdentifier:@"welcomeSegue" sender:self];
////        WelcomePageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcome"];
////        //[self presentViewController:vc animated:NO completion:nil];
////        [self.navigationController pushViewController:vc animated:NO];
//        self.segueFlag = 0;
//        [self.myProfileLabel setText:@"حسابي"];
//    }
    
    
    if ([self.userDefaults integerForKey:@"Guest"]==1) {
        //Not functional any more
        [self.btnBuyInvitations setEnabled:NO];
        self.segueFlag = 2;
        [self.myProfileLabel setText:@"حسابي"];
        //[self.btnMyAccount setEnabled:NO];
        [self.btnMyMessages setEnabled:NO];
        [self.btnSearch setEnabled:NO];
        [self.btnSupport setEnabled:NO];
        
     
        self.newsCollectionView.allowsSelection = NO;
        self.groupsCollectionView.allowsSelection = NO;
        
    }else if ([self.userDefaults integerForKey:@"Visitor"] == 1){
        
       // [self.btnBuyInvitations setEnabled:NO];
        //        [self.btnMyAccount setEnabled:NO];
        self.segueFlag = 1;
        [self.btnMyProfile setTitle:@"خروج" forState:UIControlStateNormal];
        
        [self.btnMyProfile setEnabled:YES];
        
        [self.btnMyMessages setEnabled:NO];
        [self.btnSupport setEnabled:NO];
        [self.btnInvitationsBuy setEnabled:NO];
        [self.btnInvitationsBuySmall setEnabled:NO];
        [self.btnCreateNewInvitation setEnabled:NO];
        
//        self.eventsTableView.allowsSelection = NO;
//        self.eventCollectionView.allowsSelection = NO;
//        self.newsCollectionView.allowsSelection = NO;
//        self.groupsCollectionView.allowsSelection = NO;

        
    }else{
        
        [self.btnMyProfile setTitle:@"حسابي" forState:UIControlStateNormal];
        self.userID = [self.userDefaults integerForKey:@"userID"];
        [self.btnMyProfile setEnabled:YES];
        [self.btnMyMessages setEnabled:YES];
        [self.btnSupport setEnabled:YES];
        [self.btnInvitationsBuy setEnabled:YES];
        [self.btnInvitationsBuySmall setEnabled:YES];
        [self.btnCreateNewInvitation setEnabled:YES];
        
//        [self.btnBuyInvitations setEnabled:YES];
//        //        [self.btnMyAccount setEnabled:NO];
//        [self.btnMyMessages setEnabled:YES];
//        [self.btnSearch setEnabled:YES];
//        [self.btnSupport setEnabled:YES];
//        [self.btnInvitationsBuy setEnabled:YES];
//        self.segueFlag = 0;
//        [self.myProfileLabel setText:@"حسابي"];
        
//        self.eventsTableView.allowsSelection = YES;
        self.eventCollectionView.allowsSelection = YES;
        self.newsCollectionView.allowsSelection = YES;
        self.groupsCollectionView.allowsSelection = YES;
        
       
    }
    
    
    
    NSArray *groups = [self.userDefaults objectForKey:@"groups"];

    if (groups != nil) {
//        self.offlineGroupsFlag = 1 ;
        self.groups = groups;
    
        [self assignGroupsToSections];
//        
      //  [self.groupsCollectionView reloadData];
    }
  
//
    
//    NSArray *news = [self.userDefaults objectForKey:@"news"];
//
//    if (news != nil) {
//        //self.offlineNewsFlag = 1 ;
//        self.news = news;
//        [self.newsCollectionView reloadData];
//    }
    
    [self initAds];
    NSDictionary *getUserPoints = @{
                                @"FunctionName":@"getUserPoints" ,
                                @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.userID]}]};
    
    NSMutableDictionary *getUserPointsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUserPoints",@"key", nil];
    
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
    
    
    NSDictionary *getUnReadInbox = @{@"FunctionName":@"unReadInbox" , @"inputs":@[@{@"ReciverID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                    //                                                                             @"catID":@"-1",
                                                                                    //                                                                             @"start":@"0",@"limit":@"3"
                                                                                    }]};
    NSMutableDictionary *getUnReadInboxTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"unReadInbox",@"key", nil];
    
    
    if (self.userMobile && self.userPassword) {
        getInvNum = @{@"FunctionName":@"signIn" ,
                      @"inputs":@[@{@"Mobile":self.userMobile,
                                    @"password":self.userPassword}]};
        
        getInvNumTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invNum",@"key", nil];
    }
    
    
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
        //[self.adsConnection getAdsWithStart:0 andLimit:1000];
        
//        [self postRequest:getUnReadInbox withTag:getUnReadInboxTag];
//         [self postRequest:getInvNum withTag:getInvNumTag];
        
        @try {
            [self postRequest:getUserPoints withTag:getUserPointsTag];
        }
        @catch (NSException *exception) {
            //NSLog(@"ERROOOR");
        }

        
        
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
            //[self downloadNewsImages];
            [self postRequest:getGroups withTag:getGroupsTag];
            [self postRequest:getNews withTag:getNewsTag];
            [self postRequest:getEvents withTag:getEventsTag];
            [self postRequest:getUserPoints withTag:getUserPointsTag];
            [self initAds];
            //[self.adsConnection getAdsWithStart:0 andLimit:1000];
//            [self postRequest:getUnReadInbox withTag:getUnReadInboxTag];
//            [self postRequest:getUserPointsTag withTag:getUserPointsTag];
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

-(void)initAds{
    self.adsConnection = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        self.allAds = responseArray;
        if (self.allAds.count > 0) {
           // [self distributeAds];
            [self numberOfSectionsFromEnabledAds];
            [self assignGroupsToSections];
            [self.groupsCollectionView reloadData];
        }
        
        [self.groupsCollectionView reloadData];
        
    }];
    [self.adsConnection getAdsWithStart:10 andLimit:1000];
}

-(NSInteger)numberOfSectionsFromEnabledAds {
    NSInteger section = 0 ;
    NSMutableArray *tempAds = [[NSMutableArray alloc]init];
    for (int i = 0 ; i < self.allAds.count; i++) {
        NSDictionary *ad = self.allAds[i];
        NSInteger isEnabled = [ad[@"Enable"]integerValue];
        if (isEnabled == 1) {
            [tempAds addObject:ad];
            [self.sectionAds setValue:[tempAds copy] forKey:[NSString stringWithFormat:@"%ld",(long)section]];
            if ((i+1) %3 == 0 && i+1 < self.allAds.count) {
                section++;
                [tempAds removeAllObjects];
            }
        }
    }
    return self.sectionAds.count;
}

-(void)distributeAds{
    
    NSInteger section = 0 ;
    NSMutableArray *tempAds = [[NSMutableArray alloc]init];
    int counter = 0 ;
    
    while (section < 5) {
        for (int i = counter ; i < counter + 3 ; i ++) {
            [tempAds addObject:self.allAds[i]];
            if (i == counter+2) {
                [self.sectionAds setValue:[tempAds copy] forKey:[NSString stringWithFormat:@"%ld", (long)section]];
                [tempAds removeAllObjects];
            }
            
        }
        counter = counter + 3 ;
        section++ ;
    }
    
    
}




-(void)viewWillDisappear:(BOOL)animated{
//    [self.groupsSpinner stopAnimating];
//    [self.eventsSpinner stopAnimating];
     //[self.groupsCollectionView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    self.segueFlag = 0;
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

//-(void)clearProfileCaching{
//
//    SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:@"profile"];
//    [imageCache clearMemory];
//    [imageCache clearDisk];
//}

#pragma mark - Middle container Delegate 
-(void)removeContainerIfEmpty:(BOOL)isEmpty withContainerID:(NSInteger)containerID {
    if (isEmpty == YES) {
        if (containerID == 0) {
            self.container0Height.constant = 0;
        
        }else if (containerID == 1){
            self.container1Height.constant = 0;
        }
    }
}

#pragma mark - Footer Container Delegate

-(void)adjustFooterHeight:(NSInteger)height{
    self.footerHeight.constant = height;
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


#pragma mark - Collection View methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (collectionView.tag == 0) {
        if (self.sectionAds.count > 0) {
             return self.sectionAds.count;
        }else{
            return 1;
        }
       
    }else{
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView.tag == 0 && self.groups.count > 0) {
        NSArray *sectionGroups = [self.sectionGroups valueForKey:[NSString stringWithFormat:@"%ld",(long)section]];
        if (sectionGroups.count > 0) {
             return sectionGroups.count;
        }else{
            return self.groups.count;
        }
       


    }else if (collectionView.tag == 1){
        return self.news.count;
    }else if (collectionView.tag == 2){
        return self.events.count;
    }else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    
    if (collectionView.tag == 0) {
        if (self.sectionAds.count > 0) {
            return CGSizeMake((self.groupsCollectionView.bounds.size.width), 150);
        }else{
             return CGSizeMake((self.groupsCollectionView.bounds.size.width), 1);
        }
        
        
    }else{
        return CGSizeZero;
    }
    return CGSizeZero;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

     cellGroupsCollectionView *cell = [[cellGroupsCollectionView alloc]init];
    
    if (collectionView.tag == 0 ) {
        
        NSDictionary *tempGroup = [[NSDictionary alloc]init];
        NSArray *sectionGroups = [[NSArray alloc]init];
        if (self.sectionGroups.count > 0) {
            sectionGroups = [self.sectionGroups valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        }else{
            sectionGroups = self.groups;
        }
        
        if (sectionGroups.count > 19 ) {
           // NSLog(@"%lu",(unsigned long)sectionGroups.count);
        }
        //self.groups[indexPath.item];
        
        tempGroup = sectionGroups[indexPath.row];
        
        if (indexPath.item == 1 && indexPath.section == 0 ) {
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
        

        

        if ([tempGroup[@"Royal"]integerValue] == 1) {
            NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",tempGroup[@"ProfilePic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            
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
            
            NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",tempGroup[@"ProfilePic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            // UIActivityIndicatorView *groupsSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [cell.groupPP sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                groupsSpinner.center = cell.groupPP.center;
//                groupsSpinner.hidesWhenStopped = YES;
//                [cell addSubview:groupsSpinner];
//                [groupsSpinner startAnimating];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                cell.groupPP.image = image;
                
                    // [groupsSpinner stopAnimating];
               
               
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
//                NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@&t=150x150",tempGroup[@"ProfilePic"]];
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
                NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",tempNews[@"Image"]];
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
        
        NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
        NSURL *imgURL = [NSURL URLWithString:imgURLString];
       // UIActivityIndicatorView *eventsSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [cell.eventPic sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            eventsSpinner.center = cell.eventPic.center;
//            eventsSpinner.hidesWhenStopped = YES;
//            [cell addSubview:eventsSpinner];
//            [eventsSpinner startAnimating];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.eventPic.image = image;
         
//            [eventsSpinner stopAnimating];

            
        }];
        
        UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        [aFlowLayout setSectionInset:UIEdgeInsetsMake(5, 0, 5, 0)];

        
            [cell.contentView setTransform:CGAffineTransformMakeScale(-1, 1)];
            self.eventCollectionViewConstraint.constant = self.eventCollectionView.contentSize.height;
            
            return cell ;
    }
    
    return nil ;
}



-(void)downloadNewsImages {
    
    for (int i = 0; i < self.news.count; i++) {
        NSDictionary *tempNews = self.news[i];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",tempNews[@"Image"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *imageData = UIImagePNGRepresentation(image);
                NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                [self.userDefaults setObject:encodedDate forKey:tempNews[@"Image"]];
                [self.userDefaults synchronize];
                [self.newsCollectionView reloadData];
                
            });
        });
       
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    
    if (kind== UICollectionElementKindSectionFooter && collectionView.tag == 0) {
        
        customGroupFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"adFooter" forIndexPath:indexPath];
        
       // NSLog(@"%ld",(long)indexPath.section);
        self.verticalLayoutConstraint.constant = self.groupsCollectionView.contentSize.height;

        [footer setTransform:CGAffineTransformMakeScale(-1, 1)];
        
        NSLog(@"%@",self.sectionAds);
        NSLog(@"%ld",(long)indexPath.section);

            //NSMutableArray *threeAds = [[NSMutableArray alloc]init];
        
        NSMutableArray *threeAds = [self.sectionAds objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        //NSLog(@"%ld",(long)indexPath.section);
        NSLog(@"%@",self.sectionAds);
            //NSInteger numberOfDeletedAds = 0 ;
            for (int i = 0; i < threeAds.count; i++) {
                NSDictionary *tempAd = threeAds[i];
                NSInteger picID = [tempAd[@"adsImage"]integerValue];
                NSInteger adID = [tempAd[@"id"]integerValue];
                self.footerImgConnection = [[NetworkConnection alloc]init];
                switch (i) {
                    case 0:{
                       // NSLog(@"%ld",(long)picID);
                        footer.btn1.tag = adID;
                        [self removeIfDisabled:tempAd imageView:footer.img1 imageHeight:footer.img1Height imgWidth:nil andButtonHeight:footer.img1Height buttonWidth:nil];
                       // [self removeIfDisabled:tempAd imageView:footer.img1 imageHeight:footer.img1Height andButtonHeight:footer.btn1Height];
                        //[self.footerImgConnection downloadImageWithID:picID andImageView:footer.img1];
//                        [self removeIfDisabled:tempAd imageView:footer.img1 andButton:footer.btn1];
                        if (threeAds.count == 1) {
                            
                            footer.btn2Height.constant = 0;
                            footer.img2Height.constant = 0;
                            footer.btn2Width.constant = 0;
                            footer.img2Width.constant = 0;
                            
                            footer.btn3Height.constant = 0;
                            footer.img3Height.constant = 0;
                            footer.btn3Width.constant =0;
                            footer.img3Width.constant = 0;
                            
//                            [footer.img2 removeFromSuperview];
//                            [footer.btn2 removeFromSuperview];
//                            
//                            [footer.img3 removeFromSuperview];
//                            [footer.btn3 removeFromSuperview];
                        }
//                        if (remove == YES) {
//                            numberOfDeletedAds ++ ;
//                        }
                        break;
                    }case 1:{

                        footer.btn2.tag = adID;
                        [self removeIfDisabled:tempAd imageView:footer.img2 imageHeight:footer.img2Height imgWidth:footer.img2Width andButtonHeight:footer.btn2Height buttonWidth:footer.btn2Width];
                        //[self removeIfDisabled:tempAd imageView:footer.img2 imageHeight:footer.img2Height andButtonHeight:footer.btn2Height];
                        
                        //[self.footerImgConnection downloadImageWithID:picID andImageView:footer.img2];
                        //[self removeIfDisabled:tempAd imageView:footer.img2 andButton:footer.btn2];
//                        if (remove == YES) {
//                            numberOfDeletedAds ++ ;
//                        }
                        
                        footer.img2Width.constant = (footer.frame.size.width/2) - 5;
                        footer.btn2Width.constant = (footer.frame.size.width/2) - 5;
                        if (threeAds.count == 2) {
                            //footer.btn3Height.constant = 0;
                            footer.btn3Width.constant = 0 ;
                            
                            //footer.img3Height.constant = 0;
                            footer.img3Width.constant = 0;
                            
                            //[footer.img3 removeFromSuperview];
                            //[footer.btn3 removeFromSuperview];
                            
                            
//                            [footer.img3 removeFromSuperview];
//                            [footer.btn3 removeFromSuperview];
                        }
                        break;
                    }case 2:{
                        
                       // NSLog(@"%ld",(long)picID);
                        footer.btn3.tag = adID;
                        footer.img3Width.constant = (footer.frame.size.width/2) - 5;
                        footer.btn3Width.constant = (footer.frame.size.width/2) - 5;
                        //[self.footerImgConnection downloadImageWithID:picID andImageView:footer.img3];
                        //[self removeIfDisabled:tempAd imageView:footer.img3 imageHeight:footer.img3Height andButton:footer.btn3Height];
                        [self removeIfDisabled:tempAd imageView:footer.img3 imageHeight:footer.img3Height imgWidth:footer.img3Width andButtonHeight:footer.btn3Height buttonWidth:footer.btn3Width];
                        //[self removeIfDisabled:tempAd imageView:footer.img3 imageHeight:footer.img3Height andButtonHeight:footer.btn3Height];
                        break;
                    }
                    default:
                        break;
                }

            }
            

        

        reusableview = footer;
    
    }else{

    }
    return reusableview;
}


-(void)removeIfDisabled:(NSDictionary *)ad imageView:(UIImageView *)imageV imageHeight:(NSLayoutConstraint* )imgHeight imgWidth:(NSLayoutConstraint *)imgWidth andButtonHeight:(NSLayoutConstraint *)btnHeight buttonWidth:(NSLayoutConstraint *)btnWidth {
    NSInteger picNumber = [ad[@"adsImage"]integerValue];
    NSInteger status = [ad[@"Enable"]integerValue];
    if (status == 0) {
        //[imageV removeFromSuperview];
        //[btn removeFromSuperview];
        imgHeight.constant = 0;
        btnHeight.constant = 0;
        

    }else if (status == 1){
        imgHeight.constant = 68;
        btnHeight.constant = 68;
        if (imgWidth != nil && btnWidth != nil) {
           //imgWidth.constant = 30;
            //btnWidth.constant = 142;
        }
        [self.footerImgConnection downloadImageWithID:picNumber andImageView:imageV];

    }

}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 0) {
        NSArray *sectionGroups = [self.sectionGroups valueForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        self.selectedGroup = sectionGroups[indexPath.row];
//        self.selectedGroup = self.groups[indexPath.item];
//        switch (indexPath.section) {
//            case 0:{
//                self.selectedGroup = self.firstSection[indexPath.row];
//                break;
//            }
//                
//            case 1:{
//                
//                self.selectedGroup = self.secondSection[indexPath.row];
//                
//                break;
//            }
//                
//            case 2:{
//                
//                self.selectedGroup = self.thirdSection[indexPath.row];
//                break;
//            }
//                
//            case 3:{
//                self.selectedGroup = self.fourthSection[indexPath.row];
//
//                break;
//            }
//                
//            case 4:{
//
//                self.selectedGroup = self.fifthSection[indexPath.row];
//                break;
//            }
//                
//            default:
//                break;
//        }

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
    //was 142
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
    }else if ([segue.identifier isEqualToString:@"specialEvent"]){
        SpecialEventsViewController *specialEvent = segue.destinationViewController;
        specialEvent.eventType = self.selectedSpecialEventType;
    }else if ([segue.identifier isEqualToString:@"footer"]){
        FooterContainerViewController *footerController = segue.destinationViewController;
        footerController.footerAds = self.footerAds;
        footerController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"middle0"]){
        MiddleContainerViewController *middleController = segue.destinationViewController;
        middleController.containerID = 0;
        middleController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"middle1"]){
        MiddleContainerViewController *middleContainer = segue.destinationViewController;
        middleContainer.containerID = 1;
        middleContainer.delegate = self;
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
    NSString *urlString = @"http://Bixls.com/api/" ;
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
 
    
    [self.queue addOperation:request];

    //[request startAsynchronous];
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
            [self.userDefaults setObject:self.groups forKey:@"groups"];
            [self assignGroupsToSections];

            
            [self.userDefaults synchronize];
            
            [self.groupsCollectionView reloadData];
        }else{

            [self.userDefaults setObject:self.groups forKey:@"groups"];
            [self assignGroupsToSections];
            

            [self.userDefaults synchronize];
            
            [self.groupsCollectionView reloadData];

        }


        
    }else if([key isEqualToString:@"getNews"]){
        
        if (responseArray.count > 0) {
            self.pullToRefreshFlag ++;
            //self.offlineNewsFlag = 0;
            self.news = responseArray;
            [self.noNewsLabel setHidden:YES];
            //self.newsCollectionViewHeight.constant = 142;
            [self downloadNewsImages];
            [self.userDefaults setObject:self.news forKey:@"news"];
            [self.userDefaults synchronize];
            [self.newsCollectionView reloadData];
        }else{
            self.news = responseArray;
            [self.noNewsLabel setHidden:NO];
            [self.userDefaults removeObjectForKey:@"news"];
            [self.userDefaults synchronize];
            self.newsCollectionView.scrollEnabled = NO;

//            self.newsCollectionView.frame = CGRectMake(self.newsCollectionView.frame.origin.x, self.newsCollectionView.frame.origin.y, self.newsCollectionView.frame.size.width, 500);
//            [self.newsCollectionView setNeedsDisplay];
//            [self.newsCollectionView setNeedsLayout];
//            [self.view setNeedsDisplay];
            //self.newsCollectionViewHeight.constant = 0;
            [self.newsCollectionView reloadData];
            self.pullToRefreshFlag ++;
        }


    }else if ([key isEqualToString:@"getEvents"]){
        if (responseArray.count > 0) {
            self.events = responseArray;
            [self.noEventsLabel setHidden:YES];
            if (self.events.count > 0) {
                [self.showAllEventsBtn setHidden:NO];
                [self.showAllEventsLabel setHidden:NO];
            }
            [self.userDefaults setObject:self.events forKey:@"events"];
            [self.userDefaults synchronize];
            self.eventCollectionViewConstraint.constant = 210;
            [self.eventCollectionView reloadData];
            self.pullToRefreshFlag ++;
        }else{
            self.events = responseArray;
            [self.noEventsLabel setHidden:NO];
            [self.showAllEventsBtn setHidden:YES];
            [self.showAllEventsLabel setHidden:YES];
            [self.userDefaults removeObjectForKey:@"events"];
            [self.userDefaults synchronize];
            self.eventCollectionViewConstraint.constant = 0;
            [self.eventCollectionView reloadData];
            //NSLog(@"No events");
        }


    }
//    else if ([key isEqualToString:@"unReadInbox"]){
//        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        self.unReadMsgs = [dict[@"unReaded"]integerValue];
//        [self.btnUnReadMsgs setHidden:NO];
//        [self.btnUnReadMsgs setTitle:[NSString stringWithFormat:@"%ld",(long)self.unReadMsgs] forState:UIControlStateNormal];
//        self.pullToRefreshFlag ++;
//    }
//    else if ([key isEqualToString:@"invNum"]){
//        NSDictionary *responseDictionary =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        NSInteger VIP  = [responseDictionary[@"inVIP"]integerValue];
//        self.VIPPointsNumber.text = [NSString stringWithFormat:@"%ld",(long)VIP];
//        [self.userDefaults setInteger:VIP forKey:@"VIPPoints"];
//        [self.userDefaults synchronize];
//        
//       // UPDATE CONTROLS
//    }
    else if ([key isEqualToString:@"getUserPoints"]){
        
        NSDictionary *responseDictionary =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        
        if (responseDictionary[@"unRead"]) {
            
            NSInteger unread = [responseDictionary[@"unRead"]integerValue];
            if (unread > 0) {
                [self.msgsNotificationView setHidden:NO];
            }else{
                [self.msgsNotificationView setHidden:YES];
            }
            [self.btnUnReadMsgs setHidden:NO];
//            NSString *unread = [responseDictionary[@"unRead"]stringValue];
//            NSLog(@"%@",unread);
            [self.btnUnReadMsgs setTitle:[NSString stringWithFormat:@"%ld",(long)unread] forState:UIControlStateNormal];
            
            //[self.btnUnReadMsgs setTitle:[responseDictionary[@"unRead"]stringValue] forState:UIControlStateNormal];
//            [[self.btnUnReadMsgs setTitle:[NSString stringWithFormat:@"%@",unread] forState:UIControlStateNormal];
//             self.btnUnReadMsgs setTitle:[NSString stringWithFormat:@"%@",unread] forState:UIControlStateNormal];
            self.pullToRefreshFlag ++;
        }
        
        if (responseDictionary[@"VIP"]!= [NSNull null]) {
            [responseDictionary[@"VIP"]integerValue];
            NSInteger VIP = [responseDictionary[@"VIP"]integerValue];
            if (VIP > 0) {
                [self.invitationsNotificationsView setHidden:NO];
            }else{
                [self.invitationsNotificationsView setHidden:YES];
            }
            self.VIPPointsNumber.text = [NSString stringWithFormat:@"%ld",(long)VIP];
           // [s setTitle:[NSString stringWithFormat:@"%ld",(long)VIP] forState:UIControlStateNormal];
            
//            NSInteger VIP  = [responseDictionary[@"inVIP"]integerValue];
//            self.VIPPointsNumber.text = [NSString stringWithFormat:@"%ld",(long)VIP];
//            self.lblVIPPoints.text = [NSString stringWithFormat:@"%ld",(long)VIP];
            
            [self.userDefaults setInteger:VIP forKey:@"VIPPoints"];
            [self.userDefaults synchronize];
        }
        
        
        
    
        
        // UPDATE CONTROLS
    }
    
//invNum

}

-(void)assignGroupsToSections{
    
    NSMutableArray *tempGroups = [[NSMutableArray alloc]init];
    NSInteger counter = 19 ;
    for (int i = 0 ; i < self.sectionAds.count; i++) {
        if (i == 0 ) {
            [self populateFirstSection];
        }else{
            
            NSInteger numberOfRemainingSections = self.sectionAds.count-1;
            NSInteger max = (self.groups.count-19) / numberOfRemainingSections;
            max = max + 1 ;
            //NSLog(@"%ld",max);
            for (NSInteger k = counter ; k < counter + max; k++) {
                if (k < self.groups.count) {
                    [tempGroups addObject:self.groups[k]];
                    NSArray *temp = [tempGroups copy];
                    [self.sectionGroups setValue:temp forKey:[NSString stringWithFormat:@"%d",i]];
                    if (k+1 == counter+max ) {
                        counter = counter + max;
                        [tempGroups removeAllObjects];
                        break;
                    }
                }else{
                    break;
                }
              
            }
            
            
        }
    }
}

/*
 
 -(NSInteger)numberOfSectionsFromEnabledAds {
 NSInteger section = 0 ;
 NSMutableArray *tempAds = [[NSMutableArray alloc]init];
 for (int i = 0 ; i < self.allAds.count; i++) {
 NSDictionary *ad = self.allAds[i];
 NSInteger isEnabled = [ad[@"Enable"]integerValue];
 if (isEnabled == 1) {
 [tempAds addObject:ad];
 [self.sectionAds setValue:[tempAds copy] forKey:[NSString stringWithFormat:@"%ld",(long)section]];
 if ((i+1) %3 == 0 && i+1 < self.allAds.count) {
 section++;
 [tempAds removeAllObjects];
 }
 }
 }
 return self.sectionAds.count;
 }
 
 */

-(void)populateFirstSection {
    if (self.sectionAds.count > 1) {
        NSMutableArray *tempGroups = [[NSMutableArray alloc]init];
        for (int j = 0; j < 19; j++) {
            [tempGroups addObject:self.groups[j]];
        }
        [self.sectionGroups setValue:[tempGroups copy] forKey:[NSString stringWithFormat:@"%d",0]];
        [tempGroups removeAllObjects];
    }else {
     
            NSMutableArray *tempGroups = [[NSMutableArray alloc]init];
            for (int j = 0; j < self.groups.count; j++) {
                [tempGroups addObject:self.groups[j]];
            }
            [self.sectionGroups setValue:[tempGroups copy] forKey:[NSString stringWithFormat:@"%d",0]];
            [tempGroups removeAllObjects];
    
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
- (IBAction)specialEventPressed:(UIButton *)sender {
    self.selectedSpecialEventType = sender.tag;
    [self performSegueWithIdentifier:@"specialEvent" sender:self];
    
    
}

- (IBAction)btn1FooterPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
    
}

- (IBAction)btn2FooterPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
   // NSLog(@"%ld",(long)button.tag);
}

- (IBAction)btn3FooterPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
    //NSLog(@"%ld",(long)button.tag);
}

-(void)emptyMarkedGroups{
    [self.userDefaults removeObjectForKey:@"markedGroups"];
    [self.userDefaults synchronize];
}

#pragma mark - Open Safari

-(void)openWebPageWithBtnTag:(NSInteger)tag {
    NSString *webPage = [self searchAllAdsAndGetWebPageWithID:tag];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webPage]];
}

-(NSString *)searchAllAdsAndGetWebPageWithID:(NSInteger)adID{
    for (NSDictionary *tempAd in self.allAds) {
        NSInteger tempID = [tempAd[@"id"]integerValue];
        if (tempID == adID) {
            return tempAd[@"adsURL"];
        }
    }
    return nil;
}

@end
