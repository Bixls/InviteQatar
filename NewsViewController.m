//
//  NewsViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 8,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "NewsViewController.h"
#import "ASIHTTPRequest.h"
#import "CommentsViewController.h"
#import "Reachability.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIScrollView+SVInfiniteScrolling.h>
#import "CommentsSecondTableViewCell.h"
#import "UserViewController.h"
#import "FullImageViewController.h"
#import "HomePageViewController.h"

@interface NewsViewController ()

@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic) NSInteger start;
@property (nonatomic) NSInteger limit;
@property (nonatomic,strong)NSString *userInput;
@property (nonatomic)NSInteger userID;
@property (nonatomic,strong) NSUserDefaults *userDefaults;

@property (nonatomic) NSInteger userTypeFlag;
@property(nonatomic)NSInteger newsID;
@property(nonatomic)NSInteger type;
@property(nonatomic)BOOL visitor;
@property(nonatomic)NSInteger selectedUserID;
@property(nonatomic,strong)UIActivityIndicatorView *newsPicSpinner;

@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet customAlertView *customAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnAddComment;
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageAddComment;


@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = nil;
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *backbutton =  [[UIBarButtonItem alloc] initWithTitle:@"عوده" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backbutton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:18],NSFontAttributeName,
                                        nil] forState:UIControlStateNormal];
    backbutton.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.backBarButtonItem = backbutton;
    self.newsID = [self.news[@"NewsID"]integerValue];
    self.type = 1;
    [self.btnComments setHidden:YES];
    [self.imgComments setHidden:YES];
    self.newsSubject.text = self.news[@"Subject"];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus != NotReachable) {
        
        [self downloadNewsPicture];
        
    }
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"تأكد من إتصالك بخدمة الإنترنت" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    self.comments = [[NSMutableArray alloc]init];
    self.start = 0;
    self.limit = 5000;
    
    //Custom Alert
    self.customAlert.delegate = self;
    [self.customAlertView setHidden:YES];
    //Disable or enable interaction
    [self checkIfVisitor];
    
    [self.navigationItem setHidesBackButton:YES];
    [self addOrRemoveFooter];
    
    //Remove Ability to comment if visitor
    if ([self.userDefaults integerForKey:@"Visitor"] == 1) {
        [self removeAbilityToComment];
    }
    
}

-(void)removeAbilityToComment{
    [self.btnAddComment removeFromSuperview];
    [self.imageAddComment removeFromSuperview];
    [self.commentsTextField removeFromSuperview];
    
}

-(void)removeComments{
    [self.btnComments removeFromSuperview];
    [self.imgComments removeFromSuperview];
    [self.btnAddComment removeFromSuperview];
    [self.imageAddComment removeFromSuperview];
    [self.commentsTextField removeFromSuperview];
    [self.commentsTableView removeFromSuperview];
}

-(void)addOrRemoveFooter {
    BOOL remove = [[self.userDefaults objectForKey:@"removeFooter"]boolValue];
    [self removeFooter:remove];
    
}

-(void)adjustFooterHeight:(NSInteger)height{
    self.footerHeight.constant = height;
}

-(void)removeFooter:(BOOL)remove{
    self.footerContainer.clipsToBounds = YES;
    if (remove == YES) {
        self.footerHeight.constant = 0;
    }else if (remove == NO){
        self.footerHeight.constant = 492;
    }
    [self.userDefaults setObject:[NSNumber numberWithBool:remove] forKey:@"removeFooter"];
    [self.userDefaults synchronize];
}

