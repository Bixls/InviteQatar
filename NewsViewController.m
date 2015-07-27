//
//  NewsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "NewsViewController.h"
#import "ASIHTTPRequest.h"
#import "CommentsViewController.h"

@interface NewsViewController ()

@property(nonatomic)NSInteger newsID;
@property(nonatomic)NSInteger newsType;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = nil;
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.newsID = [self.news[@"NewsID"]integerValue];
    self.newsType = 1;
    [self.btnComments setHidden:YES];
    [self.imgComments setHidden:YES];
    self.newsSubject.text = self.news[@"Subject"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.news[@"Image"]];
        NSData *newsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *newsImage = [[UIImage alloc]initWithData:newsData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.newsImage.image = newsImage;
        });
    });
    [self.navigationItem setHidesBackButton:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self getNews];
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
    
    NSLog(@"EVEENT %@",self.news);
    if ([self.news[@"AllowComments"]boolValue]) {

        [self.btnComments setHidden:NO];
        [self.imgComments setHidden:NO];
    }else{
        [self.imgComments setHidden:YES];
        [self.btnComments setHidden:YES];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateD = [formatter dateFromString:[NSString stringWithFormat:@"%@",self.news[@"timeCreated"]]];
    NSString *dateString = [formatter stringFromDate:dateD];
  //  NSString *dateWithoutSeconds = [date substringToIndex:16];

    
 //   NSString *dateString = self.news[@"timeCreated"];
    NSString *date = [dateString substringToIndex:10];
    NSString *tempTime = [dateString substringFromIndex:11];
    NSString *time = [tempTime substringToIndex:5];
    self.newsTime.text = time;
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *myDate = [formatter dateFromString:date];
//    NSLog(@"%@",myDate);
//   // NSString *newDate = [formatter stringFromDate:myDate];
//    NSString *localizedDateTime = [NSDateFormatter localizedStringFromDate:myDate dateStyle:NSDateFormatterMediumStyle timeStyle:nil];
//    self.newsDate.text = localizedDateTime ;
    self.newsDate.text = date;
    self.newsDescription.text = self.news[@"Description"];

    
}



#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showComments"]) {
        CommentsViewController *commentsController = segue.destinationViewController;
        commentsController.postImage = self.newsImage.image;
        commentsController.postDescription = self.newsDescription.text;
        commentsController.postID = self.newsID;
    }
}

#pragma mark - Connection Setup

-(void)getNews {
    
    NSDictionary *getEvents = @{@"FunctionName":@"GetFullNews" , @"inputs":@[@{
                                                                               @"NewsID":[NSString stringWithFormat:@"%ld",(long)self.newsID]
                                                                               }]};

    NSLog(@"%@",getEvents);
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getNews",@"key", nil];
    
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
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getNews"]) {
        self.news = dictionary;
        [self updateUI];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
