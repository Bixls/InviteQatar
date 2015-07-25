//
//  MyEventsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "MyEventsViewController.h"
#import "ASIHTTPRequest.h"
#import <SVPullToRefresh.h>
#import "MyEventsTableViewCell.h"
#import "EventViewController.h"
@interface MyEventsViewController ()

@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger populate;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation MyEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    NSLog(@"%ld",self.userID);

    self.start = 0 ;
    self.limit = 10 ;
    self.allEvents = [[NSMutableArray alloc]init];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        self.populate = 1 ;
        self.start = self.allEvents.count ;
        //self.limit = 10;
        [self getMyEvents];
    }];
    [self getMyEvents];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.allEvents.count;
}

-(MyEventsTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    MyEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[MyEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *event = self.allEvents[indexPath.row];

    cell.eventSubject.text = event[@"subject"];
    cell.eventDate.text = event[@"TimeEnded"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",event[@"EventPic"]] ;
        //[NSString stringWithFormat:@"http://www.bixls.com/Qatar/%@",user[@"ProfilePic"]]
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *img = [[UIImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            cell.eventPicture.image = img;
        });
    });
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedEvent = self.allEvents[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"Event" sender:self];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Event"]) {
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }
}

#pragma mark - Connection Setup

-(void)getMyEvents {
    
    NSDictionary *getEvents = @{@"FunctionName":@"getUserEventsList" , @"inputs":@[@{@"userID":[NSString stringWithFormat:@"%ld",(long)self.userID],@"start":[NSString stringWithFormat:@"%ld",(long)self.start],@"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]
                                                                               }]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
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
    if ([key isEqualToString:@"getEvents"]&& array && (self.populate == 0)) {
        [self.allEvents addObjectsFromArray:array];
        [self.tableView reloadData];
    }else{
        //[self insertRowAtBottomWithArray:self.receivedArray];
        [self.allEvents addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
    }
    NSLog(@"%@",self.allEvents);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
