//
//  MyProfileViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 3,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ASIHTTPRequest.h"
#import "EditAccountViewController.h"
#import "EventViewController.h"
#import <Social/Social.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ASIDownloadCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EventsDataSource.h"
#import "FullImageViewController.h"

static void *invitationsNumberContext = &invitationsNumberContext;
static void *eventsContext = &eventsContext;
static void *userContext = &userContext;

@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *btnSignOut;
@property (weak, nonatomic) IBOutlet UIView *innerView;
@property (weak, nonatomic) IBOutlet UICollectionView *eventsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventsCollectionViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *userType;

@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger groupID;
@property (nonatomic) NSInteger userTypeFlag;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic, retain) UIDocumentInteractionController *dic;
@property (nonatomic) BOOL finishedLoadingEvents;
@property (nonatomic,strong) NetworkConnection *getInvitationsNumConnection;
@property (nonatomic,strong) NetworkConnection *getUserConnection;
@property (nonatomic,strong) NetworkConnection *getUserEventsConnection;
@property (nonatomic,strong) NetworkConnection *downloadProfilePicConnection;
@property (strong) UIActivityIndicatorView *profilePicSpinner;
@property (strong) UIActivityIndicatorView *tableViewSpinner;
@property (strong,nonatomic) SDImageCache *imageCache;
@property (nonatomic,strong) EventsDataSource *customEventsDataSource;

@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //Table View delegate and datasource


    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];
    self.userTypeFlag = -1;
    [self.userType setHidden:YES];
    
    if ([self.userDefaults objectForKey:@"userName"]) {
        self.myName.text = [self.userDefaults objectForKey:@"userName"];
    }
    if ([self.userDefaults objectForKey:@"groupName"]) {
        self.myGroup.text = [self.userDefaults objectForKey:@"groupName"];
    }
    
//    NSLog(@"%d",self.finishedLoadingEvents);
    [self.activateLabel setHidden:YES];
    [self.activateLabel2 setHidden:YES];
    [self.btnSeeMore setHidden:YES];
    [self.imgSeeMore setHidden:YES];
    
    [self initializeConnections];
    
//    self.tableViewSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    self.tableViewSpinner.center = CGPointMake(self.view.bounds.size.width/2, self.tableView.frame.origin.y + self.tableView.frame.size.height/2);
//    self.tableViewSpinner.hidesWhenStopped = YES;
//    [self.innerView addSubview:self.tableViewSpinner];
//    
//    [self.tableViewSpinner startAnimating];
}

-(void)initializeConnections{
    self.getInvitationsNumConnection = [[NetworkConnection alloc]init];
    self.getUserConnection = [[NetworkConnection alloc]init];
    self.getUserEventsConnection = [[NetworkConnection alloc]init];
    self.downloadProfilePicConnection = [[NetworkConnection alloc]init];
    self.downloadProfilePicConnection.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self.getInvitationsNumConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:invitationsNumberContext];
    [self.getUserConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:userContext];
    [self.getUserEventsConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:eventsContext];
    
    self.imageCache = [SDImageCache sharedImageCache];
    [self.imageCache queryDiskCacheForKey:@"profilePic" done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image == nil) {
            self.profilePicSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            self.profilePicSpinner.center = self.myProfilePicture.center;
            self.profilePicSpinner.hidesWhenStopped = YES;
            [self.innerView addSubview:self.profilePicSpinner];

            [self.profilePicSpinner startAnimating];
        }else{
            self.myProfilePicture.image = image;
        }
    }];
    
    if (self.userID) {
        [self.getUserConnection getUserWithID:self.userID];
        
    }
    
    if (self.userMobile && self.userPassword) {
        [self.getInvitationsNumConnection getInvitationsNumberWithMobile:self.userMobile password:self.userPassword];
        
    }
    
    [self.getUserEventsConnection getUserEventsWithUserID:self.userID startValue:0 limitValue:4];

}



-(void)viewWillDisappear:(BOOL)animated{
    
    [self.getInvitationsNumConnection removeObserver:self forKeyPath:@"response" context:invitationsNumberContext];
    [self.getUserConnection removeObserver:self forKeyPath:@"response" context:userContext];
    [self.getUserEventsConnection removeObserver:self forKeyPath:@"response" context:eventsContext];
    
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

#pragma mark - KVO Method

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
    NSDictionary *responseDictionary =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    
    if (context == userContext && [keyPath isEqualToString:@"response"]) {
        self.user = responseDictionary;
        self.userTypeFlag = 1;
        [self updateUI];
    }else if (context == eventsContext && [keyPath isEqualToString:@"response"]){
        NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.events = responseArray;
        self.customEventsDataSource = [[EventsDataSource alloc]initWithEvents:self.events withHeightConstraint:self.eventsCollectionViewHeight andViewController:self withSelectedEvent:^(NSDictionary *selectedEvent) {
            self.selectedEvent = selectedEvent;
        }];
        [self.eventsCollectionView setDataSource:self.customEventsDataSource];
        [self.eventsCollectionView setDelegate:self.customEventsDataSource];
        self.finishedLoadingEvents = true;
        [self setOrHideSeeMoreButton];
        [self.eventsCollectionView reloadData];
        //[self.tableViewSpinner stopAnimating];
        //[self.tableView reloadData];
    }else if (context == invitationsNumberContext && [keyPath isEqualToString:@"response"]){
        NSInteger VIP  = [responseDictionary[@"inVIP"]integerValue];
        //[self.btnInvitationNum setTitle:normal forState:UIControlStateNormal];
        [self.btnVIPNum setTitle:[NSString stringWithFormat:@"%ld",(long)VIP] forState:UIControlStateNormal];
        [self.userDefaults setInteger:VIP forKey:@"VIPPoints"];
        [self.userDefaults synchronize];
    }
}

