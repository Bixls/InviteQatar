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

@interface EventViewController ()

@property (nonatomic)NSInteger userID;
@property (nonatomic)NSInteger eventID;
@property (nonatomic)NSInteger eventType;
@property (nonatomic)UIImage *eventImage;
@property (nonatomic)NSInteger allowComments;
@property (nonatomic)NSInteger isInvited;
@property (nonatomic)NSInteger isJoined;
@property (nonatomic)NSInteger creatorID;
@property (nonatomic)NSInteger approved;
@property (nonatomic,strong)NSString *eventDescription;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *fullEvent;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic)NSInteger isVIP;

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
    self.isVIP = [self.event[@"VIP"]integerValue];
 
    
    self.navigationItem.backBarButtonItem = backbutton;
    [self.btnAttendees setHidden:YES];
    [self.imgGoingList setHidden:YES];
    [self.imgGoing setHidden:YES];
    [self.btnEditEvent setHidden:YES];
    [self.imgEditEvent setHidden:YES];
    [self.btnInviteOthers setHidden:YES];
    [self.imgInviteOthers setHidden:YES];
    
    self.isJoined = -1;
    self.isInvited =-1;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.eventID = [self.event[@"Eventid"]integerValue];
    self.eventType = 0;
    
    [self.navigationItem setHidesBackButton:YES];
    [self updateUI];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self getInvited];
    if (self.selectedType == 2 || self.selectedType == 3) {
        [self readMessage];
    }else{
        [self getEvent];
    }
    
    [self getJoined];

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

-(void)updateUI {

    NSLog(@"EVEENT %@",self.event);
    if (self.selectedType == 2 || self.selectedType == 3) {
        
    }else{
        self.eventSubject.text = self.event[@"subject"];
        self.creatorName.text = self.event[@"CreatorName"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
        [formatter setLocale:qatarLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",self.event[@"TimeEnded"]]];
        NSString *arabicDate = [formatter stringFromDate:dateString];
       // NSString *dateWithoutSeconds = [arabicDate substringToIndex:16];

       // NSString *dateString = self.event[@"TimeEnded"];
        NSString *date = [arabicDate substringToIndex:10];
        NSString *tempTime = [arabicDate substringFromIndex:11];
        NSString *time = [tempTime substringToIndex:5];
        self.eventTime.text = time;
        self.eventDate.text = date ;
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
    
    if (self.allowComments == 1) {
        [self.btnComments setHidden:NO];
        [self.imgComments setHidden:NO];
            }else{
        [self.btnComments setHidden:YES];
        [self.imgComments setHidden:YES];

    }
    if (self.isInvited == 0) {
        [self.btnGoing setHidden:YES];
        [self.imgGoing setHidden:YES];
    }else if (self.isInvited == 1 && self.userID == self.creatorID){
        [self.btnGoing setHidden:YES];
        [self.imgGoing setHidden:YES];
    }else if (self.isInvited == 1 && self.isJoined == 0){
        [self.btnGoing setHidden:NO];
        [self.imgGoing setHidden:NO];
        [self.btnGoing setTitle:@"الذهاب؟" forState:UIControlStateNormal];
    }else if(self.isInvited == 1 && self.isJoined == 1){
        [self.btnGoing setHidden:NO];
        [self.imgGoing setHidden:NO];
        [self.btnGoing setTitle:@"عدم الذهاب؟" forState:UIControlStateNormal];
    }
    
    if (self.userID == self.creatorID) {
        [self.btnAttendees setHidden:NO];
        [self.imgGoingList setHidden:NO];
        [self.btnEditEvent setHidden:NO];
        [self.imgEditEvent setHidden:NO];

    }else {
        [self.btnAttendees setHidden:YES];
        [self.imgGoingList setHidden:YES];
        [self.btnEditEvent setHidden:YES];
        [self.imgEditEvent setHidden:YES];
    }
    if (self.approved == 1 && self.userID == self.creatorID) {
        [self.btnInviteOthers setHidden:NO];
        [self.imgInviteOthers setHidden:NO];
    }else {
        [self.btnInviteOthers setHidden:YES];
        [self.imgInviteOthers setHidden:YES];
    }

    


}
#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showComments"]) {
        CommentsViewController *commentController = segue.destinationViewController;
        commentController.postID = self.eventID;
        commentController.postImage = self.eventImage;
        commentController.postDescription = self.eventDescription;
        commentController.postType = self.eventType;
    }else if ([segue.identifier isEqualToString:@"showAttendees"]){
        EventAttendeesViewController *eventAttendeesController = segue.destinationViewController;
        eventAttendeesController.eventID = self.eventID;
    }else if ([segue.identifier isEqualToString:@"editEvent"]){
        CreateEventViewController *createEventController = segue.destinationViewController;
        createEventController.createOrEdit = 1;
        createEventController.eventID = self.eventID;
        createEventController.event  = self.fullEvent;
    }else if ([segue.identifier isEqualToString:@"showUser"]){
        UserViewController *userController = segue.destinationViewController;
        userController.user = self.user;
        
    }else if ([segue.identifier isEqualToString:@"invite"]){
        InviteViewController *inviteController = segue.destinationViewController;
        inviteController.creatorID = self.creatorID;
        inviteController.eventID = self.eventID;
        inviteController.normORVIP = 0;
    }else if ([segue.identifier isEqualToString:@"inviteAll"]){
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.flag = 1;
        chooseGroupController.eventID = self.eventID;
    }
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
            self.approved = [dict[@"approved"]integerValue];
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
        self.allowComments = [dict[@"comments"]integerValue];
        self.descriptionLabel.text = dict[@"description"];
        self.creatorID = [dict[@"CreatorID"]integerValue];
        self.creatorName.text = dict[@"name"];
        NSInteger eventPic = [dict[@"picture"]integerValue];
        self.eventSubject.text = dict[@"subject"];
        NSString *dateString = dict[@"timeCreated"];
        NSString *date = [dateString substringToIndex:10];
        NSString *tempTime = [dateString substringFromIndex:11];
        NSString *time = [tempTime substringToIndex:5];
        self.eventTime.text = time;
        self.eventDate.text = date ;
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

            });
        });
  
        [self updateUI];
    }
    else if ([key isEqualToString:@"getUser"]){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"CREATORRR %@",dict);
        self.user = dict;
        
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

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
