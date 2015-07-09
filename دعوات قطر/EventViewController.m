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

@interface EventViewController ()

@property (nonatomic)NSInteger userID;
@property (nonatomic)NSInteger eventID;
@property (nonatomic)NSInteger eventType;
@property (nonatomic)UIImage *eventImage;
@property (nonatomic)NSInteger allowComments;
@property (nonatomic,strong)NSString *eventDescription;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

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
    self.navigationItem.backBarButtonItem = backbutton;
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.eventID = [self.event[@"Eventid"]integerValue];
    self.eventType = 0;
    
    [self updateUI];
    [self isInvited];
    [self getEvent];
   
    
}

-(void)updateUI {

    NSLog(@"EVEENT %@",self.event);
    self.eventSubject.text = self.event[@"subject"];
    self.creatorName.text = self.event[@"CreatorName"];
    NSString *dateString = self.event[@"TimeEnded"];
    NSString *date = [dateString substringToIndex:10];
    NSString *tempTime = [dateString substringFromIndex:11];
    NSString *time = [tempTime substringToIndex:5];
    self.eventTime.text = time;
    self.eventDate.text = date ;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.event[@"EventPic"]];
        NSString *creatorPic = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.event[@"CreatorPic"]];
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
    if (self.allowComments == 1) {
        [self.btnComments setHidden:NO];
    }else{
        [self.btnComments setHidden:YES];
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
    }
}

#pragma mark - Connection Setup

-(void)getEvent {
    
    NSDictionary *getEvent = @{@"FunctionName":@"getEventbyID" , @"inputs":@[@{
                                                                                 @"Eventid":[NSString stringWithFormat:@"%ld",(long)self.eventID]
                                                                                 }]};
    
    NSLog(@"%@",getEvent);
    NSMutableDictionary *getEventTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvent",@"key", nil];
    
    [self postRequest:getEvent withTag:getEventTag];
    
}



-(void)isInvited {
    NSInteger eventID = [self.event[@"Eventid"] integerValue];
    NSDictionary *getEvents = @{@"FunctionName":@"isInvited" , @"inputs":@[@{
                                                                               @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                               @"eventID":[NSString stringWithFormat:@"%ld",(long)eventID]
                                                                            }]};
    //[NSString stringWithFormat:@"%ld",(long)self.userID]
    //[NSString stringWithFormat:@"%ld",(long)eventID]
    NSLog(@"%@",getEvents);
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"isInvited",@"key", nil];
    
    [self postRequest:getEvents withTag:getEventsTag];
    
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
        NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",array);
    }else if ([key isEqualToString:@"getEvent"]){
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"Full event %@",dict);
        self.allowComments = [dict[@"comments"]integerValue];
        self.eventDescription = dict[@"description"];
        [self updateUI];
    }
    
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
@end
