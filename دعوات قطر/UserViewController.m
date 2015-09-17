//
//  UserViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "UserViewController.h"
#import "SendMessageViewController.h"
#import "NetworkConnection.h"

@interface UserViewController ()

@property (nonatomic,strong)NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic,strong) NetworkConnection *getUserConnection;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    
    if (self.eventOrMsg == 0) {
        self.otherUserID = [self.user[@"id"]integerValue];
        [self checkIfSameProfile];
        [self updateUIWithUser:self.user];
        //NSLog(@"%@",self.user);
    }else if (self.eventOrMsg == 1){
        self.getUserConnection = [[NetworkConnection alloc]init];
        [self.getUserConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    if (self.userCurrentGroup == YES) {
        self.userGroup.text = self.defaultGroup;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self getUSer];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.getUserConnection removeObserver:self forKeyPath:@"response"];
    
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

#pragma mark - KVO Methods
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"response"]) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.user = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        [self updateUIWithUser:self.user];
    }
}

#pragma mark - Connection
-(void)getUSer {
    
    NSDictionary *getUserDic = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{
                                                                               @"id":[NSString stringWithFormat:@"%ld",(long)self.otherUserID]
                                                                               }]};
    
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self.getUserConnection postRequest:getUserDic withTag:getUserTag];
    
}


#pragma mark - Methods

-(void)updateUIWithUser:(NSDictionary *)user{
    
    self.userName.text = user[@"name"];
    self.userGroup.text = user[@"GName"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",user[@"ProfilePic"]];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *userImage = [[UIImage alloc]initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.userPicture.image = userImage;
        });
    });
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
