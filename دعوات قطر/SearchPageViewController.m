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
#import "NetworkConnection.h"

@interface SearchPageViewController ()

@property (nonatomic,strong) NSDictionary *postDict;
@property (nonatomic,strong) NSDictionary *selectedUser;
@property (nonatomic,strong) NetworkConnection *searchUsersConnection;

@end

@implementation SearchPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filteredNames = [[NSMutableArray alloc]init];
    [self.textField addTarget:self
                       action:@selector(textFieldDidChange)
             forControlEvents:UIControlEventEditingChanged];
    
    self.viewHeight.constant = self.view.bounds.size.height - 35;
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.searchUsersConnection = [[NetworkConnection alloc]init];
    [self.searchUsersConnection addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.searchUsersConnection removeObserver:self forKeyPath:@"response"];
    
    for (ASIHTTPRequest *request in ASIHTTPRequest.sharedQueue.operations)
    {
        if(![request isCancelled])
        {
            [request cancel];
            [request setDelegate:nil];
        }
    }
}

#pragma mark - Methods

-(void)textFieldDidChange{
    [self.searchUsersConnection searchDataBaseWithText:self.textField.text];
}

#pragma mark - KVO Methods

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"response"]) {
        NSData *responseData = [change valueForKey:NSKeyValueChangeNewKey];
        self.filteredNames = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",self.filteredNames);
        [self.tableView reloadData];
    }
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


#pragma mark - Buttons

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnHomePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
