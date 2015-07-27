//
//  AllSectionsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "AllSectionsViewController.h"
#import "ASIHTTPRequest.h"
#import "AllSectionsCellCollectionView.h"
#import "AllSectionHeaderCollectionReusableView.h"
#import "AllSectionFooterCollectionReusableView.h"
#import "SecEventsViewController.h"
#import "EventViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>
@interface AllSectionsViewController ()

@property (nonatomic,strong) NSArray *allSections;
@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic) int skeletonSections;
@property (nonatomic) NSMutableDictionary *sectionContent;
@property (nonatomic) int flag;
@property (nonatomic) NSInteger secCount;
@property (nonatomic) NSInteger selectedSection;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSString *selectedSectionName;

@end

@implementation AllSectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.view.backgroundColor = [UIColor blackColor];
    self.secCount = 0;
    self.flag = 0;
    self.sectionContent = [[NSMutableDictionary alloc]init];
    
    //Get All sections first
    [self.navigationItem setHidesBackButton:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    NSDictionary *getAllSections = @{@"FunctionName":@"getEventCategories" , @"inputs":@[@{
                                                                                             }]};
    NSMutableDictionary *getAllSectionsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getSections",@"key", nil];
    [self postRequest:getAllSections withTag:getAllSectionsTag];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",section]];
    if (content.count > 0) {
        return content.count;
    }else{
        return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
     return self.sectionContent.count;
}

-(AllSectionsCellCollectionView *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    
    AllSectionsCellCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (self.allSections.count) {
        NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        if (content) {
            NSLog(@"%@",self.sectionContent);
            NSLog(@"%@",content);
            if (content.count>0) {
                NSDictionary *event = content[indexPath.row];
                cell.eventName.text = event[@"subject"];
                cell.eventCreator.text = event[@"CreatorName"];
                cell.eventDate.text = event[@"TimeEnded"];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    //Background Thread
                    NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",event[@"EventPic"]];
                    //NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                    UIImage *img = [[UIImage alloc]initWithData:data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        //Run UI Updates
                        cell.eventPicture.image = img;
                        
                    });
                });
            }
        }

        // NSArray *content = [self.sectionContent objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section+1]] ;
    }
    return cell;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        AllSectionHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)indexPath.section]];
        if (content.count>0) {
            NSDictionary *event = content[0];
            NSInteger catID = [event[@"catID"]integerValue];
            for (int i = 0; i < self.allSections.count; i++) {
                NSDictionary *section = self.allSections[i];
                if ([section[@"catID"]integerValue]==catID) {
                    header.headerLabel.text = section[@"catName"];
                }
            }
        }
        reusableview = header;
    }
    
    if (kind== UICollectionElementKindSectionFooter) {
        AllSectionFooterCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        footer.btnSeeMore.tag = indexPath.section;
        reusableview = footer;
    }
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSection = indexPath.section ;
    NSArray *content = [self.sectionContent objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]] ;
    self.selectedEvent = content[indexPath.row];
    [self performSegueWithIdentifier:@"enterEvent" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"enterSection"]) {
        SecEventsViewController *secEventsController = segue.destinationViewController;
        secEventsController.selectedSection = self.selectedSection;
        secEventsController.groupID = self.groupID;
        secEventsController.sectionName = self.selectedSectionName;
    }else if ([segue.identifier isEqualToString:@"enterEvent"]){
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
    }
}


#pragma mark - Connection Setup

-(void)getEvents {
    
    for (int i =0 ; i <self.allSections.count ; i++) {
        NSDictionary *section = self.allSections[i];
        NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":[NSString stringWithFormat:@"%ld",(long)self.groupID],
                                                                                 @"catID":[NSString stringWithFormat:@"%@",section[@"catID"]],
                                                                                 @"start":@"0",
                                                                                 @"limit":@"5"}]};//Default values
        NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",section[@"catID"]],@"key", nil];
        
        [self postRequest:getEvents withTag:getEventsTag];
    }
    

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
    
    if ([key isEqualToString:@"getSections"]) {
        self.allSections = array ;
        NSLog(@"%@",array);
        [self getEvents];
        
    }
    
    for (int i = 0 ; i <self.allSections.count; i++) {
        NSDictionary *section = self.allSections[i];
        if ([key isEqualToString:section[@"catID"]]) {
            if (array.count>0) {
                self.skeletonSections = 1;
                NSLog(@"arraay %@",array);
                [self.sectionContent setObject:array forKey:[NSString stringWithFormat:@"%ld",(long)self.secCount]];
                self.secCount++;
                [self.collectionView reloadData];
            }
        }
    }
    
    NSLog(@"%@",self.sectionContent);
    self.flag++;
    if (self.flag == self.allSections.count) {
        [self.collectionView reloadData];
    }

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    //NSLog(@"%@",error);
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)btnSeeMorePressed:(id)sender {
    UIButton *pressedBtn = (UIButton *)sender;
    NSInteger *tempSection = pressedBtn.tag;
    NSArray *content = self.sectionContent[[NSString stringWithFormat:@"%ld",(long)tempSection]];
    NSDictionary *event = content[0];
    NSInteger catID = [event[@"catID"]integerValue];
    for (int i = 0; i < self.allSections.count; i++) {
        NSDictionary *section = self.allSections[i];
        if ([section[@"catID"]integerValue]==catID) {
            self.selectedSection =catID;
            self.selectedSectionName = section[@"catName"];
        }
    }
    NSLog(@"Section : %ld",(long)self.selectedSection);
    
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
