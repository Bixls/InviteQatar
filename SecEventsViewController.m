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
#import <SDWebImage/UIImageView+WebCache.h>
#import "EventsDataSource.h"
#import "HomePageViewController.h"

@interface SecEventsViewController ()

@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger flag;
@property (nonatomic,strong) NSArray *receivedArray;
@property (nonatomic) NSInteger populate;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic) NSInteger backFLag;
@property (nonatomic,strong) UIActivityIndicatorView *userPicSpinner;
@property (nonatomic,strong) UIActivityIndicatorView *scrollSpinner;
@property (nonatomic,strong) EventsDataSource *customEvent;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;
 
@end

@implementation SecEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
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
    self.view.backgroundColor = [UIColor blackColor];
    self.populate = 0;
    //__weak SecEventsViewController *weakSelf = self;
    // Do any additional setup after loading the view.

    self.start = 0 ;
    self.limit = 10;
    self.allEvents = [[NSMutableArray alloc]init];
    self.sectionNameLabel.text = self.sectionName;
    [self.navigationItem setHidesBackButton:YES];
    self.flag = 1 ;
    self.backFLag = 0 ;
    self.scrollSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.scrollSpinner.hidesWhenStopped = YES;
    self.scrollSpinner.center = self.view.center;
    [self.view addSubview:self.scrollSpinner];
    [self.scrollSpinner startAnimating];
    [self addOrRemoveFooter];
    [self.eventsCollectionView setTransform:CGAffineTransformMakeScale(-1, 1)];
}

-(void)addOrRemoveFooter {
    BOOL remove = [[self.userDefaults objectForKey:@"removeFooter"]boolValue];
    [self removeFooter:remove];
    
}

-(void)adjustFooterHeight:(NSInteger)height{
    self.footerHeight.constant = height;
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
    

    if (self.backFLag != 1){
        [self getEvents];
        self.backFLag = 1 ;
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

//- (void)insertRowAtBottomWithArray:(NSArray *)arr {
//    if (arr) {
//        __weak SecEventsViewController *weakSelf = self;
//        
//        int64_t delayInSeconds = 2.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [weakSelf.tableView beginUpdates];
//            [self.allEvents addObjectsFromArray:arr];
//            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.allEvents.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
//            [weakSelf.tableView endUpdates];
//            [weakSelf.tableView.infiniteScrollingView stopAnimating];
//
//        });
//
//    }
//    
//}

-(NSString *)GenerateArabicDateWithDate:(NSString *)englishDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [formatter dateFromString:englishDate];
    NSString *arabicDate = [formatter stringFromDate:dateString];
    NSString *date = [arabicDate substringToIndex:16];
    return [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
}
#pragma mark - TableView DataSource Methods

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//    
//}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.allEvents.count;
//}
//
//-(SecEventTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *cellIdentifier = @"Cell";
//    
//    SecEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    if (cell==nil) {
//        cell=[[SecEventTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    NSDictionary *event = self.allEvents[indexPath.row];
//    cell.eventSubject.text = event[@"subject"];
//    cell.eventCreator.text = event[@"CreatorName"];
//    cell.eventDate.text = [self GenerateArabicDateWithDate:event[@"TimeEnded"]] ;
//    
//    NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@&t=150x150",event[@"EventPic"]];
//    NSURL *imgURL = [NSURL URLWithString:imgURLString];
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [cell.eventPicture sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        spinner.center = cell.eventPicture.center;
//        spinner.hidesWhenStopped = YES;
//        [cell addSubview:spinner];
//        [spinner startAnimating];
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        cell.eventPicture.image = image;
//        [spinner stopAnimating];
////        NSLog(@"Cache Type %ld",(long)cacheType);
//    }];
//
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell ;
//}
//
//#pragma mark - Delegate Methods
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.selectedEvent = self.allEvents[indexPath.row];
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self performSegueWithIdentifier:@"enterEvent" sender:self];
//
//}

#pragma mark - Segue Method 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"event"]) {
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }else if ([segue.identifier isEqualToString:@"footer"]){
        FooterContainerViewController *footerController = segue.destinationViewController;
        footerController.delegate = self;
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
    NSString *urlString = @"http://Bixls.com/api/" ;
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
        
        if (self.allEvents.count && array.count > 0) {
            for (int i = 0 ; i < self.allEvents.count; i++) {
                for (int j = 0; j < array.count; j++) {
                    NSDictionary *event = self.allEvents[i];
                    NSDictionary *dict = array[j];
                    if ([event isEqualToDictionary:dict]) {
                        //do nothing
                    }else{
                        //[self.allEvents addObjectsFromArray:array];
                        [self.allEvents addObject:array[j]];
//                        [self.tableView reloadData];
                        [self initCollectionView];
                    }
                }
            }
        }else if (array.count > 0){
            [self.allEvents addObjectsFromArray:array];
            [self initCollectionView];
           // [self.tableView reloadData];
        }
    
    }else{
         //[self insertRowAtBottomWithArray:self.receivedArray];
        [self.allEvents addObjectsFromArray:array];
//        [self.tableView reloadData];
        [self initCollectionView];
        [self.scrollView.infiniteScrollingView stopAnimating];
    }
    [self.userPicSpinner stopAnimating];
    [self.scrollSpinner stopAnimating];
//    NSLog(@"%@",self.allEvents);
   
    [self.scrollView addInfiniteScrollingWithActionHandler:^{
        self.populate = 1;
        self.start = self.allEvents.count;
        self.userPicSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.userPicSpinner.hidesWhenStopped = YES;
        self.userPicSpinner.center = self.view.center;
        [self.view addSubview:self.userPicSpinner];
        [self.userPicSpinner startAnimating];
        [self getEvents];
        
    }];
    
    
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
    HomePageViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"home"]; //
    [self.navigationController pushViewController:homeVC animated:NO];
}

-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
