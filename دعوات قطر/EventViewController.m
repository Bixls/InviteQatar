//
//  EventViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "EventViewController.h"
#import "ASIHTTPRequest.h"
#import "CommentsViewController.h"
#import "EventAttendeesViewController.h"
#import "CreateEventViewController.h"
#import "UserViewController.h"
#import "InviteViewController.h"
#import "chooseGroupViewController.h"
#import "ASIDownloadCache.h"
#import "ASICacheDelegate.h"
#import "Reachability.h"
@interface EventViewController ()

@property (nonatomic)NSInteger userID;

@property (nonatomic)NSInteger eventType;
@property (nonatomic)UIImage *eventImage;
@property (nonatomic)NSInteger allowComments;
@property (nonatomic)NSInteger isInvited;
@property (nonatomic)NSInteger isInvitedFlag;
@property (nonatomic)NSInteger isJoined;
@property (nonatomic)NSInteger creatorID;
@property (nonatomic)NSInteger creatorFlag;
@property (nonatomic)NSInteger approved;
@property (nonatomic)NSInteger approvedFlag;
@property (nonatomic,strong)NSString *eventDescription;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *fullEvent;
@property (nonatomic,strong) NSDictionary *user;

@property (nonatomic,strong) NSString *selectedDate;

@end

