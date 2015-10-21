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

    self.allAds = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < 3; i++ )
    {
        [self.allAds addObject:[NSNull null]];
    }

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
        if (responseArray.count > 0) {
            if (self.containerID == 0) {
                [self getFirstThreeAds:responseArray];
                
            }else if (self.containerID == 1){
                [self getLastThreeAds:responseArray];
            }
            [self setAds];
            [self showAds];
        }
    }];
    [self.adsConnection getAdsWithStart:4 andLimit:6];
}

-(void)getFirstThreeAds:(NSArray *)response{

        for (int i = 0; i < 3; i ++) {
            [self.allAds replaceObjectAtIndex:i withObject:response[i]];

        }


}
-(void)getLastThreeAds:(NSArray *)response{

    for (int i = 3; i < 6; i ++) {
        [self.allAds replaceObjectAtIndex:(i-3) withObject:response[i]];

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
                //NSInteger picNumber = [temp[@"adsImage"]integerValue];
                [self removeIfDisabled:temp imageView:self.topAdImg andButton:self.topAdBtn];
               // [self.imgConnection downloadImageWithID:picNumber andImageView:self.topAdImg];
                break;
            }case 1:{
                //NSInteger picNumber = [temp[@"adsImage"]integerValue];
                //[self.imgConnection downloadImageWithID:picNumber andImageView:self.rightAdImg];
                [self removeIfDisabled:temp imageView:self.rightAdImg andButton:self.rightAdBtn];
                break;
            }case 2:{
               // NSInteger picNumber = [temp[@"adsImage"]integerValue];
               // [self.imgConnection downloadImageWithID:picNumber andImageView:self.leftAdImg];
                [self removeIfDisabled:temp imageView:self.leftAdImg andButton:self.leftAdBtn];
                break;
            }default:
                break;
        }
    }
}

-(void)removeIfDisabled:(NSDictionary *)ad imageView:(UIImageView *)imageV andButton:(UIButton *)btn {
    NSInteger picNumber = [ad[@"adsImage"]integerValue];
    NSInteger status = [ad[@"Enable"]integerValue];
    if (status == 0) {
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
