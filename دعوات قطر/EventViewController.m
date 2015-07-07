//
//  EventViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "EventViewController.h"
#import "ASIHTTPRequest.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"EVEENT %@",self.event);
    self.eventSubject.text = self.event[@"subject"];
    self.creatorName.text = self.event[@"CreatorName"];
    self.eventDate.text = self.event[@"TimeEnded"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
        NSString *creatorPic = [NSString stringWithFormat:@"http://www.bixls.com/Qatar/%@",self.event[@"CreatorPic"]];
        NSData *eventData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        NSData *creatorData = [NSData dataWithContentsOfURL:[NSURL URLWithString:creatorPic]];
        UIImage *eventImage = [[UIImage alloc]initWithData:eventData];
        UIImage *creatorImage = [[UIImage alloc]initWithData:creatorData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.eventPicture.image = eventImage;
            self.creatorPicture.image = creatorImage;
        });
    });

    
}


#pragma mark - Connection Setup

-(void)getEvents {
    self.eventSubject = self.event[@"subject"];
    self.creatorName = self.event[@"CreatorName"];
    NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":@"2",
                                                                            }]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"sectionEvents",@"key", nil];
    
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
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    
}


- (IBAction)btnViewAttendeesPressed:(id)sender {
    [self performSegueWithIdentifier:@"showAttendees" sender:self];
}
@end
