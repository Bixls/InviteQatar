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
//@property (nonatomic,strong) NSMutableArray *normalPackages;
@property (nonatomic,strong) NSArray *VIPPackages;
@property (nonatomic) NSInteger cellPressed;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger invitationID;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLayoutConstraint;


@end

@implementation BuyInvitationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    
    self.VIPPackages = [[NSMutableArray alloc]init];
    
    self.cellPressed =0 ;
   
    [self.navigationItem setHidesBackButton:YES];
    self.productsIdentifiers = [[NSMutableArray alloc]init];
    [self hideLabels];
    

}

-(void)viewDidAppear:(BOOL)animated{
    self.postDict = @{
                      @"FunctionName":@"getInvitationList" ,
                      @"inputs":@[@{@"limit":@"1000"}]};
    NSMutableDictionary *invitationsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invitations",@"key", nil];
    
    [self postRequest:self.postDict withTag:invitationsTag];
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

-(void)hideLabels{
    [self.InvitationsNum setHidden:YES];
    [self.invitationsPrice setHidden:YES];
    [self.invitationsType setHidden:YES];
}


-(void)showLabels{
    [self.InvitationsNum setHidden:NO];
    [self.invitationsPrice setHidden:NO];
    [self.invitationsType setHidden:NO];
}
#pragma mark -Shop Methods

//-(NSArray *)productsIdentifiers{
//    if (!_productsIdentifiers) {
//        _productsIdentifiers = @[@"com.bixls.inviteQatar.normalPlanTest",@"com.bixls.inviteQatar.mediumPlan"];
//    }
//    return _productsIdentifiers;
//}

-(void)validateProductIdentifiers{
    
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithArray:self.productsIdentifiers]];
    request.delegate = self;
    [request start];
    
}

-(void)makeThePurchase{
    SKPayment *payment = [SKPayment paymentWithProduct:self.selectedProduct];
    [[SKPaymentQueue defaultQueue]addPayment:payment];
}

#pragma mark - SKProductsRequest Delegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    self.selectedProduct = response.products.firstObject;
    NSLog(@"%@",response.products);
     NSLog(@"%@",response.invalidProductIdentifiers);
    if ([SKPaymentQueue canMakePayments]) {
        //can make payments
        [self displayStoreUIwithProduct:self.selectedProduct];
    }else{
        //can't make payments
        [self cantBuyAnything];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
//    NSLog(@"Failed to load list of products.");

    
}

- (void)displayStoreUIwithProduct:(SKProduct *)product {
    
    // display local currency
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:product.priceLocale];
    NSString *price = [NSString stringWithFormat:@"Buy for %@", [formatter stringFromNumber:product.price]];
    
    // a UIAlertView brings up the purchase option
    UIAlertView *storeUI = [[UIAlertView alloc]initWithTitle:product.localizedTitle message:product.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:price, nil];
    storeUI.tag = 1;
    [storeUI show];
    
}

-(void)cantBuyAnything{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"عفواً تأكد من فتح الشراء من داخل التطبيقات في الإعدادات" delegate:nil cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
    [alertView show];
}


#pragma mark - Alert View Delegate 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            NSLog(@"Cancel button");
            break;
        }
        case 1:{
            NSLog(@"Buy button");
            
            [self.userDefaults setInteger:self.userID forKey:@"memberID"];
            [self.userDefaults setInteger:self.invitationID forKey:@"invitationID"];
            [self.userDefaults setInteger:0 forKey:@"requestSuccess"];
            [self makeThePurchase];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Table view Methods 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        return self.VIPPackages.count;

}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    CellInvitationTableView *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
    
    if (cell2==nil) {
        cell2=[[CellInvitationTableView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *tempDict = self.VIPPackages[indexPath.row];
    cell2.label00.text = [NSString stringWithFormat:@"$ %@",tempDict[@"price"]];
    cell2.label11.text = tempDict[@"packageName"];
    cell2.label22.text = tempDict[@"number"];
    cell2.backgroundColor = [UIColor clearColor];
    cell2.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.tableViewLayoutConstraint.constant = tableView.contentSize.height;
    
    return cell2;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *nowPressed = [[NSDictionary alloc]init];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    nowPressed = self.VIPPackages[indexPath.row];
    self.invitationID = [nowPressed[@"id"]integerValue];
   // self.selectedProduct = self.allProducts[indexPath.row];
    if ([self.selectedItem isEqual:nowPressed]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedItemType = nil;
        self.selectedItem = nil;
        self.selectedIndexPath = nil;
        self.selectedTableView = nil;
    }else if (self.selectedItem == nil){
        self.selectedItem = self.VIPPackages[indexPath.row];
        self.selectedItemType = @"vip";
        self.selectedIndexPath = indexPath;
        self.selectedTableView = tableView;
    }
    else{
        
     
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفوا" message:@"تم إختيار باقه بالفعل" delegate:self cancelButtonTitle:@"اغلاق" otherButtonTitles:nil, nil];
        [alertView show];
        [tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
    }
    
    switch ([nowPressed[@"id"]integerValue]) {
        case 1:{
            [self.productsIdentifiers addObject:@"com.bixls.inviteQatar.normalPlanTest"];
            break;
        }
        case 2:{
            [self.productsIdentifiers addObject:@"com.bixls.inviteQatar.mediumPlan"];
            break;
        }
            
        default:{
            break;
        }
            
    }
    
    [self validateProductIdentifiers];
    
    
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

    NSData *responseData = [request responseData];
    
    self.responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//    NSLog(@"%@",self.responseArray);
    
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"invitations"]) {
        for (NSDictionary *dict in self.responseArray) {
            self.VIPPackages = self.responseArray;

        }
        
        [self showLabels];
        [self.vipTableView reloadData];
    }else if ([key isEqualToString:@"buyNow"]){
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//        NSLog(@"%@",self.responseArray);
        NSInteger success = [dict[@"success"]integerValue];
        if (success == 1) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"تم شراء الدعوة" delegate:self cancelButtonTitle:@"إغلاق"otherButtonTitles:nil, nil];
            [alertView show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}



#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"header"]) {
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }
}

#pragma mark - Delegate Methods 

-(void)homePageBtnPressed{
     [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)backBtnPressed{
     [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Buttons


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