@implementation EventViewController

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
    self.view.backgroundColor = [UIColor blackColor];
 
 
    
    self.navigationItem.backBarButtonItem = backbutton;
    [self.btnAttendees setHidden:YES];
    [self.imgGoingList setHidden:YES];
    [self.imgGoing setHidden:YES];
    [self.btnEditEvent setHidden:YES];
    [self.imgEditEvent setHidden:YES];
    [self.btnInviteOthers setHidden:YES];
    [self.imgInviteOthers setHidden:YES];
    [self.imgRemindMe setHidden:YES];
    [self.btnRemindMe setHidden:YES];
    
    [self.imgTitle setHidden:YES];
    
    [self.imgComments setHidden:YES];
    [self.btnComments setHidden:YES];
    
    [self.imgUserProfile setHidden:YES];
    [self.imgPicFrame setHidden:YES];
    [self.lblUsername setHidden:YES];
    [self.btnUser setHidden:YES];
    [self.creatorPicture setHidden:YES];
    
    self.isJoined = -1;
    self.isInvited =-1;
    self.allowComments = -1;
    self.creatorFlag = -1;
    self.approvedFlag = -1;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    
    if ((self.selectedType==2 || self.selectedType == 3)) {
        //donothing
    }else{
        self.isVIP = [self.event[@"VIP"]integerValue];
        self.eventID = [self.event[@"Eventid"]integerValue];
    }
    
    self.eventType = 0;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        //do nothing
        [self updateUI];
        
    }
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [self.navigationItem setHidesBackButton:YES];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        [self getInvited];
        if (self.selectedType == 2 || self.selectedType == 3) {
            [self readMessage];
        }else{
            [self getEvent];
        }
        [self getInvited];
        [self getJoined];
        
    }
    else {
        //donothing
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

#pragma mark - UI Methods

-(void)GenerateArabicDateWithDate:(NSString *)englishDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [formatter dateFromString:englishDate];
    NSString *arabicDate = [formatter stringFromDate:dateString];
    NSString *date = [arabicDate substringToIndex:10];
    NSString *tempTime = [arabicDate substringFromIndex:11];
    NSString *time = [tempTime substringToIndex:5];
    self.eventTime.text = time;
   
    self.eventDate.text = [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
}

-(void)updateUI {

    NSLog(@"EVEENT %@",self.event);
    if (self.selectedType == 2 || self.selectedType == 3) {
        
        
    }else{
        self.eventSubject.text = self.event[@"subject"];
        [self.imgTitle setHidden:NO];

        [self GenerateArabicDateWithDate:[NSString stringWithFormat:@"%@",self.event[@"TimeEnded"]]];
        
        self.descriptionLabel.text = self.eventDescription;
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.event[@"EventPic"]];
            NSString *creatorPic = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",self.event[@"CreatorPic"]];
            NSData *eventData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            NSData *creatorData = [NSData dataWithContentsOfURL:[NSURL URLWithString:creatorPic]];
            self.eventImage = [[UIImage alloc]initWithData:eventData];
            UIImage *creatorImage = [[UIImage alloc]initWithData:creatorData];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                self.eventPicture.image = self.eventImage;
                self.creatorPicture.image = creatorImage;
            });
        });
    }
    
    if (self.isVIP == 1 && self.isInvited == 1 && self.isInvitedFlag == 1) {
        [self.imgRemindMe setHidden:NO];
        [self.btnRemindMe setHidden:NO];
    }else if ((self.isVIP != 1 || self.isInvited != 1) && self.isInvitedFlag == 1){
        [self.imgRemindMe setHidden:YES];
        [self.btnRemindMe setHidden:YES];
        [self.imgRemindMe removeFromSuperview];
        [self.btnRemindMe removeFromSuperview];
    }else {
        [self.imgRemindMe setHidden:YES];
        [self.btnRemindMe setHidden:YES];
    }
    
    
    if (self.allowComments == 1) {
        [self.btnComments setHidden:NO];
        [self.imgComments setHidden:NO];
    }else if (self.allowComments == 0){
        [self.btnComments setHidden:YES];
        [self.imgComments setHidden:YES];
        [self.btnComments removeFromSuperview];
        [self.imgComments removeFromSuperview];
    }else if (self.allowComments == -1){
        [self.btnComments setHidden:YES];
        [self.imgComments setHidden:YES];
    }
    
    
    
    if (self.isInvited == 0 && self.isInvitedFlag == 1) {
        [self.btnGoing setHidden:YES];
        [self.imgGoing setHidden:YES];
        [self.btnGoing removeFromSuperview];
        [self.imgGoing removeFromSuperview];
        
    }else if (self.isInvited == 1 && self.userID == self.creatorID && self.isInvitedFlag == 1){
        [self.btnGoing setHidden:YES];
        [self.imgGoing setHidden:YES];
        [self.btnGoing removeFromSuperview];
        [self.imgGoing removeFromSuperview];
        
    }else if (self.isInvited == 1 && self.isJoined == 0 && self.isInvitedFlag == 1){
        [self.btnGoing setHidden:NO];
        [self.imgGoing setHidden:NO];
        [self.btnGoing setTitle:@"الذهاب؟" forState:UIControlStateNormal];

    }else if(self.isInvited == 1 && self.isJoined == 1 && self.isInvitedFlag == 1){
        [self.btnGoing setHidden:NO];
        [self.imgGoing setHidden:NO];
        [self.btnGoing setTitle:@"عدم الذهاب؟" forState:UIControlStateNormal];

    }else{
        [self.btnGoing setHidden:YES];
        [self.imgGoing setHidden:YES];
    }
    
    
    
    
    if (self.userID == self.creatorID && self.creatorFlag == 1) {
        [self.btnAttendees setHidden:NO];
        [self.imgGoingList setHidden:NO];
        [self.btnEditEvent setHidden:NO];
        [self.imgEditEvent setHidden:NO];
        

    }else if (self.userID != self.creatorID && self.creatorFlag == 1){
        [self.btnAttendees setHidden:YES];
        [self.imgGoingList setHidden:YES];
        [self.btnEditEvent setHidden:YES];
        [self.imgEditEvent setHidden:YES];
        [self.btnAttendees removeFromSuperview];
        [self.imgGoingList removeFromSuperview];
        [self.btnEditEvent removeFromSuperview];
        [self.imgEditEvent removeFromSuperview];
        
    }else if (self.creatorFlag == -1){
        [self.btnAttendees setHidden:YES];
        [self.imgGoingList setHidden:YES];
        [self.btnEditEvent setHidden:YES];
        [self.imgEditEvent setHidden:YES];
    }
    
    
    if (self.approved == 1 && self.userID == self.creatorID && self.approvedFlag == 1) {
        [self.btnInviteOthers setHidden:NO];
        [self.imgInviteOthers setHidden:NO];
        [self.btnAttendees setHidden:NO];
        [self.imgGoingList setHidden:NO];
    }else if ((self.approved != 1 || self.userID != self.creatorID) && self.approvedFlag == 1){
        [self.btnInviteOthers setHidden:YES];
        [self.imgInviteOthers setHidden:YES];
        [self.btnAttendees setHidden:YES];
        [self.imgGoingList setHidden:YES];
        
        [self.btnInviteOthers removeFromSuperview];
        [self.imgInviteOthers removeFromSuperview];
        [self.btnAttendees removeFromSuperview];
        [self.imgGoingList removeFromSuperview];
        
        
    }else if(self.approvedFlag == -1 ){
        [self.btnInviteOthers setHidden:YES];
        [self.imgInviteOthers setHidden:YES];
        [self.btnAttendees setHidden:YES];
        [self.imgGoingList setHidden:YES];
    }

    


}
#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showComments"]) {
        CommentsViewController *commentController = segue.destinationViewController;
        commentController.postID = self.eventID;
        commentController.postImage = self.eventImage;
        commentController.postDescription = self.eventDescription;
