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
@property (nonatomic) NSInteger allAdsRemoved;
@property (nonatomic) BOOL isTopRemoved;
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

-(void)refreshAds{
    self.allAds = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < 3; i++ )
    {
        [self.allAds addObject:[NSNull null]];
    }
    [self initAds];
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
                BOOL removed =[self removeIfDisabled:temp imageView:self.topAdImg andButton:self.topAdBtn];
                if (removed) {
                    self.allAdsRemoved ++ ;
                }else{
                    self.isTopRemoved = NO;
                }
               // [self.imgConnection downloadImageWithID:picNumber andImageView:self.topAdImg];
                break;
            }case 1:{
                //NSInteger picNumber = [temp[@"adsImage"]integerValue];
                //[self.imgConnection downloadImageWithID:picNumber andImageView:self.rightAdImg];
                BOOL removed = [self removeIfDisabled:temp imageView:self.rightAdImg andButton:self.rightAdBtn];
                if (removed) {
                    self.allAdsRemoved ++ ;
                }
                break;
            }case 2:{
               // NSInteger picNumber = [temp[@"adsImage"]integerValue];
               // [self.imgConnection downloadImageWithID:picNumber andImageView:self.leftAdImg];
                BOOL removed = [self removeIfDisabled:temp imageView:self.leftAdImg andButton:self.leftAdBtn];
                if (removed) {
                    self.allAdsRemoved ++ ;
                }
                if ([self isAllRemoved] == YES) {
                    //call delegate
                    [self.delegate removeContainerIfEmpty:YES withContainerID:self.containerID];
                    self.allAdsRemoved = 0;
                }else if ([self isTopOnly] == YES){
                    [self.delegate setContainerHeight:75 withContainerID:self.containerID];
                }
                break;
            }default:
                break;
        }
    }
}

-(BOOL)isAllRemoved {
    if (self.allAdsRemoved == 3) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)isTopOnly{
    if (self.isTopRemoved == NO && self.allAdsRemoved == 2) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)removeIfDisabled:(NSDictionary *)ad imageView:(UIImageView *)imageV andButton:(UIButton *)btn {
    NSInteger picNumber = [ad[@"adsImage"]integerValue];
    NSInteger status = [ad[@"Enable"]integerValue];
    if (status == 0) {
        [imageV removeFromSuperview];
        [btn removeFromSuperview];
        return YES;
    }else if (status == 1){
        [self.imgConnection downloadImageWithID:picNumber andImageView:imageV];
        return NO;
    }
    else return NO;
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