-(void)viewDidAppear:(BOOL)animated{
    
    self.newsPicSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.newsPicSpinner.hidesWhenStopped = YES;
    self.newsPicSpinner.center = self.newsDescription.center;
    [self.innerView addSubview:self.newsPicSpinner];
    [self.newsPicSpinner startAnimating];
    [self getNews];
    

    [self.commentsTableView addInfiniteScrollingWithActionHandler:^{
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

-(void)checkIfVisitor{
    if ([self.userDefaults integerForKey:@"Visitor"] == 1){
        
        self.visitor = 1;
    }else{
        self.visitor = 0;
    }
}

-(void)downloadNewsPicture {
    UIActivityIndicatorView *newsPicSPinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    NSString *imgURLString = [NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",self.news[@"Image"]];
    SDWebImageManager *newsProfileManager = [SDWebImageManager sharedManager];
    [newsProfileManager downloadImageWithURL:[NSURL URLWithString:imgURLString]
                                      options:0
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                         
                                         newsPicSPinner.center = self.newsImage.center;
                                         newsPicSPinner.hidesWhenStopped = YES;
                                         [self.innerView addSubview:newsPicSPinner];
                                         [newsPicSPinner startAnimating];
                                         
                                     }
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                        if (image) {
                                            self.newsImage.image = image;
                                            [newsPicSPinner stopAnimating];
                                        }
                                    }];
}

-(void)updateUI {
    
//    NSLog(@"EVEENT %@",self.news);
    if ([self.news[@"AllowComments"]boolValue] == true) {

        [self.btnComments setHidden:NO];
        [self.imgComments setHidden:NO];
    }else{
        [self removeComments];
    }
    
    [self GenerateArabicDateWithDate:self.news[@"timeCreated"]];
    self.newsDescription.text = self.news[@"Description"];
    
}
#pragma mark - Alert View Methods

-(void)showAlertWithMsg:(NSString *)msg alertTag:(NSInteger )tag {
    
    [self.customAlertView setHidden:NO];
    self.customAlert.viewLabel.text = msg ;
    self.customAlert.tag = tag;
}
-(void)customAlertCancelBtnPressed{
    [self.customAlertView setHidden:YES];
    
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
    self.newsTime.text = time;
    self.newsDate.text = [date stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
}
#pragma mark - Textfield delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.userInput = textField.text;
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showComments"]) {
        CommentsViewController *commentsController = segue.destinationViewController;
//        commentsController.postImage = self.newsImage.image;
//        commentsController.postDescription = self.newsDescription.text;
//        commentsController.postID = self.newsID;
//        commentsController.postType = 1;
    }else if ([segue.identifier isEqualToString:@"header"]){
        HeaderContainerViewController *header = segue.destinationViewController;
        header.delegate = self;
    }else if ([segue.identifier isEqualToString:@"showUser"]){

            UserViewController *userController = segue.destinationViewController;
            userController.otherUserID = self.selectedUserID;
            userController.eventOrMsg = 1;
    }else if ([segue.identifier isEqualToString:@"fullImage"]){
        FullImageViewController *controller = segue.destinationViewController;
        controller.image = self.newsImage.image;
    }else if ([segue.identifier isEqualToString:@"footer"]){
        FooterContainerViewController *footerController = segue.destinationViewController;
        footerController.delegate = self;
    }
    
}

#pragma mark - Comments 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%@",self.comments);
    return self.comments.count;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Comments %@",self.comments);
    
    
    CommentsSecondTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2" forIndexPath:indexPath];
    if (cell2==nil) {
        cell2=[[CommentsSecondTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
    }
    if (self.comments.count > 0) {
        NSDictionary *comment = self.comments[indexPath.row];
        
        cell2.userName.text = comment[@"name"];
        cell2.userComment.text = comment[@"comment"];
        NSInteger userType = [comment[@"Type"]integerValue];
        [self showOrHideUserType:userType andCell:cell2];
        
        [cell2.userImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://Bixls.com/api/image.php?id=%@",comment[@"ProfilePic"]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                NSLog(@"Error downloading images");
            }else{
                cell2.userImage.image = image;
            }
        }];
        
        self.commentsHeightLayoutConstraint.constant = self.commentsTableView.contentSize.height;
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell2;
    }
    
    return nil ;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *comment =self.comments[indexPath.row];
    self.selectedUserID = [comment[@"id"]integerValue];
    self.type = 2;
    [self performSegueWithIdentifier:@"showUser" sender:self];
//    [self getUSerWithID:self.selectedUserID];
    
    
}

