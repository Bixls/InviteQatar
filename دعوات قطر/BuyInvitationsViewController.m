//
//  BuyInvitationsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "BuyInvitationsViewController.h"

#import "ASIHTTPRequest.h"
#import "CellInvitationTableView.h"

@interface BuyInvitationsViewController ()


@property(nonatomic,strong) NSDictionary *postDict;
@property(nonatomic,strong) NSArray *responseArray;
@property(nonatomic,strong) NSDictionary *selectedItem;
@property(nonatomic,strong) NSString *selectedItemType;
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)UITableView *selectedTableView;
@property (nonatomic,strong) NSMutableArray *normalPackages;
@property (nonatomic,strong) NSMutableArray *VIPPackages;
@property (nonatomic) NSInteger cellPressed;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic) int userID;

@end

@implementation BuyInvitationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    
    self.normalPackages = [[NSMutableArray alloc]init];
    self.VIPPackages = [[NSMutableArray alloc]init];
    
    self.cellPressed =0 ;
    self.postDict = @{
                      @"FunctionName":@"getInvitationList" ,
                      @"inputs":@[@{@"limit":@"1000"}]};
    NSMutableDictionary *invitationsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invitations",@"key", nil];
    
    [self postRequest:self.postDict withTag:invitationsTag];
    
}

#pragma mark - Table view Methods 


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag ==0) {
        return self.normalPackages.count;
    }else{
        return self.VIPPackages.count;
    }
    
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    
    
    
    if (tableView.tag == 0) {
        CellInvitationTableView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[CellInvitationTableView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSDictionary *tempDict = self.normalPackages[indexPath.row];
        cell.label0.text = [NSString stringWithFormat:@"$ %@",tempDict[@"price"]];
        cell.label1.text = tempDict[@"packageName"];
        cell.label2.text = tempDict[@"number"];
        cell.backgroundColor = [UIColor clearColor];
       
        return cell;
    }if (tableView.tag == 1){
        CellInvitationTableView *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        if (cell2==nil) {
            cell2=[[CellInvitationTableView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSDictionary *tempDict = self.VIPPackages[indexPath.row];
        cell2.label00.text = [NSString stringWithFormat:@"$ %@",tempDict[@"price"]];
        cell2.label11.text = tempDict[@"packageName"];
        cell2.label22.text = tempDict[@"number"];
        cell2.backgroundColor = [UIColor clearColor];
        return cell2;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *nowPressed = [[NSDictionary alloc]init];
    
    if (tableView.tag==0) {
        nowPressed =self.normalPackages[indexPath.row];
    }else {
        nowPressed = self.VIPPackages[indexPath.row];
    }
    
    
    
    if (tableView.tag == 0 && [self.selectedItemType isEqualToString:@"normal"] && [self.selectedItem isEqual:nowPressed]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedItemType = nil;
        self.selectedItem = nil;
        self.selectedIndexPath = nil;
        self.selectedTableView = nil;
    }else if (tableView.tag == 1 && [self.selectedItemType isEqualToString:@"vip"] && [self.selectedItem isEqual:nowPressed]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedItemType = nil;
        self.selectedItem = nil;
        self.selectedIndexPath = nil;
        self.selectedTableView = nil;
    }else if (self.selectedItemType ==nil) {
        if (tableView.tag == 0) {
            self.selectedItem = self.normalPackages[indexPath.row];
            self.selectedItemType = @"normal";
            self.selectedIndexPath = indexPath;
            self.selectedTableView = tableView;
        }else{
            self.selectedItem = self.VIPPackages[indexPath.row];
            self.selectedItemType = @"vip";
            self.selectedIndexPath = indexPath;
            self.selectedTableView = tableView;
        }
    }else{
       
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفوا" message:@"تم إختيار باقه بالفعل" delegate:self cancelButtonTitle:@"اغلاق" otherButtonTitles:nil, nil];
        [alertView show];
        [self.selectedTableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
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
    // Use when fetching text data
    NSString *responseString = [request responseString];
    //NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    
    self.responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@",self.responseArray);
    
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"invitations"]) {
        for (NSDictionary *dict in self.responseArray) {
            if ([dict[@"VIP"]intValue]==0) {
                [self.normalPackages addObject:dict];
                
            }else{
                [self.VIPPackages addObject:dict];
            }
        }
        
        [self.tableView reloadData];
        [self.vipTableView reloadData];
    }
    

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



- (IBAction)btnBuyNowPressed:(id)sender {
    
    
    int id = [self.selectedItem[@"id"]integerValue] ;
    
    self.postDict = @{
                      @"FunctionName":@"addInvPoints" ,
                      @"inputs":@[@{@"memberID":[NSString stringWithFormat:@"%d",self.userID],@"invitationID":[NSNumber numberWithInt:id]}]};
//    if (self.cellPressed==1) {
//        [self postRequest:self.postDict];
//    }
    NSMutableDictionary *buyNowTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"buyNow",@"key", nil];
    
    if (self.selectedIndexPath) {
        [self postRequest:self.postDict withTag:buyNowTag];
    }
    
}
@end
