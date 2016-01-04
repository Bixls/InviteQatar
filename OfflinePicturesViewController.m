//
//  OfflinePicturesViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 11,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "OfflinePicturesViewController.h"
#import "OfflinePicturesCollectionViewCell.h"
#import "ASIHTTPRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OfflinePicturesViewController ()

@property (nonatomic,strong) NSArray *imageArray;
@property (nonatomic)NSInteger offlineGroupsFlag;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation OfflinePicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
//    self.imageArray = @[[UIImage imageNamed:@"3emadi.png"],[UIImage imageNamed:@"3etebi.png"],[UIImage imageNamed:@"elka3bi.png"],[UIImage imageNamed:@"elna3emi.png"],[UIImage imageNamed:@"eltamimi.png"],[UIImage imageNamed:@"ka7tani.png"],[UIImage imageNamed:@"kbesi.png"],[UIImage imageNamed:@"mare5i.png"],[UIImage imageNamed:@"eldosri.png"],[UIImage imageNamed:@"elhawager.png"],[UIImage imageNamed:@"elmra.png"],[UIImage imageNamed:@"elmasnad.png"]];
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSArray *avatars = [self.userDefaults objectForKey:@"avatars"];
    if (avatars != nil) {
        self.offlineGroupsFlag = 1 ;
        self.imageArray = avatars;
        [self.collectionView reloadData];
    }
    
    NSDictionary *getAvatars = @{@"FunctionName":@"getAvatarList" , @"inputs":@[@{
                                                                                   }]};
    NSMutableDictionary *getAvatarsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAvatars",@"key", nil];
    
    [self postRequest:getAvatars withTag:getAvatarsTag];
    
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



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    OfflinePicturesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
   
    NSDictionary *tempImage = self.imageArray [indexPath.item];
    
    NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@&t=150x150",tempImage[@"imageID"]];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    [cell.picture sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.picture.image = image;
    
    }];
    

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     OfflinePicturesCollectionViewCell *cell =(OfflinePicturesCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate selectedPicture:cell.picture.image];
    //self.imageArray[indexPath.row]
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict{
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    NSString *urlString = @"http://Bixls.com/api/" ;
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.username =@"admin";
    request.password = @"admin";
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Authorization" value:authValue];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    request.allowCompressedResponse = NO;
    request.useCookiePersistence = NO;
    request.shouldCompressRequestBody = NO;
    request.userInfo = dict;
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    [request startAsynchronous];
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    //NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getAvatars"]) {
        if ([array isEqualToArray:[self.userDefaults objectForKey:@"avatars"]]) {
            //do nothing
        }else{
            self.offlineGroupsFlag = 0;
            self.imageArray = array;
            [self.collectionView reloadData];
            [self.userDefaults setObject:self.imageArray forKey:@"avatars"];
            [self.userDefaults synchronize];
        }
    }
    
    //
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}



- (IBAction)btnDismissPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