//        commentController.postType = self.eventType;
        commentController.postType = 0;
        
    }else if ([segue.identifier isEqualToString:@"showAttendees"]){
        EventAttendeesViewController *eventAttendeesController = segue.destinationViewController;
        eventAttendeesController.eventID = self.eventID;
        
    }else if ([segue.identifier isEqualToString:@"editEvent"]){
        CreateEventViewController *createEventController = segue.destinationViewController;
        createEventController.createOrEdit = 1;
        createEventController.eventID = self.eventID;
        createEventController.event  = self.fullEvent;
        
    }else if ([segue.identifier isEqualToString:@"showUser"]){
        if (self.selectedType == 2 || self.selectedType == 3) {
            UserViewController *userController = segue.destinationViewController;
            userController.otherUserID = self.userID;
            userController.eventOrMsg = 1;
            
            //        userController.user = @{@"id": [NSNumber numberWithInteger:self.creatorID]};
        }else{
            UserViewController *userController = segue.destinationViewController;
            userController.user = self.user;
            userController.eventOrMsg = 0;

        }

        
    }else if ([segue.identifier isEqualToString:@"invite"]){
        InviteViewController *inviteController = segue.destinationViewController;
        inviteController.creatorID = self.creatorID;
        inviteController.eventID = self.eventID;
        inviteController.normORVIP = 0;
    }else if ([segue.identifier isEqualToString:@"inviteAll"]){
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.flag = 1;
        chooseGroupController.eventID = self.eventID;
    }else if ([segue.identifier isEqualToString:@"chooseDate"]){
        ChooseDateViewController *chooseDateController = segue.destinationViewController;
        chooseDateController.delegate = self;
    }
}

#pragma mark - Choose Date Delegate Method 

-(void)selectedDate:(NSString *)date {
    self.selectedDate = date;
    NSLog(@"%@",self.selectedDate);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  //  [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *dateFromString = [formatter dateFromString:self.selectedDate];
    NSLog(@"%@",dateFromString);

//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge
//                                                                                                              categories:nil]];
//    }
   
    UIApplication *app = [UIApplication sharedApplication];
    UILocalNotification *notifyAlarm = [[UILocalNotification alloc]init];
    if (notifyAlarm) {
        notifyAlarm.fireDate = dateFromString;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        notifyAlarm.alertBody = [NSString stringWithFormat:@"لا تنسي %@ بتاريخ %@ الساعة %@",self.event[@"subject"],self.eventDate.text,self.eventTime.text ];
        NSLog(@"%@",notifyAlarm.alertBody);
        [app scheduleLocalNotification:notifyAlarm];
    }
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
//    [formatter setLocale:qatarLocale];
////    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
////    NSDate *dateString = [formatter dateFromString:self.selectedDate];
    
  
    
    
}



#pragma mark - Connection Setup
-(void)getUSer {
    
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{
                                                                                 @"id":[NSString stringWithFormat:@"%ld",(long)self.creatorID]
                                                                                 }]};
    
 
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self postRequest:getUser withTag:getUserTag];
    
}

-(void)getEvent {
    
    NSDictionary *getEvent = @{@"FunctionName":@"getEventbyID" , @"inputs":@[@{
                                                                                 @"Eventid":[NSString stringWithFormat:@"%@",self.event[@"Eventid"]]
                                                                                 }]};
    
    //NSLog(@"%@",getEvent);
    NSMutableDictionary *getEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvent",@"key", nil];
    
    [self postRequest:getEvent withTag:getEventTag];
    
}