-(void)setOrHideSeeMoreButton{
        if (self.events.count > 0) {
            [self.btnSeeMore setHidden:NO];
            [self.imgSeeMore setHidden:NO];
            [self.activateLabel setHidden:YES];
            [self.activateLabel2 setHidden:YES];
            
        }else if( self.events.count == 0 && self.finishedLoadingEvents == true){
            
            [self.btnSeeMore removeFromSuperview];
            [self.imgSeeMore removeFromSuperview];
            [self.tableView removeFromSuperview];
            [self.activateLabel setHidden:NO];
            [self.activateLabel2 setHidden:NO];
            
        }
}

#pragma mark - Network Connection Delegate

-(void)downloadedImage:(UIImage *)image{
    self.myProfilePicture.image = image;
    [self.profilePicSpinner stopAnimating];

}


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editProfile"]) {
        EditAccountViewController *editAccount = segue.destinationViewController;
        editAccount.userName = self.user[@"name"];
        editAccount.userPic = self.myProfilePicture.image;
        editAccount.groupID = [self.user[@"Gid"]integerValue];
        editAccount.groupName = self.user[@"GName"];
        
    }else if ([segue.identifier isEqualToString:@"event"]) {
        
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
        
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }else if ([segue.identifier isEqualToString:@"fullImage"]){
        FullImageViewController *controller = segue.destinationViewController;
        controller.image = self.myProfilePicture.image;
    }
}

#pragma mark - Methods

-(void)downloadProfilePicture {
    [self.downloadProfilePicConnection downloadImageWithID:[self.user[@"ProfilePic"]integerValue] withCacheNameSpace:@"profile" withKey:@"profilePic" withWidth:150 andHeight:150];
}

-(void)updateUI {
    self.myName.text = self.user[@"name"];
    self.myGroup.text = self.user[@"GName"];
    [self showOrHideUserType:[self.user[@"Type"]integerValue]];
    
    [self downloadProfilePicture];

}

-(void)showOrHideUserType:(NSInteger)userType {
    
    if (userType == 2 && self.userTypeFlag == 1) {
        [self.userType setHidden:NO];
        self.userType.image = [UIImage imageNamed:@"ownerUser.png"];
    }else if (userType == 1 && self.userTypeFlag == 1){
        [self.userType setHidden:NO];
        self.userType.image = [UIImage imageNamed:@"vipUser.png"];
    }else if (userType == 0 && self.userTypeFlag == 1){
        [self.userType removeFromSuperview];
    }else{
        [self.userType setHidden:YES];
    }
    
}
#pragma mark - Action Sheet 
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            //[fbPostSheet setInitialText:@"This is a Facebook post!"];
            [fbPostSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/qa/app/d-wat-qtr/id1019189072?mt=8"]];
            [self presentViewController:fbPostSheet animated:YES completion:nil];
        } else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:@"Facebook عفواً لا يمكنك النشر الآن ، تأكد من وجود إنترنت و إتصالك بحساب"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }else if (buttonIndex == 1){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {

            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"حمل تطبيق دعوات قطر الآن"];
            [tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/qa/app/d-wat-qtr/id1019189072?mt=8"]];
            [self presentViewController:tweetSheet animated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:@"Facebook عفواً لا يمكنك النشر الآن ، تأكد من وجود إنترنت و إتصالك بحساب"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }

    }else if (buttonIndex == 2){
        
        NSString *url = @"https://itunes.apple.com/qa/app/d-wat-qtr/id1019189072?mt=8 حمل تطبيق دعوات قطر الآن من هنا";
        url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                    (CFStringRef)url,
                                                                                    NULL,
                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                    kCFStringEncodingUTF8));
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",url]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }

    }
}



- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}




#pragma mark - Buttons
- (IBAction)btnSignoutPressed:(id)sender {
    [self.userDefaults setInteger:0 forKey:@"Guest"];
    [self.userDefaults setInteger:0 forKey:@"signedIn"];
    [self.userDefaults setInteger:0 forKey:@"userID"];
    [self.userDefaults setInteger:0 forKey:@"Visitor"];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache removeImageForKey:@"profilePic" fromDisk:YES];
    
    
    [self.navigationController popToRootViewControllerAnimated:NO];

    
    //[self performSegueWithIdentifier:@"welcome" sender:self];
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSeeMorePressed:(id)sender {
    [self performSegueWithIdentifier:@"seeMore" sender:self];
}

- (IBAction)btnSharePressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",@"Whatsapp", nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)openFullImage:(id)sender {
    [self performSegueWithIdentifier:@"fullImage" sender:self];
}



@end
