//
//  FooterContainerViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import "FooterContainerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FooterContainerViewController ()

@property (nonatomic,strong) NetworkConnection *adsConnection;
@property (nonatomic,strong) NetworkConnection *imgConnection;
@property (nonatomic,strong) NSArray *allAds;
@property (nonatomic,strong) NSDictionary *ad1;
@property (nonatomic,strong) NSDictionary *ad2;
@property (nonatomic,strong) NSDictionary *ad3;
@property (nonatomic,strong) NSDictionary *bigAd;

@property (weak, nonatomic) IBOutlet UIButton *ad1Btn;
@property (weak, nonatomic) IBOutlet UIButton *ad2Btn;
@property (weak, nonatomic) IBOutlet UIButton *ad3Btn;
@property (weak, nonatomic) IBOutlet UIButton *bigAdBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bigAdTopFrame;
@property (weak, nonatomic) IBOutlet UIImageView *bigAdBottomFrame;

@property (weak, nonatomic) IBOutlet UIImageView *ad1Img;
@property (weak, nonatomic) IBOutlet UIImageView *ad2Img;
@property (weak, nonatomic) IBOutlet UIImageView *ad3Img;
@property (weak, nonatomic) IBOutlet UIImageView *bigAdImg;


@end

@implementation FooterContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
        self.allAds = responseArray;
        [self setAds];
        [self showAds];
        
    }];
    [self.adsConnection getAdsWithStart:0 andLimit:4];
}
-(void)setAds{
    for (int i = 0; i < 4; i++) {
        NSDictionary *temp  = self.allAds[i];
        switch (i) {
            case 0:{
                self.bigAd = temp;
                break;
            }case 1:{
                self.ad1 = temp;
                break;
            }case 2:{
                self.ad2 = temp;
                break;
            }case 3:{
                self.ad3 = temp;
                break;
            }default:
                break;
        }
    }
    
}

-(void)showAds{
    self.imgConnection = [[NetworkConnection alloc]init];
    for (int i = 0; i < 4; i++) {
        NSDictionary *temp  = self.allAds[i];
        switch (i) {
            case 0:{
               // NSInteger picNumber = [temp[@"adsImage"]integerValue];
                //[self.imgConnection downloadImageWithID:picNumber andImageView:self.bigAdImg];
                [self removeIfDisabled:temp imageView:self.bigAdImg andButton:self.bigAdBtn];
                break;
            }case 1:{
               // NSInteger picNumber = [temp[@"adsImage"]integerValue];
                //[self.imgConnection downloadImageWithID:picNumber andImageView:self.ad1Img];
                [self removeIfDisabled:temp imageView:self.ad1Img andButton:self.ad1Btn];
                break;
            }case 2:{
                //NSInteger picNumber = [temp[@"adsImage"]integerValue];
                //[self.imgConnection downloadImageWithID:picNumber andImageView:self.ad2Img];
                [self removeIfDisabled:temp imageView:self.ad2Img andButton:self.ad2Btn];
                break;
            }case 3:{
               // NSInteger picNumber = [temp[@"adsImage"]integerValue];
               // [self.imgConnection downloadImageWithID:picNumber andImageView:self.ad3Img];
                [self removeIfDisabled:temp imageView:self.ad3Img andButton:self.ad3Btn];
                break;
            }default:
                break;
        }
    }
}

-(void)removeIfDisabled:(NSDictionary *)ad imageView:(UIImageView *)imageV andButton:(UIButton *)btn {
    NSInteger picNumber = [ad[@"adsImage"]integerValue];
    NSInteger status = [ad[@"Enable"]integerValue];
    NSInteger adID = [ad[@"id"]integerValue];
    if (status == 0 && adID == 1) {
        [imageV removeFromSuperview];
        [btn removeFromSuperview];
        [self.bigAdTopFrame removeFromSuperview];
        [self.bigAdBottomFrame removeFromSuperview];
    }else if (status == 0) {
        [imageV removeFromSuperview];
        [btn removeFromSuperview];
    }else if (status == 1){
        [self.imgConnection downloadImageWithID:picNumber andImageView:imageV];
    }
}

-(void)openWebPageWithBtnTag:(NSInteger)tag {
    NSString *webPage = [self searchAllAdsAndGetWebPageWithID:tag];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webPage]];
}

-(NSString *)searchAllAdsAndGetWebPageWithID:(NSInteger)adID{
    for (NSDictionary *tempAd in self.allAds) {
        NSInteger tempID = [tempAd[@"id"]integerValue];
        if (tempID == adID) {
            return tempAd[@"adsURL"];
        }
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

- (IBAction)largeBtnPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self openWebPageWithBtnTag:button.tag];
    NSLog(@"Big Button ");
}

@end
