//
//  MyProfileViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 3,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "MyProfileViewController.h"
#import "ASIHTTPRequest.h"
#import "EditAccountViewController.h"
#import "EventViewController.h"
#import <Social/Social.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVerticalLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *btnSignOut;

@property (nonatomic) NSInteger userID;
@property (nonatomic) NSInteger groupID;
@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSDictionary *user;
@property (nonatomic,strong) NSString *userMobile;
@property (nonatomic,strong) NSString *userPassword;
@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic, retain) UIDocumentInteractionController *dic;
@property (nonatomic) BOOL finishedLoadingEvents;
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.userPassword = [self.userDefaults objectForKey:@"password"];
    self.userMobile = [self.userDefaults objectForKey:@"mobile"];

    NSLog(@"%d",self.finishedLoadingEvents);
    [self.activateLabel setHidden:YES];
    [self.activateLabel2 setHidden:YES];
    [self.btnSeeMore setHidden:YES];
    [self.imgSeeMore setHidden:YES];
    
//    if ([self.userDefaults integerForKey:@"Guest"]==1) {
//        [self.tableView setHidden:YES];
//        [self.btnSeeMore setHidden:YES];
//        [self.imgSeeMore setHidden:YES];
//        self.smallerView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
//        [self.activateLabel setHidden:NO];
//    }

    
}

-(void)viewDidAppear:(BOOL)animated{
    if (self.userID) {
        [self getUser];
    }
    if (self.userMobile && self.userPassword) {
        NSDictionary *getInvNum = @{
                                    @"FunctionName":@"signIn" ,
                                    @"inputs":@[@{@"Mobile":self.userMobile,
                                                  @"password":self.userPassword}]};
        NSLog(@"%@",getInvNum);
        
        
        NSMutableDictionary *getInvNumTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invNum",@"key", nil];
        [self postRequest:getInvNum withTag:getInvNumTag];
        
    }
    NSDictionary *getEvents = @{@"FunctionName":@"getUserEventsList" , @"inputs":@[@{@"userID":[NSString stringWithFormat:@"%ld",(long)self.userID],@"start":[NSString stringWithFormat:@"%d",0],@"limit":[NSString stringWithFormat:@"%d",3]
                                                                                     }]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    [self postRequest:getEvents withTag:getEventsTag];
    

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

#pragma mark - Table View


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.events.count > 0) {
        [self.btnSeeMore setHidden:NO];
        [self.imgSeeMore setHidden:NO];
        [self.activateLabel setHidden:YES];
        [self.activateLabel2 setHidden:YES];
        return self.events.count ;
    }else if (self.events.count == 0 && self.finishedLoadingEvents == true){
        [self.btnSeeMore removeFromSuperview];
        [self.imgSeeMore removeFromSuperview];
        [self.tableView removeFromSuperview];
        [self.activateLabel setHidden:NO];
        [self.activateLabel2 setHidden:NO];
        return 0;
    }else{
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    if (indexPath.row < self.events.count) {
        
        MyLatestEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell==nil) {
            cell=[[MyLatestEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *tempEvent = self.events[indexPath.row];
        cell.eventName.text =tempEvent[@"subject"];
        cell.eventCreator.text = tempEvent[@"CreatorName"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
        [formatter setLocale:qatarLocale];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",tempEvent[@"TimeEnded"]]];
        NSString *date = [formatter stringFromDate:dateString];
        NSString *dateWithoutSeconds = [date substringToIndex:16];
        cell.eventDate.text = [dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        NSLog(@"%@",date);
        //cell.eventDate.text = tempEvent[@"TimeEnded"];
        
        if ([[tempEvent objectForKey:@"VIP"]integerValue] == 0) {
            [cell.vipImage setHidden:YES];
            [cell.vipLabel setHidden:YES];
        }else{
            [cell.vipImage setHidden:NO];
            [cell.vipLabel setHidden:NO];
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.eventPic.image = image;
            });
            
        });
        
        self.tableVerticalLayoutConstraint.constant = self.tableView.contentSize.height;
        return cell ;
    }
//    else if (indexPath.row == self.events.count){
//        MyLatestEventsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seeMore" forIndexPath:indexPath];
//        if (cell==nil) {
//            cell=[[MyLatestEventsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
//    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.events.count) {
        self.selectedEvent = self.events[indexPath.row];
        [self performSegueWithIdentifier:@"event" sender:self];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"editProfile"]) {
        EditAccountViewController *editAccount = segue.destinationViewController;
        editAccount.userName = self.user[@"name"];
        editAccount.userPic = self.myProfilePicture.image;
        editAccount.groupID = [self.user[@"Gid"]integerValue];
        editAccount.groupName = self.user[@"GName"];
        NSLog(@"%@",self.user[@"GName"]);
        
    }else if ([segue.identifier isEqualToString:@"event"]) {
        
        EventViewController *eventController = segue.destinationViewController;
        eventController.event = self.selectedEvent;
        
    }
}

