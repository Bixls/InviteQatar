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
@property (nonatomic,strong) NSString *selectedDate;

@property (nonatomic,strong) NSString *messageDate;
@property (nonatomic,strong) NSString *messageTime;
@property (nonatomic,strong) UIActivityIndicatorView *messageSpinner;

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
    self.limit = 15;
    [self.navigationItem setHidesBackButton:YES];
   
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
        cell.btnRemindMe.tag = indexPath.row;
//        cell.btnRemindMe.tag = 
        if (status == 1 && VIP == 1 ) {
            cell.msgImage.image = [UIImage imageNamed:@"read.png"];
            cell.secondMsgImage.image = [UIImage imageNamed:@"vip2.png"];
            [cell.btnRemindMe setHidden:NO];
            [cell.btnRemindMeFrame setHidden:NO];
        }else if (status == 0 && VIP == 1){
            cell.msgImage.image = [UIImage imageNamed:@"unread.png"];
            cell.secondMsgImage.image = [UIImage imageNamed:@"vip2.png"];
            [cell.btnRemindMe setHidden:NO];
            [cell.btnRemindMeFrame setHidden:NO];
        }
        else if (status == 1){
            cell.msgImage.image = [UIImage imageNamed:@"read.png"];
            [cell.btnRemindMe setHidden:YES];
            [cell.btnRemindMeFrame setHidden:YES];
        }else if (status==0){
            cell.msgImage.image = [UIImage imageNamed:@"unread.png"];
            [cell.btnRemindMe setHidden:YES];
            [cell.btnRemindMeFrame setHidden:YES];
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

    
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (self.messageSpinner) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageSpinner stopAnimating];
        });
    }
    
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
    }else if ([segue.identifier isEqualToString:@"chooseDate"]){
        ChooseDateViewController *chooseDateController = segue.destinationViewController;
        chooseDateController.delegate = self;
//        chooseGroupController.createMsgFlag = 1;
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
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
    
    self.messageSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.messageSpinner.hidesWhenStopped = YES;
    self.messageSpinner.center = self.innerView.center;
    [self.innerView addSubview:self.messageSpinner];
    [self.messageSpinner startAnimating];
    
}

-(void)getMessages {
    
    NSDictionary *getMessages = @{@"FunctionName":@"RetriveInbox" , @"inputs":@[@{@"ReciverID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                             @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                                             @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]}]};
//    NSLog(@"%@",getMessages);
    NSMutableDictionary *getMessagesTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getMessages",@"key", nil];
    [self postRequest:getMessages withTag:getMessagesTag];
    self.messageSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.messageSpinner.hidesWhenStopped = YES;
    self.messageSpinner.center = self.innerView.center;
    [self.self.innerView addSubview:self.messageSpinner];
    [self.messageSpinner startAnimating];
    
}

-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict{
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    NSString *urlString = @"http://da3wat-qatar.com/api/" ;
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

        self.start = self.messages.count;
        [self.scrollView.infiniteScrollingView stopAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageSpinner stopAnimating];
        });
        
        
        [self.tableView reloadData];
        
    }else if ([key isEqualToString:@"deleteMessage"]){
        [self.messageSpinner stopAnimating];
//        NSLog(@"%@",array);
    }

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    [self.messageSpinner stopAnimating];
//    NSLog(@"%@",error);
}

-(void)selectedDate:(NSString *)date{
    self.selectedDate = date;
    //    NSLog(@"%@",self.selectedDate);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [formatter dateFromString:self.selectedDate];
    //    NSLog(@"%@",dateFromString);
    
    UIApplication *app = [UIApplication sharedApplication];
    UILocalNotification *notifyAlarm = [[UILocalNotification alloc]init];
    if (notifyAlarm) {
        notifyAlarm.fireDate = dateFromString;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        notifyAlarm.soundName = UILocalNotificationDefaultSoundName;
        

        notifyAlarm.alertBody = [NSString stringWithFormat:@"لا تنسي %@ بتاريخ %@ الساعة %@",self.messageSubject,self.messageDate,self.messageTime];
        //        NSLog(@"%@",notifyAlarm.alertBody);
        [app scheduleLocalNotification:notifyAlarm];
    }

}

-(void)GenerateArabicDateWithDate:(NSString *)englishDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [formatter dateFromString:englishDate];
    NSString *arabicDate = [formatter stringFromDate:dateString];
    NSString *date = [arabicDate substringToIndex:10];
    NSString *tempTime = [arabicDate substringFromIndex:11];
    NSString *time = [tempTime substringToIndex:5];
    self.messageTime = time;
    
    self.messageDate = [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Buttons

- (IBAction)btnRemindMePressed:(id)sender {
    if ([sender isMemberOfClass:[UIButton class]])
    {
        UIButton *btn = (UIButton *)sender;
        self.selectedMessage = self.messages[btn.tag];
        self.messageSubject = self.selectedMessage[@"Subject"];
        [self GenerateArabicDateWithDate:self.selectedMessage[@"TimeEnded"]];
        
        [self performSegueWithIdentifier:@"chooseDate" sender:self];
    }
   
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
