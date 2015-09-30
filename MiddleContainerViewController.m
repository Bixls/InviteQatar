//
//  MiddleContainerViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import "MiddleContainerViewController.h"

@interface MiddleContainerViewController ()
@property (nonatomic,strong) NetworkConnection *adsConnection;
@property (nonatomic,strong) NetworkConnection *imgConnection;
@property (nonatomic,strong) NSMutableArray *allAds;
@property (nonatomic,strong) NSDictionary *ad1;
@property (nonatomic,strong) NSDictionary *ad2;
@property (nonatomic,strong) NSDictionary *ad3;

@property (weak, nonatomic) IBOutlet UIImageView *topAdImg;
@property (weak, nonatomic) IBOutlet UIImageView *rightAdImg;
@property (weak, nonatomic) IBOutlet UIImageView *leftAdImg;
@property (weak, nonatomic) IBOutlet UIButton *topAdBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightAdBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftAdBtn;



@end

@implementation MiddleContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.allAds = [[NSMutableArray alloc]init];
}

-(void)viewDidAppear:(BOOL)animated{
    [self initAds];
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

-(void)initAds{
    self.adsConnection = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        if (self.containerID == 0) {
            [self getFirstThreeAds:responseArray];

        }else if (self.containerID == 1){
            [self getLastThreeAds:responseArray];
        }
        [self setAds];
        [self showAds];
        
//        [self setAds];
//        [self showAds];
        
    }];
    [self.adsConnection getAdsWithStart:4 andLimit:6];
}

-(void)getFirstThreeAds:(NSArray *)response{
    for (int i = 0; i < 3; i ++) {
        [self.allAds addObject:response[i]];
    }
}
-(void)getLastThreeAds:(NSArray *)response{
    for (int i = 3; i < 6; i ++) {
        [self.allAds addObject:response[i]];
    }
}

-(void)setAds{
    for (int i = 0; i < 3; i++) {
        NSDictionary *temp  = self.allAds[i];
        switch (i) {
            case 0:{
                self.ad1 = temp;
                break;
            }case 1:{
                self.ad2 = temp;
                break;
            }case 2:{
                self.ad3 = temp;
                break;
            }default:
                break;
        }
    }
}

-(void)showAds{
    self.imgConnection = [[NetworkConnection alloc]init];
    for (int i = 0; i < 3; i++) {
        NSDictionary *temp  = self.allAds[i];
        switch (i) {
            case 0:{
                NSInteger picNumber = [temp[@"adsImage"]integerValue];
                [self.imgConnection downloadImageWithID:picNumber andImageView:self.topAdImg];
                break;
            }case 1:{
                NSInteger picNumber = [temp[@"adsImage"]integerValue];
                [self.imgConnection downloadImageWithID:picNumber andImageView:self.rightAdImg];
                break;
            }case 2:{
                NSInteger picNumber = [temp[@"adsImage"]integerValue];
                [self.imgConnection downloadImageWithID:picNumber andImageView:self.leftAdImg];
                break;
            }default:
                break;
        }
    }
}

-(void)openWebPageWithBtnTag:(NSInteger)tag {
    NSString *webPage = [self searchAllAdsAndGetWebPageWithID:tag];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webPage]];
}

-(NSString *)searchAllAdsAndGetWebPageWithID:(NSInteger)adID{
    if (adID < self.allAds.count) {
        NSDictionary *tempAd = self.allAds[adID];
        return tempAd[@"adsURL"];
    }
    return nil;
}


- (IBAction)firstBtnPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
    NSLog(@"first Button");
}

- (IBAction)secondBtnPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
    NSLog(@"second Button");
}

- (IBAction)thirdBtnPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
    NSLog(@"Third Button");
}


@end
