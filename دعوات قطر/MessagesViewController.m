//
//  MessagesViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 9,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "MessagesViewController.h"
#import "ASIHTTPRequest.h"
#import "MessagesFirstTableViewCell.h"
#import "ReadMessageViewController.h"
#import "EventViewController.h"
#import "chooseGroupViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

@interface MessagesViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger selectedMessageID;
@property (nonatomic) NSInteger selectedMessageType;
@property (nonatomic,strong)NSMutableArray *messages;
@property (nonatomic,strong)NSDictionary *selectedMessage;
@property(nonatomic)NSInteger profilePicNumber;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *messageSubject;
@property (nonatomic)NSInteger toDeleteMsgID;


@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.backBarButtonItem = nil;
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.view.backgroundColor = [UIColor blackColor];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.messages = [[NSMutableArray alloc]init];
    self.start = 0;
    self.limit = 10;
    [self.navigationItem setHidesBackButton:YES];
    [self getMessages];
}
-(void)viewDidAppear:(BOOL)animated{
    [self getMessages];
    [self.scrollView addInfiniteScrollingWithActionHandler:^{
        self.start = self.messages.count;
        [self getMessages];
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
#pragma mark - TableView DataSource


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.messages.count ;
   
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if(indexPath.row<(self.messages.count)){
        MessagesFirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[MessagesFirstTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
//        NSLog(@"MEssagesss %@",self.messages);
//        NSLog(@"MEssagesss %ld",(long)indexPath.row);
        NSDictionary *message = self.messages[indexPath.row];
        cell.msgSender.text = message[@"name"];
        cell.msgSubject.text = message[@"Subject"];
        NSInteger VIP = [message[@"VIP"]integerValue];
        NSInteger status = [message[@"Status"]integerValue];
        if (status == 1 && VIP == 1 ) {
            cell.msgImage.image = [UIImage imageNamed:@"read.png"];
            cell.secondMsgImage.image = [UIImage imageNamed:@"vip2.png"];
        }else if (status == 0 && VIP == 1){
            cell.msgImage.image = [UIImage imageNamed:@"unread.png"];
            cell.secondMsgImage.image = [UIImage imageNamed:@"vip2.png"];
        }
        else if (status == 1){
            cell.msgImage.image = [UIImage imageNamed:@"read.png"];
        }else if (status==0){
            cell.msgImage.image = [UIImage imageNamed:@"unread.png"];
        }
        
        self.tableVerticalLayoutConstraint.constant = self.tableView.contentSize.height;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
//    else if (indexPath.row == self.messages.count){
//        
//        MessagesFirstTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
//        if (cell1==nil) {
//            cell1=[[MessagesFirstTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
//        }
//        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell1;
//    }
   
    
    return nil ;
}

#pragma mark - TableView Delegate 

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == (self.messages.count)){
        return NO;
    }else{
        return YES;
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ( indexPath.row < (self.messages.count) ) {
            
            NSDictionary *message = self.messages[indexPath.row];
            self.toDeleteMsgID = [message[@"messageID"]integerValue];
            
            [self.messages removeObjectAtIndex:(indexPath.row)];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self deleteMessage];
        }
        
    } else {
//        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessagesFirstTableViewCell *cell = (MessagesFirstTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
   // NSDictionary *message = self.messages[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *selectedMessage = self.messages[indexPath.row];
    self.selectedMessage = selectedMessage;
    self.selectedMessageID = [selectedMessage[@"invitationID"]integerValue];
    self.selectedMessageType = 3;
    [self performSegueWithIdentifier:@"openEvent" sender:self];
    
    NSDictionary *message = self.messages[indexPath.row];
    NSDictionary *mutableMessage = [NSMutableDictionary dictionaryWithDictionary:message];
    [mutableMessage setValue:[NSNumber numberWithInteger:1] forKey:@"Status"];
    self.messages[indexPath.row] = mutableMessage;
    self.messageSubject = selectedMessage[@"Subject"];
   
    
    [self.tableView reloadData];
    
//    if (self.selectedMessageType == 0) {
//        self.profilePicNumber = [selectedMessage[@"ProfilePic"]integerValue];
//        self.messageSubject = selectedMessage[@"Subject"];
//        self.userName = selectedMessage[@"name"];
//        [self performSegueWithIdentifier:@"readMessage" sender:self];
//    }else if (self.selectedMessageType==1){
//        self.messageSubject = selectedMessage[@"Subject"];
//        [self performSegueWithIdentifier:@"readMessage" sender:self];
//    }else if (self.selectedMessageType==2 || self.selectedMessageType == 3){
//        //
//        
//        
//    }
//
//    
//    if (indexPath.row == self.messages.count) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }else{
//        
//    }
    
   

    
}




#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"readMessage"]) {
        ReadMessageViewController *readMessageController = segue.destinationViewController;
        readMessageController.messageID = self.selectedMessageID;
        readMessageController.profilePicNumber = self.profilePicNumber;
        readMessageController.userName = self.userName;
        readMessageController.messageSubject = self.messageSubject;
        readMessageController.messageType = self.selectedMessageType;
        
    }else if ([segue.identifier isEqualToString:@"openEvent"]) {
        EventViewController *eventController = segue.destinationViewController;
        eventController.selectedType = self.selectedMessageType;
        eventController.selectedMessageID = self.selectedMessageID;
        eventController.eventID = [self.selectedMessage[@"EventID"]integerValue];
        eventController.isVIP = [self.selectedMessage[@"VIP"]integerValue];
    }else if ([segue.identifier isEqualToString:@"selectGroup"]){
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.createMsgFlag = 1;
    }
}


#pragma mark - Connection Setup

-(void)deleteMessage {
    
    NSDictionary *deleteMessage = @{@"FunctionName":@"deleteMessege" , @"inputs":@[@{
                                                                                       @"messageID":[NSString stringWithFormat:@"%ld",(long)self.toDeleteMsgID],
                                                                                       
                                                                                       }]};
    
//    NSLog(@"%@",deleteMessage);
    NSMutableDictionary *deleteMessageTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"deleteMessage",@"key", nil];
    
    [self postRequest:deleteMessage withTag:deleteMessageTag];
    
}

-(void)getMessages {
    
    NSDictionary *getMessages = @{@"FunctionName":@"RetriveInbox" , @"inputs":@[@{@"ReciverID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                             @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                                             @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]}]};
//    NSLog(@"%@",getMessages);
    NSMutableDictionary *getMessagesTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getMessages",@"key", nil];
    [self postRequest:getMessages withTag:getMessagesTag];
    
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
    if ([key isEqualToString:@"getMessages"]) {
        
        [self.messages addObjectsFromArray:array];
//        NSLog(@"%@",self.messages);
        self.start = self.messages.count;
        [self.scrollView.infiniteScrollingView stopAnimating];
        [self.tableView reloadData];
        
    }else if ([key isEqualToString:@"deleteMessage"]){
//        NSLog(@"%@",array);
    }

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)newMsgBtnPressed:(id)sender {
//    [self performSegueWithIdentifier:@"selectGroup" sender:self];
//}
@end
