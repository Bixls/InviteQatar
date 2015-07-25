//
//  UserViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 7,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "UserViewController.h"
#import "SendMessageViewController.h"
@interface UserViewController ()

@property (nonatomic,strong)NSUserDefaults *userDefaults;
@property(nonatomic) NSInteger otherUserID;
@property (nonatomic) NSInteger userID;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = nil;
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID  = [self.userDefaults integerForKey:@"userID"];
    self.otherUserID = [self.user[@"id"]integerValue];
    if (self.otherUserID == self.userID) {
        [self.btnSendMessage setHidden:YES];
        [self.imgSendMessage setHidden:YES];
    }else{
        [self.btnSendMessage setHidden:NO];
        [self.imgSendMessage setHidden:NO];
    }
    NSLog(@"%@",self.user);
    self.userName.text = self.user[@"name"];
    self.userGroup.text = self.user[@"GroupName"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.user[@"ProfilePic"]];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *userImage = [[UIImage alloc]initWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.userPicture.image = userImage;
        });
    });

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"sendMessage"]) {
        SendMessageViewController *sendMessageController = segue.destinationViewController;
        sendMessageController.receiverID = self.otherUserID;
    }
}
- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnSendMessagePressed:(id)sender {
    [self performSegueWithIdentifier:@"sendMessage" sender:self];
}
@end
