//
//  EventAttendeesViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "EventAttendeesViewController.h"
#import "AttendeeTableViewCell.h"
#import "ASIHTTPRequest.h"
#import <SVPullToRefresh.h>
#import "UserViewController.h"
@interface EventAttendeesViewController ()

@property (nonatomic,strong) NSMutableArray *allUsers;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger populate;
@property (nonatomic,strong)NSDictionary *selectedUser;
@end

@implementation EventAttendeesViewController

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

    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        self.populate = 1 ;
        self.start = self.start+10 ;
        //self.limit = 10;
        [self getEvents];
    }];
    self.start = 0 ;
    self.limit = 10 ;
    self.allUsers = [[NSMutableArray alloc]init];
    [self getEvents];
    
}

- (void)insertRowAtBottomWithArray:(NSArray *)arr {
    if (arr) {
        __weak EventAttendeesViewController *weakSelf = self;
        
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tableView beginUpdates];
            [self.allUsers addObjectsFromArray:arr];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.allUsers.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
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
    return self.allUsers.count;
}

-(AttendeeTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    AttendeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[AttendeeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *user = self.allUsers[indexPath.row];
    cell.userName.text = user[@"name"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg" ; //needs to be dynamic
        //[NSString stringWithFormat:@"http://www.bixls.com/Qatar/%@",user[@"ProfilePic"]]
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *img = [[UIImage alloc]initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            cell.userImage.image = img;
        });
    });

    
    return cell ;
}

#pragma mark - Table View Delegate Methods 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedUser = self.allUsers[indexPath.row];
    [self performSegueWithIdentifier:@"showUser" sender:self];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserViewController *userController = segue.destinationViewController;
        userController.user = self.selectedUser;
    }
}

#pragma mark - Connection Setup

-(void)getEvents {

    NSDictionary *getUsers = @{@"FunctionName":@"ViewEventAttendees" , @"inputs":@[@{@"eventID":@"2",
                                                                                      @"start":[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.start]],
                                                                                      @"limit":[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.limit]]
                                                                             }]};
    NSMutableDictionary *getUsersTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUsers",@"key", nil];
    
    [self postRequest:getUsers withTag:getUsersTag];
    
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
    
    if ([key isEqualToString:@"getUsers"]&& array && (self.populate == 0)) {
        [self.allUsers addObjectsFromArray:array];
        [self.tableView reloadData];
    }else{
        //[self insertRowAtBottomWithArray:self.receivedArray];
        [self.allUsers addObjectsFromArray:array];
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
    }
    NSLog(@"%@",self.allUsers);
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}





@end