#pragma mark - Connection Setup

-(void)getUser {
   
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                             }]};
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self postRequest:getUser withTag:getUserTag];
    
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
    NSDictionary *receivedDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    NSLog(@"%@",receivedDict);
    if ([key isEqualToString:@"getUser"]) {
        self.user = receivedDict;
        [self updateUI];
   
    }else if ([key isEqualToString:@"invNum"]){
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        NSString *normal = dict[@"inNOR"];
        NSString *VIP  = dict[@"inVIP"];
        [self.btnInvitationNum setTitle:normal forState:UIControlStateNormal];
        [self.btnVIPNum setTitle:VIP forState:UIControlStateNormal];
        [self.userDefaults setInteger:[VIP integerValue] forKey:@"VIPPoints"];
        [self.userDefaults synchronize];

    }else if ([key isEqualToString:@"getEvents"]){
        NSArray *responseArray =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.events = responseArray;
        self.finishedLoadingEvents = true;
        [self.tableView reloadData];

    }

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

-(void)updateUI {
    self.myName.text = self.user[@"name"];
    self.myGroup.text = self.user[@"GName"];
   // self.groupID = [self.user[@"Gid"]integerValue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.user[@"ProfilePic"]];
        NSURL *imgURL = [NSURL URLWithString:imgURLString];
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        UIImage *image = [[UIImage alloc]initWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.myProfilePicture.image = image;
        });
    });
}
#pragma mark - Action Sheet 
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *fbPostSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            //[fbPostSheet setInitialText:@"This is a Facebook post!"];
            [fbPostSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/qa/app/d-wat-qtr/id1019189072?mt=8"]];
            [self presentViewController:fbPostSheet animated:YES completion:nil];
        } else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:@"Facebook عفواً لا يمكنك النشر الآن ، تأكد من وجود إنترنت و إتصالك بحساب"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }else if (buttonIndex == 1){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {

            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:@"حمل تطبيق دعوات قطر الآن"];
            [tweetSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/qa/app/d-wat-qtr/id1019189072?mt=8"]];
            [self presentViewController:tweetSheet animated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@""
                                      message:@"Facebook عفواً لا يمكنك النشر الآن ، تأكد من وجود إنترنت و إتصالك بحساب"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }

    }else if (buttonIndex == 2){
        
        NSString *url = @"https://itunes.apple.com/qa/app/d-wat-qtr/id1019189072?mt=8 حمل تطبيق دعوات قطر الآن من هنا";
        url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                    (CFStringRef)url,
                                                                                    NULL,
                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                    kCFStringEncodingUTF8));
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",url]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }

    }
}

-(void)shareInsta{
    UIImage *screenShot = [UIImage imageNamed:@"Image"];
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.igo"];
    
    [UIImagePNGRepresentation(screenShot) writeToFile:savePath atomically:YES];
    
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.igo"];
    NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
    
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    self.dic.UTI = @"com.instagram.photo";
    self.dic.annotation = [NSDictionary dictionaryWithObject:@"Enter your caption hereee" forKey:@"InstagramCaption"];
    
    [self.dic presentOpenInMenuFromRect:rect inView:self.view animated:YES];
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://media?id=MEDIA_ID"];
    
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        
    } else {
        
        NSLog(@"No Instagram Found");
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(void)shareInInstagram
{
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"Image"]); //convert image into .png format.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
    
    NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
    
    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
    
    NSLog(@"image saved");
    
    
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIGraphicsEndImageContext();
    NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
    NSLog(@"jpg path %@",jpgPath);
    NSString *newJpgPath = [NSString stringWithFormat:@"file://%@",jpgPath]; //[[NSString alloc] initWithFormat:@"file://%@", jpgPath] ];
    NSLog(@"with File path %@",newJpgPath);
    NSURL *igImageHookFile = [[NSURL alloc] initFileURLWithPath:newJpgPath];
    NSLog(@"url Path %@",igImageHookFile);
    

    
   // self.dic = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
    self.dic=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
    self.dic.delegate = self;
    @{@"InstagramCaption" : @"hooooo"};
    //self.dic.annotation = [NSDictionary dictionaryWithObject:@"Here Give what you want to share" forKey:@"InstagramCaption"];
    self.dic.UTI = @"com.instagram.exclusivegram";
    
    [self.dic presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
    
    
}


#pragma mark - Buttons
- (IBAction)btnSignoutPressed:(id)sender {
    [self.userDefaults setInteger:0 forKey:@"Guest"];
    [self.userDefaults setInteger:0 forKey:@"signedIn"];
    [self.userDefaults setInteger:0 forKey:@"userID"];
    [self.userDefaults setInteger:0 forKey:@"Visitor"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"welcome" sender:self];
}

- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSeeMorePressed:(id)sender {
    [self performSegueWithIdentifier:@"seeMore" sender:self];
}


- (IBAction)btnSharePressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",@"Whatsapp", nil];
    
    [actionSheet showInView:self.view];
}
@end
