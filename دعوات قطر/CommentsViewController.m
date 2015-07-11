//
//  CommentsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "CommentsViewController.h"
#import "ASIHTTPRequest.h"
#import "CommentsFirstTableViewCell.h"
#import "CommentsSecondTableViewCell.h"
@interface CommentsViewController ()

@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger userID;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSString *myComment;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.comments = [[NSMutableArray alloc]init];
    self.start = 0;
    self.limit = 1;
    [self getComments];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.comments.count > 0 ) {
        return self.comments.count +2 ;
    }else{
        return 1;
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.row == 0) {
        CommentsFirstTableViewCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"Cell0" forIndexPath:indexPath];
        if (cell0==nil) {
            cell0=[[CommentsFirstTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell0"];
        }
        cell0.postImage.image = self.postImage;
        cell0.postDescription.text = self.postDescription;
        return cell0;
        
    }else if (indexPath.row > 0 && indexPath.row<(self.comments.count+1) ){
        CommentsSecondTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        if (cell2==nil) {
            cell2=[[CommentsSecondTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
        }
        if (self.comments.count > 0) {
            NSDictionary *comment = self.comments[indexPath.row-1];
            cell2.userName.text = comment[@"name"];
            cell2.userComment.text = comment[@"comment"];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                //Background Thread
                NSString *imageURL = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",comment[@"ProfilePic"]];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                UIImage *img = [[UIImage alloc]initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    cell2.userImage.image = img;
                    
                });
            });
            

        }
        return cell2;
    }else if (indexPath.row == (self.comments.count+1)){
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        if (cell1==nil) {
            cell1=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
        }
        return cell1;
    }

    
    
    return nil ;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TextField 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"RETURNN");
    return YES;
}

#pragma mark - Connection Setup
-(void)addComment {
    
    NSDictionary *addComment = @{@"FunctionName":@"addComment" , @"inputs":@[@{
                                                                                     @"POSTType":[NSString stringWithFormat:@"%ld",(long)self.postType],
                                                                                     @"POSTID":[NSString stringWithFormat:@"%ld",(long)self.postID],
                                                                                     @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                     @"comment":self.myComment
                                                                                     }]};
    
    NSLog(@"%@",addComment);
    NSMutableDictionary *addCommentTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"addComment",@"key", nil];
    
    [self postRequest:addComment withTag:addCommentTag];
    
}

-(void)getComments {
    
    NSDictionary *getEvents = @{@"FunctionName":@"retriveComments" , @"inputs":@[@{
                                                                                 @"POSTType":[NSString stringWithFormat:@"%ld",(long)self.postType], 
                                                                                 @"POSTID":[NSString stringWithFormat:@"%ld",(long)self.postID],
                                                                                 @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                                                 @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]
                                                                                 }]};
    
    NSLog(@"%@",getEvents);
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getComments",@"key", nil];
    
    [self postRequest:getEvents withTag:getEventsTag];
    
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
    if ([key isEqualToString:@"getComments"]) {
        [self.comments addObjectsFromArray:array];
        NSLog(@"%@",self.comments);
        [self.tableView reloadData];
    }else if ([key isEqualToString:@"addComment"]){
        NSLog(@"Add Comment Success %@",array);
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}


- (IBAction)btnSendCommentPressed:(id)sender {
    if (self.textField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عذراً" message:@"تأكد من إدخال نص ال التعليق" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        self.myComment = self.textField.text;
        self.textField.text = nil;
        [self addComment];
        [self.textField resignFirstResponder];
    }
   
}

- (IBAction)btnSeeMorePressed:(id)sender {
    self.start = self.start+1;
    [self getComments];
    NSLog(@"See More! ");
}
@end
