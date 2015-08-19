//
//  SearchPageViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 19,8//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SearchPageViewController.h"
#import "ASIHTTPRequest.h"
#import "UserViewController.h"

@interface SearchPageViewController ()

@property (nonatomic,strong) NSDictionary *postDict;
@property (nonatomic,strong) NSDictionary *selectedUser;

@end

@implementation SearchPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filteredNames = [[NSMutableArray alloc]init];
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange)
             forControlEvents:UIControlEventEditingChanged];
    [self.navigationItem setHidesBackButton:YES];
    self.viewHeight.constant = self.view.bounds.size.height - 35;
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


-(void)textFieldDidChange{
    [self searchDataBaseWithText:self.textField.text];
}


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"user"]) {
        UserViewController *userController = segue.destinationViewController;
        userController.user = self.selectedUser;
        
    }
}


#pragma mark - Table View Datasource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filteredNames.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *user = self.filteredNames[indexPath.row];
    cell.detailTextLabel.text = user[@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell ;
}

#pragma mark - Table view Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedUser = self.filteredNames[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.searchController.searchBar setHidden:YES];
    [self performSegueWithIdentifier:@"user" sender:self];
}


#pragma mark - Connection Setup

-(void)searchDataBaseWithText:(NSString*)text {
    self.postDict = @{
                      @"FunctionName":@"searchUsers" ,
                      @"inputs":@[@{@"Key":text,
                                    @"start":@"0",
                                    @"limit":@"50000"}]};
    
    [self postRequest:self.postDict];
}

-(void)postRequest:(NSDictionary *)postDict{
    
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
    if (self.textField.text.length > 0) {
        [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
        [request startAsynchronous];
    }
    
    
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    NSData *responseData = [request responseData];
    self.filteredNames = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSLog(@"%@",self.filteredNames);
    [self.tableView reloadData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

#pragma mark - Buttons

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnHomePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