-(void)showOrHideUserType:(NSInteger)userType andCell:(CommentsSecondTableViewCell *)cell {
    
    if (userType == 2 && self.userTypeFlag == 1) {
        [cell.userType setHidden:NO];
        cell.userType.image = [UIImage imageNamed:@"ownerUser.png"];
    }else if (userType == 1 && self.userTypeFlag == 1){
        [cell.userType setHidden:NO];
        cell.userType.image = [UIImage imageNamed:@"vipUser.png"];
    }else if (userType == 0 && self.userTypeFlag == 1){
        [cell.userType removeFromSuperview];
    }else{
        [cell.userType setHidden:YES];
    }
    
}



#pragma mark - Connection Setup

-(void)getNews {
    
    NSDictionary *getEvents = @{@"FunctionName":@"GetFullNews" , @"inputs":@[@{
                                                                               @"NewsID":[NSString stringWithFormat:@"%ld",(long)self.newsID]
                                                                               }]};

//    NSLog(@"%@",getEvents);
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getNews",@"key", nil];
    
    [self postRequest:getEvents withTag:getEventsTag];
    
}

-(void)getComments {
    
    NSDictionary *getComments = @{@"FunctionName":@"retriveComments" , @"inputs":@[@{
                                                                                       @"POSTType":[NSString stringWithFormat:@"%d",1],
                                                                                       @"POSTID":[NSString stringWithFormat:@"%ld",(long)self.newsID],
                                                                                       @"start":[NSString stringWithFormat:@"%ld",(long)self.start],
                                                                                       @"limit":[NSString stringWithFormat:@"%ld",(long)self.limit]
                                                                                       }]};
    
    
    NSMutableDictionary *getCommentsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getComments",@"key", nil];
    
    [self postRequest:getComments withTag:getCommentsTag];
    
}


-(void)addComment {
    
    NSDictionary *addComment = @{@"FunctionName":@"addComment" , @"inputs":@[@{
                                                                                 @"POSTType":[NSString stringWithFormat:@"%ld",1],
                                                                                 @"POSTID":[NSString stringWithFormat:@"%ld",(long)self.newsID],
                                                                                 @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                                 @"comment":self.userInput
                                                                                 }]};
    
    
    NSMutableDictionary *addCommentTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"addComment",@"key", nil];
    
    [self postRequest:addComment withTag:addCommentTag];
    
}


-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict{
    
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
    request.userInfo = dict;
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    [request startAsynchronous];
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    //NSString *responseString = [request responseString];
    
    NSData *responseData = [request responseData];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *key = [request.userInfo objectForKey:@"key"];
    if ([key isEqualToString:@"getNews"]) {
        self.news = dictionary;
        [self updateUI];
        [self getComments];
        [self.newsPicSpinner stopAnimating];
        
    }else if ([key isEqualToString:@"getComments"]){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        //NSString *key = [request.userInfo objectForKey:@"key"];
        NSLog(@"%@",array);
        [self.comments removeAllObjects];
        [self.comments addObjectsFromArray:array];
        self.userTypeFlag = 1;
        [self.commentsTableView reloadData];
        [self.commentsTableView.infiniteScrollingView stopAnimating];
        
        NSLog(@"%@",self.comments);
        
        
    }else if ([key isEqualToString:@"addComment"]){
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        if ([dict[@"sucess"]boolValue]) {
            //            self.start = self.comments.count;
            self.start = 0;
            [self getComments];
        }
    }

    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
//    NSLog(@"%@",error);
}

#pragma mark - Header Delegate

-(void)homePageBtnPressed{
    HomePageViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"home"]; //
    [self.navigationController pushViewController:homeVC animated:NO];
}


-(void)backBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)btnSendComment:(id)sender {
    if (self.visitor) {
        [self showAlertWithMsg:@"عفواً لا يمكنك إضافة تعليقات إلا بعد تفعيل الحساب" alertTag:0];
    }else{
        self.userInput = self.commentsTextField.text;
        if (self.userInput.length > 0) {
            self.commentsTextField.text = nil;
            [self addComment];
        }
        
    }
}
- (IBAction)fullImagePressed:(id)sender {
        [self performSegueWithIdentifier:@"fullImage" sender:self];
}

@end
