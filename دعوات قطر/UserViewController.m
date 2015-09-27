//
//  UserViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "UserViewController.h"
#import "SendMessageViewController.h"
#import "EventViewController.h"
#import "EventsDataSource.h"

@interface UserViewController ()

@property (nonatomic,strong)NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger userTypeFlag;
@property (nonatomic,strong) NetworkConnection *getUserConnection;
@property (nonatomic,strong) NetworkConnection *getEvents;
@property (nonatomic,strong) EventsDataSource *customEvent;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.userTypeFlag = -1;
    [self.userType setHidden:YES];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    

}

-(void)viewDidAppear:(BOOL)animated{
    if (self.eventOrMsg == 0) {
        self.otherUserID = [self.user[@"id"]integerValue];
        
        [self checkIfSameProfile];
        [self updateUIWithUser:self.user];
        
    }else if (self.eventOrMsg == 1){
        self.getUserConnection = [[NetworkConnection alloc]init];
        
       
        
    }
    if (self.userCurrentGroup == YES) {
        self.userGroup.text = self.defaultGroup;
    }
    
    
    //[self getUSer];
    [self getUserEvents];
    
}


-(void)getUserEvents{
    
    self.getEvents = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        self.events = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        self.customEvent = [[EventsDataSource alloc]initWithEvents:self.events withHeightConstraint:self.eventsCollectionViewHeight andViewController:self withSelectedEvent:^(NSDictionary *selectedEvent) {
            self.selectedEvent = selectedEvent;
        }];
        [self.eventsCollectionView setDelegate:self.customEvent];
        [self.eventsCollectionView setDataSource:self.customEvent];
        [self.eventsCollectionView reloadData];
    }];
    [self.getEvents getUserEventsWithUserID:self.otherUserID startValue:0 limitValue:10000];
    
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

#pragma mark - Connection
-(void)getUSer {
    self.getUserConnection = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        self.user = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        self.userTypeFlag = 1;
        [self updateUIWithUser:self.user];
    }];
    
    [self.getUserConnection getUserWithID:self.otherUserID];
    
//    NSDictionary *getUserDic = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{
//                                                                                  @"id":[NSString stringWithFormat:@"%ld",(long)self.otherUserID]
//                                                                                  }]};
//    
//    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
//    
//    [self.getUserConnection postRequest:getUserDic withTag:getUserTag];
    
}

//#pragma mark - KVO Methods
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if ([keyPath isEqualToString:@"response"]) {
//        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
//        self.user = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        [self updateUIWithUser:self.user];
//    }
//}




#pragma mark - Methods

-(void)updateUIWithUser:(NSDictionary *)user{
    
    self.userName.text = user[@"name"];
    self.userGroup.text = user[@"GName"];
    if (user[@"Type"] != [NSNull null]) {
        self.userTypeFlag = 1;
        [self showOrHideUserType:[user[@"Type"]integerValue]];
    }
    NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",user[@"ProfilePic"]];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.userPicture sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            spinner.center = self.userPicture.center;
            spinner.hidesWhenStopped = YES;
            [self.view addSubview:spinner];
            [spinner startAnimating];
        });

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.userPicture.image = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
        });
        
    }];
    

}

-(void)showOrHideUserType:(NSInteger)userType {
    
    if (userType == 2 && self.userTypeFlag == 1) {
        [self.userType setHidden:NO];
        self.userType.image = [UIImage imageNamed:@"ownerUser.png"];
    }else if (userType == 1 && self.userTypeFlag == 1){
        [self.userType setHidden:NO];
        self.userType.image = [UIImage imageNamed:@"vipUser.png"];
    }else if (userType == 0 && self.userTypeFlag == 1){
        [self.userType removeFromSuperview];
    }else{
        [self.userType setHidden:YES];
    }
    
}


-(void)checkIfSameProfile{
    if (self.otherUserID == self.userID) {
        [self.btnSendMessage setHidden:YES];
        [self.imgSendMessage setHidden:YES];
    }else{
        [self.btnSendMessage setHidden:NO];
        [self.imgSendMessage setHidden:NO];
    }
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"sendMessage"]) {
        SendMessageViewController *sendMessageController = segue.destinationViewController;
        sendMessageController.receiverID = self.otherUserID;
    }else if ([segue.identifier isEqualToString:@"event"]){
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }
}

#pragma mark - Buttons

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnSendMessagePressed:(id)sender {
    [self performSegueWithIdentifier:@"sendMessage" sender:self];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
