//
//  ChooseTypeViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 10,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ChooseTypeViewController.h"
#import "ASIHTTPRequest.h"
#import "ChooseTypeTableViewCell.h"

@interface ChooseTypeViewController ()

@property(nonatomic,strong)NSArray *categories;
@property(nonatomic,strong)NSDictionary *selectedCategory;

@end

@implementation ChooseTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self getCategories];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [self getCategories];
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

-(void)getCategories {
    
    NSDictionary *getCategories = @{@"FunctionName":@"getEventCategories" , @"inputs":@[@{
                                                                                            }]};
    
    NSMutableDictionary *getCategoriesTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"categories",@"key", nil];
    [self postRequest:getCategories withTag:getCategoriesTag];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categories.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    ChooseTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[ChooseTypeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *category = self.categories[indexPath.row];
    cell.rightLabel.text = category[@"catName"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedCategory = self.categories[indexPath.row];
    [self.delegate selectedCategory:self.selectedCategory];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Connection Setup

-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict {
    
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
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    if ([key isEqualToString:@"categories"]) {
        NSArray *response =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.categories = response;
        [self.tableView reloadData];
        NSLog(@"%@",self.categories);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}




- (IBAction)btnClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