-(void)getInvited {
    NSInteger eventID = [self.event[@"Eventid"] integerValue];
    NSDictionary *getEvents = @{@"FunctionName":@"isInvited" , @"inputs":@[@{
                                                                               @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                               @"eventID":[NSString stringWithFormat:@"%ld",(long)eventID]
                                                                            }]};
    //[NSString stringWithFormat:@"%ld",(long)self.userID]
    //[NSString stringWithFormat:@"%ld",(long)eventID]
    //NSLog(@"%@",getEvents);
    
    if (self.selectedType == 2 || self.selectedType == 3) {

        getEvents = @{@"FunctionName":@"isInvited" , @"inputs":@[@{
                                                                                   @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                   @"eventID":[NSString stringWithFormat:@"%ld",(long)self.eventID]
                                                                                   }]};

    }
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"isInvited",@"key", nil];
    
    [self postRequest:getEvents withTag:getEventsTag];
    
}

-(void)getJoined {
    NSInteger eventID = [self.event[@"Eventid"] integerValue];
    NSDictionary *getEvents = @{@"FunctionName":@"isJoind" , @"inputs":@[@{
                                                                               @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                               @"eventID":[NSString stringWithFormat:@"%ld",(long)eventID]
                                                                               }]};
    //[NSString stringWithFormat:@"%ld",(long)self.userID]
    //[NSString stringWithFormat:@"%ld",(long)eventID]
    //NSLog(@"%@",getEvents);
    
    if (self.selectedType == 2 || self.selectedType == 3) {

      getEvents = @{@"FunctionName":@"isJoind" , @"inputs":@[@{
                                                                                 @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                 @"eventID":[NSString stringWithFormat:@"%ld",(long)self.eventID]
                                                                                 }]};
    }
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"isJoind",@"key", nil];
    
    [self postRequest:getEvents withTag:getEventsTag];
    
}

-(void)joinEvent{
    NSInteger eventID = [self.event[@"Eventid"] integerValue];
    NSDictionary *leaveEvent= @{@"FunctionName":@"JoinEvent" , @"inputs":@[@{
                                                                               @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                               @"eventID":[NSString stringWithFormat:@"%ld",(long)eventID]
                                                                               }]};
    //[NSString stringWithFormat:@"%ld",(long)self.userID]
    //[NSString stringWithFormat:@"%ld",(long)eventID]
    //NSLog(@"%@",leaveEvent);
    NSMutableDictionary *leaveEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"joinEvent",@"key", nil];
    
    [self postRequest:leaveEvent withTag:leaveEventTag];
    
}

-(void)leaveEvent{
    NSInteger eventID = [self.event[@"Eventid"] integerValue];
    NSDictionary *leaveEvent = @{@"FunctionName":@"LeaveEvent" , @"inputs":@[@{
                                                                               @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                               @"eventID":[NSString stringWithFormat:@"%ld",(long)eventID]
                                                                               }]};
    //[NSString stringWithFormat:@"%ld",(long)self.userID]
    //[NSString stringWithFormat:@"%ld",(long)eventID]
    //NSLog(@"%@",leaveEvent);
    NSMutableDictionary *leaveEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"leaveEvent",@"key", nil];
    [self postRequest:leaveEvent withTag:leaveEventTag];
    
}

