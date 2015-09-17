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

    
//
    
    
    if (self.offlineGroupsFlag ==0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempImage[@"imageID"]];
//            NSLog(@"%@",imgURLString);
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{

                cell.picture.image = image;
 
                NSData *imageData = UIImagePNGRepresentation(image);
                NSData *encodedDate = [NSKeyedArchiver archivedDataWithRootObject:imageData];
                [self.userDefaults setObject:encodedDate forKey:tempImage[@"imageID"]];
                [self.userDefaults synchronize];
                
                //                    [self.groupImages addObject:@"plus"];
                //                    [self.userDefaults setObject:self.groupImages forKey:@"groupImages"];
                //                    [self.userDefaults synchronize];
            });
        });
        
    }else if (self.offlineGroupsFlag == 1){
        //self.groupImages = [self.userDefaults objectForKey:@"groupImages"];
        //            if (self.groupImages.count >0) {
        //NSDictionary *tempGroup = self.groups[indexPath.item];
        NSData *encodedObject =[self.userDefaults objectForKey:tempImage[@"imageID"]];
        if (encodedObject) {
            NSData *imgData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            UIImage *img =  [UIImage imageWithData:imgData];
            cell.picture.image = img;
        }
    }

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
    NSString *urlString = @"http://bixls.com/Qatar/" ;
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
