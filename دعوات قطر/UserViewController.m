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
#import "FullImageViewController.h"
#import "HomePageViewController.h"
@interface UserViewController ()

@property (nonatomic,strong)NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger userTypeFlag;
@property (nonatomic,strong) NetworkConnection *getUserConnection;
@property (nonatomic,strong) NetworkConnection *getEvents;
@property (nonatomic,strong) EventsDataSource *customEvent;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;

@property (weak, nonatomic) IBOutlet UILabel *latestEvents;
@property (weak, nonatomic) IBOutlet UIImageView *latestEventsImg;
@property (weak, nonatomic) IBOutlet UILabel *noEvents;
@property (weak, nonatomic) IBOutlet UIImageView *specialUser;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor ];
    self.userTypeFlag = -1;
    [self.userType setHidden:YES];
    [self.specialUser setHidden:YES];
    [self.latestEventsImg setHidden:YES];
    [self.noEvents setHidden:YES];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    
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
    if (self.eventOrMsg == 0) {
        self.otherUserID = [self.user[@"id"]integerValue];
        
        [self checkIfSameProfile];
        [self updateUIWithUser:self.user];
        
    }else if (self.eventOrMsg == 1){
        self.getUserConnection = [[NetworkConnection alloc]init];
        [self getUSer];
       
        
    }
    if (self.userCurrentGroup == YES) {
        self.userGroup.text = self.defaultGroup;
    }
    
    
    
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
        if (self.events.count == 0) {
            self.eventsCollectionViewHeight.constant = 25;
            [self.noEvents setHidden:NO];
        }
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
    
    
}





#pragma mark - Methods

-(void)updateUIWithUser:(NSDictionary *)user{
    
    self.userName.text = user[@"name"];
    self.userGroup.text = user[@"GName"];
    if (user[@"Type"] != [NSNull null]) {
        self.userTypeFlag = 1;
        [self showOrHideUserType:[user[@"Type"]integerValue]];
    }
    [self checkIfSameProfile];
    
    NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",user[@"ProfilePic"]];
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
        [self.specialUser setHidden:YES];
        [self.userType setHidden:NO];
        self.userType.image = [UIImage imageNamed:@"ownerUser.png"];
    }else if (userType == 1 && self.userTypeFlag == 1){
        [self.userType setHidden:YES];
        [self.specialUser setHidden:NO];
        self.specialUser.image = [UIImage imageNamed:@"vipUser.png"];
    }else if (userType == 0 && self.userTypeFlag == 1){
        [self.userType removeFromSuperview];
        [self.specialUser removeFromSuperview];

    }else{
        [self.userType setHidden:YES];
        [self.specialUser setHidden:YES];
    }
    
}


-(void)checkIfSameProfile{
    [self.latestEventsImg setHidden:NO];
    if (self.otherUserID == self.userID) {
        [self.latestEventsImg setHidden:NO];
        self.latestEvents.text = @"مناسباتي";
    }else{

        self.latestEvents.text = @"آخر المناسبات";
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
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }else if ([segue.identifier isEqualToString:@"fullImage"]){
        FullImageViewController *controller = segue.destinationViewController;
        controller.image = self.userPicture.image;
    }else if ([segue.identifier isEqualToString:@"footer"]){
        FooterContainerViewController *footerController = segue.destinationViewController;
        footerController.delegate = self;
    }
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    HomePageViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"home"]; //
    [self.navigationController pushViewController:homeVC animated:NO];
}

-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Buttons


- (IBAction)btnSendMessagePressed:(id)sender {
    [self performSegueWithIdentifier:@"sendMessage" sender:self];
}

- (IBAction)showFullImage:(id)sender {
    [self performSegueWithIdentifier:@"fullImage" sender:self];
}



@end