-(void)readMessage {
    
    NSDictionary *readMessage = @{@"FunctionName":@"ReadMessege" , @"inputs":@[@{
                                                                                   @"messageID":[NSString stringWithFormat:@"%ld",(long)self.selectedMessageID]
                                                                                   }]};
    
    
    NSMutableDictionary *readMessageTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"readMessage",@"key", nil];
    [self postRequest:readMessage withTag:readMessageTag];
    
    
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
   // [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
   //[ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    
    
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
    
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"isInvited"]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        //NSLog(@"invitation %@",dict);
        self.isInvited = [dict[@"sucess"]integerValue];
        self.isInvitedFlag = 1;
        [self updateUI];
    }else if ([key isEqualToString:@"getEvent"]){
        
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if (arr.count > 0) {
            NSDictionary *dict = arr[0];
            NSLog(@"Full event %@",dict);
            self.fullEvent = dict;
            self.allowComments = [dict[@"comments"]integerValue];
            self.eventDescription = dict[@"description"];
            self.creatorID = [dict[@"CreatorID"]integerValue];
            self.creatorFlag = 1;
            self.approved = [dict[@"approved"]integerValue];
            self.approvedFlag = 1;
            [self getUSer];
            [self updateUI];
            
        }
        
    }else if ([key isEqualToString:@"joinEvent"]){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        //NSLog(@"Joined!! %@",dict);
        if ([dict[@"sucess"]integerValue] == 1) {
            self.isJoined = 1;
            //[self.btnGoing setTitle:@"عدم الذهاب؟" forState:UIControlStateNormal];
            //NSLog(@"bardo 3adam zahab");
            [self updateUI];
        }
    }else if ([key isEqualToString:@"isJoind"]){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        //NSLog(@"Sorry Joined!! %@",dict);
        self.isJoined = [dict[@"sucess"]integerValue];
        [self updateUI];
    }else if ([key isEqualToString:@"leaveEvent"]){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        //NSLog(@"Left  %@",dict);
        if ([dict[@"sucess"]integerValue] == 1) {
            self.isJoined = 0;
        }

        [self updateUI];
    }else if ( [key isEqualToString:@"readMessage"]){
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary *dict = arr[0];
        //NSLog(@"Full event %@",dict);
        NSLog(@"%@",dict);
        self.allowComments = [dict[@"comments"]integerValue];
        self.descriptionLabel.text = dict[@"description"];
        self.creatorID = [dict[@"CreatorID"]integerValue];
        self.creatorName.text = dict[@"name"];
        NSInteger eventPic = [dict[@"picture"]integerValue];
        self.eventSubject.text = dict[@"subject"];
        [self.imgTitle setHidden:NO];
        [self.imgUserProfile setHidden:NO];
        [self.imgPicFrame setHidden:NO];
        [self.lblUsername setHidden:NO];
        [self.btnUser setHidden:NO];
       
        
        
        NSString *dateString = dict[@"timeCreated"];
        [self GenerateArabicDateWithDate:dateString];

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%ld",eventPic];
            NSData *eventData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            self.eventImage = [[UIImage alloc]initWithData:eventData];
            NSString *creatorPic = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",dict[@"ProfilePic"]];
            NSData *creatorData = [NSData dataWithContentsOfURL:[NSURL URLWithString:creatorPic]];
            UIImage *creatorImage = [[UIImage alloc]initWithData:creatorData];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                self.eventPicture.image = self.eventImage;
                self.creatorPicture.image = creatorImage;
                [self.creatorPicture setHidden:NO];
            });
        });
  
        [self updateUI];
    }
    else if ([key isEqualToString:@"getUser"]){
        self.user = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        [self.imgUserProfile setHidden:NO];
        [self.imgPicFrame setHidden:NO];
        [self.lblUsername setHidden:NO];
        [self.btnUser setHidden:NO];
        [self.creatorPicture setHidden:NO];
        self.creatorName.text = self.event[@"CreatorName"];

    }
    
}
- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}


- (IBAction)btnViewAttendeesPressed:(id)sender {
    [self performSegueWithIdentifier:@"showAttendees" sender:self];
}

- (IBAction)btnShowCommentsPressed:(id)sender {
    [self performSegueWithIdentifier:@"showComments" sender:self];
}

- (IBAction)btnGoingPressed:(id)sender {
    if (self.isInvited == 1 && self.isJoined == 1) {
        [self leaveEvent];
    }else if(self.isInvited ==1 && self.isJoined == 0){
        [self joinEvent];
    }
}

- (IBAction)btnEditEventPressed:(id)sender {
    [self performSegueWithIdentifier:@"editEvent" sender:self];
}

- (IBAction)btnShowUserPressed:(id)sender {
    [self performSegueWithIdentifier:@"showUser" sender:self];
}

- (IBAction)btnInviteOthersPressed:(id)sender {
    if (self.isVIP == 0) {
        [self performSegueWithIdentifier:@"invite" sender:self];
    }else if (self.isVIP == 1){
        [self performSegueWithIdentifier:@"inviteAll" sender:self];
    }
    
}

- (IBAction)btnRemindMePressed:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldnotifications = [app scheduledLocalNotifications];
    if (oldnotifications.count > 0) {
        [app cancelAllLocalNotifications];
    }
    
    [self performSegueWithIdentifier:@"chooseDate" sender:self];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
