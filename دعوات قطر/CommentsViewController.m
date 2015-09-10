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
#import "UserViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface CommentsViewController ()

@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger commentID;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSString *myComment;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger selectedUserID;
@property (nonatomic,strong) NSDictionary *selectedUser;

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.comments = [[NSMutableArray alloc]init];
    self.start = 0;
    self.limit = 5;
    [self.navigationItem setHidesBackButton:YES];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [self getComments];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        self.start = self.comments.count;
        [self getComments];
    }];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.comments.count > 0 ) {
        return self.comments.count + 1 ;
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
        cell0.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell0;
        
    }else if (indexPath.row > 0 && indexPath.row <= (self.comments.count) ){
        CommentsSecondTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
        if (cell2==nil) {
            cell2=[[CommentsSecondTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
        }
        if (self.comments.count > 0) {
            NSDictionary *comment = self.comments[indexPath.row - 1];
            NSLog(@"%d",indexPath.row-1);
       //     NSLog(@"%@",comment);
            cell2.userName.text = comment[@"name"];
            cell2.userComment.text = comment[@"comment"];
//            [cell2.userComment addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            
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
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell2;
    }
    
//    else if (indexPath.row == (self.comments.count+1)){
//        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
//        if (cell1==nil) {
//            cell1=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
//        }
//        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell1;
//    }

    
    
    return nil ;
}



#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if (indexPath.row == (self.comments.count+1)){
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSDictionary *comment =self.comments[indexPath.row-1];
        self.selectedUserID = [comment[@"id"]integerValue];
        [self getUSer];
        
    }
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return NO;
    }else if (indexPath.row == (self.comments.count+1)){
        return NO;
    }else{
        return YES;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row >0 &&indexPath.row < (self.comments.count+1)) {
            NSDictionary *comment = self.comments[indexPath.row-1];
            self.commentID = [comment[@"CommentID"]integerValue];

            [self.comments removeObjectAtIndex:(indexPath.row-1)];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self deleteComment];
        }
       
    } else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}



#pragma mark - TextField 

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"RETURNN");
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserViewController *userController = segue.destinationViewController;
        userController.user = self.selectedUser;
    }
}


#pragma mark - Connection Setup
-(void)getUSer {
    
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{
                                                                               @"id":[NSString stringWithFormat:@"%ld",(long)self.selectedUserID]
                                                                               }]};
    
    
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self postRequest:getUser withTag:getUserTag];
    
}

-(void)deleteComment {
    
    NSDictionary *deleteComment = @{@"FunctionName":@"RemoveComment" , @"inputs":@[@{
                                                                                 @"POSTType":[NSString stringWithFormat:@"%ld",(long)self.postType],
                                                                                 @"CommentID":[NSString stringWithFormat:@"%ld",(long)self.commentID],
                                                                    
                                                                                 }]};
    
    NSLog(@"%@",deleteComment);
    NSMutableDictionary *deleteCommentTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"deleteComment",@"key", nil];
    
    [self postRequest:deleteComment withTag:deleteCommentTag];
    
}


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
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView reloadData];
    }else if ([key isEqualToString:@"addComment"]){
        NSLog(@"Add Comment Success %@",array);
        self.start = self.comments.count+1;
        [self getComments];
        
    }else if ([key isEqualToString:@"deleteComment"]){
        NSLog(@"%@",array);
        [self getComments];
    }else if ([key isEqualToString:@"getUser"]){
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.selectedUser = dict;
        [self performSegueWithIdentifier:@"showUser" sender:self];
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
- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
