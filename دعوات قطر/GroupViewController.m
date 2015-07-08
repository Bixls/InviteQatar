//
//  GroupViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "GroupViewController.h"
#import "ASIHTTPRequest.h"
#import <UIKit/UIKit.h>
#import "groupCollectionViewCell.h"
@interface GroupViewController ()

@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSString *eventImageURL;
@property (nonatomic,strong) NSString *eventName;
@property (nonatomic,strong) NSString *eventPlace;
@property (nonatomic,strong) NSString *eventOwner;
@property (nonatomic,strong) NSString *eventTime;

@property (nonatomic) NSInteger groupID;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationItem.backBarButtonItem = nil;
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;

    self.groupID = [self.group[@"id"]integerValue];
    NSLog(@"%ld",(long)self.groupID);
    
    NSDictionary *getEventsDict = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                                                 @"catID":@"-1",
                                                                                 @"start":@"0",@"limit":@"3"}]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    //self.imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg";
//    NSURL *url = [NSURL URLWithString:self.imageURL];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    UIImage *img = [[UIImage alloc]initWithData:data];
   // self.imageView.image = img ;
    
    [self postRequest:getEventsDict withTag:getEventsTag];

}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    [self.btnSeeMoreGroups setTitle:@"المزيد" forState:UIControlStateNormal];
//}
//
//-(void)viewDidDisappear:(BOOL)animated{
//    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.events.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    
    groupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *currentEvent = self.events[indexPath.section];
    cell.subject.text = [currentEvent objectForKey:@"subject"];;
    cell.creator.text = [currentEvent objectForKey:@"CreatorName"];;
    cell.time.text = [currentEvent objectForKey:@"TimeEnded"];;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage *img = [[UIImage alloc]initWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            cell.profilePic.image = img ;
        });
    });

    
    [self.btnMoreGroups setTitle:@"المزيد" forState:UIControlStateNormal];
    

//    self.owner.text =(NSString *)
//    self.date.text = currentEvent [@"TimeEnded"];
   // NSLog(@"%@",currentEvent);
//    NSLog(@"%@",[currentEvent valueForKey:@"CreatorName"]);
    

    
    return cell;

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - Connection setup

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
    self.events = array;
    
    NSLog(@"%@",self.events);
    
    [self.collectionView reloadData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



@end
