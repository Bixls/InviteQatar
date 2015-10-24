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
#import <SDWebImage/UIImageView+WebCache.h>
#import "EventsDataSource.h"

@interface MyEventsViewController ()

@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger populate;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) EventsDataSource *customEvent;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;

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
//    NSLog(@"%ld",self.userID);

    self.start = 0 ;
    self.limit = 15 ;
    self.allEvents = [[NSMutableArray alloc]init];
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self addOrRemoveFooter];
}

-(void)addOrRemoveFooter {
    BOOL remove = [[self.userDefaults objectForKey:@"removeFooter"]boolValue];
    [self removeFooter:remove];
    
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

-(void)viewDidAppear:(BOOL)animated{
    [self.scrollView addInfiniteScrollingWithActionHandler:^{
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

#pragma mark - Table View
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
    if ([[event objectForKey:@"VIP"]integerValue] == 0) {
        [cell.vipImage setHidden:YES];
        [cell.vipLabel setHidden:YES];
    }else{
        [cell.vipImage setHidden:NO];
        [cell.vipLabel setHidden:NO];
    }

//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//        //Background Thread
//        NSString *imageURL = [NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%@&t=150x150",event[@"EventPic"]] ;
//        //[NSString stringWithFormat:@"http://www.bixls.com/Qatar/%@",user[@"ProfilePic"]]
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
//        UIImage *img = [[UIImage alloc]initWithData:data];
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            //Run UI Updates
//            cell.eventPicture.image = img;
//        });
//    });
    NSString *imgURLString = [NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%@&t=150x150",event[@"EventPic"]];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.eventPicture sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        spinner.center = cell.eventPicture.center;
        spinner.hidesWhenStopped = YES;
        [cell addSubview:spinner];
        [spinner startAnimating];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.eventPicture.image = image;
        [spinner stopAnimating];
//        NSLog(@"Cache Type %ld",(long)cacheType);
    }];
    
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
    if ([segue.identifier isEqualToString:@"event"]) {
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
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
    NSString *urlString = @"http://da3wat-qatar.com/api/" ;
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
        [self initCollectionView];
        [self.tableView reloadData];
    }else{
        //[self insertRowAtBottomWithArray:self.receivedArray];
        [self.allEvents addObjectsFromArray:array];
        [self initCollectionView];
        //[self.tableView reloadData];
        [self.scrollView.infiniteScrollingView stopAnimating];
    }
//    NSLog(@"%@",self.allEvents);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}

-(void)initCollectionView{
    self.customEvent = [[EventsDataSource alloc]initWithEvents:self.allEvents withHeightConstraint:self.eventsCollectionViewHeight andViewController:self withSelectedEvent:^(NSDictionary *selectedEvent) {
        self.selectedEvent = selectedEvent;
    }];
    [self.eventsCollectionView setDelegate:self.customEvent];
    [self.eventsCollectionView setDataSource:self.customEvent];
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
