//
//  SecEventsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 5,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SecEventsViewController.h"
#import "ASIHTTPRequest.h"
#import "SecEventTableViewCell.h"
#import "Pods/SVPullToRefresh/SVPullToRefresh/SVPullToRefresh.h"
#import "EventViewController.h"



@interface SecEventsViewController ()

@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic,strong) NSArray *receivedArray;
@property (nonatomic) NSInteger populate;
@property (nonatomic,strong) NSDictionary *selectedEvent;

@end

@implementation SecEventsViewController

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
    
    self.populate = 0;
    //__weak SecEventsViewController *weakSelf = self;
    // Do any additional setup after loading the view.
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        self.populate = 1;
        self.start = self.start+10;
       // self.limit = 10;
        [self getEvents];
       
    }];
    self.start = 0 ;
    self.limit = 10;
    self.allEvents = [[NSMutableArray alloc]init];
    self.sectionNameLabel.text = self.sectionName;
    [self getEvents];
    
}


- (void)insertRowAtBottomWithArray:(NSArray *)arr {
    if (arr) {
        __weak SecEventsViewController *weakSelf = self;
        
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tableView beginUpdates];
            [self.allEvents addObjectsFromArray:arr];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.allEvents.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.tableView endUpdates];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];

        });

    }
    
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allEvents.count;
}

-(SecEventTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    SecEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[SecEventTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *event = self.allEvents[indexPath.row];
    cell.eventSubject.text = event[@"subject"];
    cell.eventCreator.text = event[@"CreatorName"];
    cell.eventDate.text = event[@"TimeEnded"] ;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",event[@"EventPic"]];
       // NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *img = [[UIImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            cell.eventPicture.image = img;
            
        });
    });

    
    return cell ;
}

#pragma mark - Delegate Methods 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedEvent = self.allEvents[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"enterEvent" sender:self];

}

#pragma mark - Segue Method 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"enterEvent"]) {
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }
}


#pragma mark - Connection Setup

-(void)getEvents {
    
        NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                                                 @"catID":[NSString stringWithFormat:@"%ld",(long)self.selectedSection],
                                                                                 @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                                                 @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]}]};
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
    if ([key isEqualToString:@"sectionEvents"]&& array && (self.populate == 0)) {
        [self.allEvents addObjectsFromArray:array];
        [self.tableView reloadData];
    }else{
         //[self insertRowAtBottomWithArray:self.receivedArray];
        [self.allEvents addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
    }
    NSLog(@"%@",self.allEvents);
   
    //
    
    
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
