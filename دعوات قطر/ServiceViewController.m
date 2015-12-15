//
//  ServiceViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 20,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ServiceViewController.h"
#import "NetworkConnection.h"
#import "FullImageViewController.h"
#import "HomePageViewController.h"

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
@property (nonatomic) BOOL visitor;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;

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
    
    self.customAlert.delegate = self;
    [self.customAlertView setHidden:YES];
    [self checkIfVisitor];
    [self addOrRemoveFooter];
    
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

-(void)checkIfVisitor{
    if ([self.userDefaults integerForKey:@"Visitor"] == 1){
        self.visitor = 1;
    }else{
        self.visitor = 0;
    }
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
    }else if ([segue.identifier isEqualToString:@"fullImage"]){
        FullImageViewController *controller = segue.destinationViewController;
        controller.image = self.serviceImageView.image;
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

#pragma mark - Alert View Methods

-(void)showAlertWithMsg:(NSString *)msg alertTag:(NSInteger )tag {
    
    [self.customAlertView setHidden:NO];
    self.customAlert.viewLabel.text = msg ;
    self.customAlert.tag = tag;
}
-(void)customAlertCancelBtnPressed{
    [self.customAlertView setHidden:YES];
    
}

#pragma mark - Buttons

- (IBAction)LikesButton:(id)sender {

    
    if (self.visitor) {
        [self showAlertWithMsg:@"عفواً لا يمكنك إضافة إعجاب إلا بعد تفعيل الحساب" alertTag:0];
    }else{
        [self.likeConnection likePostWithMemberID:self.memberID EventsOrService:@"Service" postID:self.serviceID];
    }

}

- (IBAction)showFullImage:(id)sender {
    [self performSegueWithIdentifier:@"fullImage" sender:self];
    
}



@end
