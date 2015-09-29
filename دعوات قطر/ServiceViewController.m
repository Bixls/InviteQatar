//
//  ServiceViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 20,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ServiceViewController.h"
#import "NetworkConnection.h"

static void *fullServiceContext = &fullServiceContext;
static void *likeContext = &likeContext;
static void *getAllLikesContext = &getAllLikesContext;

@interface ServiceViewController ()

@property (nonatomic,strong) NetworkConnection *getFullServiceConnection;
@property (nonatomic,strong) NetworkConnection *likeConnection;
@property (nonatomic,strong) NetworkConnection *getLikesConnection;
@property (nonatomic) NSInteger serviceID;
@property (nonatomic,strong) NSDictionary *fullService;
@property (nonatomic) NSInteger memberID;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serviceID = [self.service[@"id"]integerValue];
    self.serviceImageView.image = self.serviceImage;
    
    NSString *likes = [NSString stringWithFormat:@"%ld",(long)[self.service[@"Likes"]integerValue]];
    NSString *views = [NSString stringWithFormat:@"%ld",(long)[self.service[@"views"]integerValue]];
    
    self.serviceLikes.text = likes;
    self.serviceViews.text = views;
    self.serviceTitle.text = self.service[@"title"];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.memberID = [self.userDefaults integerForKey:@"userID"];

    
}

-(void)viewDidAppear:(BOOL)animated{
    self.getFullServiceConnection = [[NetworkConnection alloc]init];
    self.likeConnection = [[NetworkConnection alloc]init];
     self.getLikesConnection = [[NetworkConnection alloc]init];
    
    [self.getFullServiceConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:fullServiceContext];
    [self.likeConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:likeContext];
    [self.getLikesConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:getAllLikesContext];
    
    [self.getFullServiceConnection getFullServiceWithID:self.serviceID];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.getFullServiceConnection removeObserver:self forKeyPath:@"response"];
    [self.likeConnection removeObserver:self forKeyPath:@"response"];
    [self.getLikesConnection removeObserver:self forKeyPath:@"response"];
    
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

-(NSString *)arabicNumberFromEnglish:(NSInteger)num {
    NSNumber *someNumber = [NSNumber numberWithInteger:num];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"response"] && context == fullServiceContext) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.fullService = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if (self.fullService) {
            self.serviceDescription.text = self.fullService[@"description"];
        }
    }else if ([keyPath isEqualToString:@"response"] && context == likeContext){
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if ([responseDictionary[@"sucess"]boolValue] == YES) {
            [self.getLikesConnection getAllLikesWithMemberID:self.memberID EventsOrService:@"ServiceLikes" postID:self.serviceID];
        }else{
            //Like is unSuccessful
        }
    }else if ([keyPath isEqualToString:@"response"] && context == getAllLikesContext){
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if (responseDictionary) {
            NSInteger likesNumber = [responseDictionary[@"likes"]integerValue];
            NSString *likes = [NSString stringWithFormat:@"%ld",likesNumber];
            
            self.serviceLikes.text = likes;

            
        }
    }
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"header"]) {
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }
}

#pragma mark - Header Delegate 

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Buttons

- (IBAction)LikesButton:(id)sender {
    [self.likeConnection likePostWithMemberID:self.memberID EventsOrService:@"Service" postID:self.serviceID];
}




@end
