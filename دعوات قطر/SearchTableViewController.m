//
//  SearchTableViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 30,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SearchTableViewController.h"
#import "ASIHTTPRequest.h"
#import "UserViewController.h"

@interface SearchTableViewController ()

@property (nonatomic,strong) NSArray *allValues;
@property (nonatomic,strong) NSMutableArray *filteredValues;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic,strong) NSDictionary *postDict;
@property (nonatomic,strong) NSDictionary *selectedUser;
@property (nonatomic) CGFloat tableX;
@property (nonatomic) CGFloat tableY;
@property (nonatomic) CGFloat tableWidth;
@property (nonatomic) CGFloat tableHeight;
@property (nonatomic) CGFloat navX;
@property (nonatomic) CGFloat navY;
@property (nonatomic) CGFloat navWidth;
@property (nonatomic) CGFloat navHeight;
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton; 
   // self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back"]];
   // self.tableView.backgroundColor = [UIColor clearColor];

    self.tableView.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundView =
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back2"]];
    backgroundView.frame = CGRectMake(0,
                                      0,
                                      self.navigationController.view.frame.size.width,
                                      self.navigationController.view.frame.size.height);
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    [self.navigationController.view insertSubview:backgroundView atIndex:0];

    
    self.postDict = [[NSDictionary alloc]init];
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView reloadData];
    [self.navigationItem setHidesBackButton:YES];
    
    self.tableX = self.view.frame.origin.x + 20 ;
    self.tableY = self.view.frame.origin.y +30;
    self.tableWidth = self.view.frame.size.width -40;
    self.tableHeight = self.view.frame.size.height ;
    
//    CGFloat x = self.view.frame.origin.x - 20 ;
//    CGFloat y  = self.view.frame.origin.y  - 30 ;
//    CGFloat w = self.view.frame.size.width + 40;
//    CGFloat h  = self.view.frame.size.height + 10;
    
    
    self.navX = self.view.frame.origin.x  ;
    self.navY= self.view.frame.origin.y + 55;
    self.navWidth = self.view.frame.size.width ;
    self.navHeight = 20 ;
    
//    CGFloat a = self.view.frame.origin.x - 2 ;
//    CGFloat b = self.view.frame.origin.y- 50 ;
//    CGFloat c = self.view.frame.size.width + 100;
//    CGFloat d = 40 ;
//    
//    [self.view removeConstraints:self.view.constraints];
//    [self.tableView removeConstraints:self.tableView.constraints];
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [self.tableView setFrame:CGRectMake(0, 0, 300, 568)];
//    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 50 , 50);
//    self.tableView.contentInset = inset;
//    [self.view setFrame:CGRectMake(0, 0, 300, 568)];
//    [self.tableView setFrame:CGRectMake(0, 0, 300, 568)];
//    [self.view setFrame:CGRectMake(10, 0, 300, 568)];
//     [self.tableView setFrame:CGRectMake(10, 0, 300, 568)];
    [self.navigationController.navigationBar setFrame:CGRectMake(self.navX , self.navY, self.navWidth , self.navHeight)];
}


-(void)viewDidLayoutSubviews {
//    NSLog(@"%f,%f,%f,%f",self.navX,self.navY , self.navWidth,self.navHeight);
//    NSLog(@"%f,%f,%f,%f",self.tableX,self.tableY , self.tableWidth,self.tableHeight);
//    [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x + 20 , self.view.bounds.origin.y +20 , self.view.bounds.size.width-40, self.view.bounds.size.height -10)];
    
    [self.tableView setFrame:CGRectMake(self.tableX , self.tableY, self.tableWidth , self.tableHeight)];
    [self.navigationController.navigationBar setFrame:CGRectMake(self.navX , self.navY, self.navWidth , self.navHeight)];
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



-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.postDict = @{
                      @"FunctionName":@"searchUsers" ,
                      @"inputs":@[@{@"Key":self.searchController.searchBar.text,
                                    @"start":@"0",
                                    @"limit":@"50000"}]};

    [self postRequest:self.postDict];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",self.searchController.searchBar.text];
    NSArray *arr  = [self.allValues filteredArrayUsingPredicate:searchPredicate];
    self.filteredValues = [NSMutableArray arrayWithArray:arr];
    [self.tableView reloadData];
//    NSLog(@"%@",[NSString stringWithFormat:@"%@",self.searchController.searchBar.text]);
//    [self.tableView setFrame:CGRectMake(0, 0, 300, 568)];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self viewDidAppear:YES];
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
//    [self.tableView setFrame:CGRectMake(0, 0, 300, 568)];
    return YES;
}

//-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    
//    UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"];
//    [cancelBtn setTitle:@"Done" forState:UIControlStateNormal];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchController.active) {
        return self.filteredValues.count;
    }else{
        return self.allValues.count;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (self.searchController.active) {
        NSDictionary *temp = self.filteredValues[indexPath.row];
        cell.textLabel.text = temp[@"name"];
        
    }else {
        cell.textLabel.text = self.allValues[indexPath.row];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view Delegate 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedUser = self.filteredValues[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.searchController.searchBar setHidden:YES];
    [self performSegueWithIdentifier:@"user" sender:self];
}

#pragma mark - Segue 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"user"]) {
        UserViewController *userController = segue.destinationViewController;
        userController.user = self.selectedUser;
        self.searchController.active = NO;
        
    }
}

#pragma mark - Connection Setup

-(void)postRequest:(NSDictionary *)postDict{
    
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
    if (!([self.searchController.searchBar.text isEqual:nil])) {
        [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
        [request startAsynchronous];
    }
   
 
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    //NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    self.filteredValues = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
//    NSLog(@"%@",self.filteredValues);
    [self.tableView reloadData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
