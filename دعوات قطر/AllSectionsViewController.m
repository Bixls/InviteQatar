//
//  AllSectionsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 4,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "AllSectionsViewController.h"
#import "ASIHTTPRequest.h"
#import "AllSectionsCellTableViewCell.h"

@interface AllSectionsViewController ()

@property (nonatomic,strong) NSArray *allSections;
@property (nonatomic,strong) NSMutableArray *allEvents;
@property (nonatomic) int skeletonSections;
@property (nonatomic) NSMutableArray *sectionContent;
@property (nonatomic) int flag;

@end

@implementation AllSectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flag = 0;
    // Do any additional setup after loading the view.
    self.sectionContent = [[NSMutableArray alloc]init];
    NSDictionary *getAllSections = @{@"FunctionName":@"getEventCategories" , @"inputs":@[@{
                                                                                             }]};
    NSMutableDictionary *getAllSectionsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getSections",@"key", nil];
    
    [self postRequest:getAllSections withTag:getAllSectionsTag];
    
    
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.allSections.count;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.sectionContent.count) {
        NSArray *content = self.sectionContent[section];
        return content.count;
    }
    else{
        return 1;
    }
}


-(AllSectionsCellTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    AllSectionsCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[AllSectionsCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.flag == self.allSections.count) {
        NSArray *content = self.sectionContent[indexPath.section];
        NSLog(@"%@",content);
        if (content.count) {
            NSDictionary *event = content[indexPath.row];
            cell.eventName.text = event[@"subject"];
            cell.eventCreator.text = event[@"CreatorName"];
            cell.eventDate.text = event[@"TimeEnded"];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background Thread
                NSString *imageURL = @"http://www.bixls.com/Qatar/uploads/user/201507/6-02032211.jpg"; //needs to be dynamic
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                UIImage *img = [[UIImage alloc]initWithData:data];
                UIView *sectionView = [self.tableView headerViewForSection:indexPath.section];
                [self.tableView bringSubviewToFront:sectionView];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    cell.eventPicture.image = img;
                    
                });
            });
                    }
    }
    
    return cell;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc]init];
//    NSDictionary *Dict = self.allSections[section];
//    label.text = [NSString stringWithFormat:@"%@  ",Dict[@"catName"]];
//    label.backgroundColor =[UIColor clearColor];
//    label.textAlignment = NSTextAlignmentRight;
//
//    
//    return label.text;
//}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    // 1. The view for the header
//    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
//    
//    // 2. Set a custom background color and a border
//    headerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
//    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
//    headerView.layer.borderWidth = 1.0;
//    
//    // 3. Add a label
//    UILabel* headerLabel = [[UILabel alloc] init];
//    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.textColor = [UIColor whiteColor];
//    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
//    headerLabel.text = @"This is the custom header view";
//    headerLabel.textAlignment = NSTextAlignmentLeft;
//    
//    // 4. Add the label to the header view
//    [headerView addSubview:headerLabel];
//    
//    // 5. Finally return
//    return headerView;
//}



//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc]init];
//    NSDictionary *Dict = self.allSections[section];
//    label.text = [NSString stringWithFormat:@"%@",Dict[@"catName"]];
//    label.backgroundColor =[UIColor clearColor];
//    label.textAlignment = NSTextAlignmentRight;
//    label.textColor = [UIColor whiteColor];
//
//    
//    return label;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 22;
//}

//- (NSIndexPath *)tableView:(UITableView *)tableView
//targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
//       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
//{
//    if (proposedDestinationIndexPath.section != sourceIndexPath.section)
//    {
//        //keep cell where it was...
//        return sourceIndexPath;
//    }
//    
//    //ok to move cell to proposed path...
//    return proposedDestinationIndexPath;
//}



-(void)getEvents {
    
    for (int i =1 ; i <=self.allSections.count ; i++) {
       
        NSDictionary *getEvents = @{@"FunctionName":@"getEvents" , @"inputs":@[@{@"groupID":@"2",
                                                                                 @"catID":[NSString stringWithFormat:@"%d",i],
                                                                                 @"start":@"0",
                                                                                 @"limit":@"5"}]};
        NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
        [self postRequest:getEvents withTag:getEventsTag];
    }
    

}



#pragma mark - Connection Setup

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
        [self getEvents];
        [self.tableView reloadData];
    }
    
    if ([key isEqualToString:@"getEvents"]) {
        self.skeletonSections = 1;
        [self.sectionContent addObject:array];
        self.flag++;
        if (self.flag == self.allSections.count) {
            [self.tableView reloadData];
        }
    }
    NSLog(@"%@",array);
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



@end
