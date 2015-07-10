//
//  EditAccountViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 29,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "EditAccountViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface EditAccountViewController ()

@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSString *maskInbox;
@property (nonatomic,strong) NSString *name;
@property (strong,nonatomic) ASIFormDataRequest *imageRequest;
@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic) int uploaded;
@property (nonatomic) int flag;
@property (nonatomic)NSInteger userID;
@property (nonatomic,strong)NSArray *categories;
@property (nonatomic,strong)NSArray *blockList;

@property (weak, nonatomic) IBOutlet UITextField *editNameField;
- (IBAction)btnSavePressed:(id)sender;
- (IBAction)btnChooseImagePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;


@end

@implementation EditAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.blockList = [[NSMutableArray alloc]init];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.maskInbox = [self.userDefaults objectForKey:@"maskInbox"];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    //NSLog(@"EDIT ACC USER ID %ld",(long)self.userID);
    NSInteger first = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:0]] integerValue];
    NSInteger second = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:1]]integerValue];
    NSInteger third = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:2]]integerValue];
    NSInteger fourth = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:3]]integerValue];
    NSInteger fifth = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:4]]integerValue];

//    if (first == 1) {
//        [self.btn1 setTitle:@"الأعراس \u2713" forState:UIControlStateNormal];
//    }else{
//        [self.btn1 setTitle:@"الأعراس" forState:UIControlStateNormal];
//    }
//    
//    if (second == 1) {
//        [self.btn2 setTitle:@"العزاء \u2713" forState:UIControlStateNormal];
//    }else{
//        [self.btn2 setTitle:@"العزاء" forState:UIControlStateNormal];
//    }
//    
//    if (third == 1) {
//        [self.btn3 setTitle:@"تخرج \u2713" forState:UIControlStateNormal];
//    }else{
//        [self.btn3 setTitle:@"تخرج" forState:UIControlStateNormal];
//    }
//
//    if (fourth == 1) {
//        [self.btn4 setTitle:@"تهنيئة \u2713" forState:UIControlStateNormal];
//    }else{
//        [self.btn4 setTitle:@"تهنيئة" forState:UIControlStateNormal];
//    }
//    
//    if (fifth == 1) {
//        [self.btn5 setTitle:@"مناسبات \u2713" forState:UIControlStateNormal];
//    }else{
//        [self.btn5 setTitle:@"مناسبات" forState:UIControlStateNormal];
//    }
    [self getCategories];
    [self getBlockList];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categories.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *category = self.categories[indexPath.row];
    cell.detailTextLabel.text =category[@"catName"];
    NSLog(@"%lu",(unsigned long)self.blockList.count);
    if (self.blockList.count > 0) {
        
        for (NSDictionary *blocked in self.blockList) {
            
            NSInteger blockedID = [blocked[@"InvitationID"]integerValue];
            NSInteger categoryID = [category[@"catID"]integerValue];
            if (blockedID == categoryID) {
                cell.textLabel.text = @"111";
                
            }
        }
    }
    return cell ;
}


#pragma mark - Connection setup

-(void)getCategories {
    
    NSDictionary *getCategories = @{@"FunctionName":@"getEventCategories" , @"inputs":@[@{
                                                                                         }]};
    
    //NSLog(@"%@",getCategories);
    NSMutableDictionary *getCategoriesTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"categories",@"key", nil];
    
    [self postRequest:getCategories withTag:getCategoriesTag];
    
}



-(void)getBlockList {
    
    NSDictionary *getBlockList = @{@"FunctionName":@"GetUserBlockList" , @"inputs":@[@{
                                                                                 @"memberID":[NSString stringWithFormat:@"%ld",(long)self.userID]
                                                                                 }]};
    
   // NSLog(@"%@",getBlockList);
    NSMutableDictionary *getBlockListTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"blocklist",@"key", nil];
    
    [self postRequest:getBlockList withTag:getBlockListTag];
    
}

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
-(void)postPicturewithTag:(NSMutableDictionary *)dict{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    
    
    self.imageRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://bixls.com/Qatar/upload.php"]];
    [self.imageRequest setUseKeychainPersistence:YES];
    self.imageRequest.delegate = self;
    self.imageRequest.username = @"admin";
    self.imageRequest.password = @"admin";
    [self.imageRequest setRequestMethod:@"POST"];
    [self.imageRequest addRequestHeader:@"Authorization" value:authValue];
    [self.imageRequest addRequestHeader:@"Accept" value:@"application/json"];
    [self.imageRequest addRequestHeader:@"content-type" value:@"application/json"];
    self.imageRequest.allowCompressedResponse = NO;
    self.imageRequest.useCookiePersistence = NO;
    self.imageRequest.shouldCompressRequestBody = NO;
    self.imageRequest.userInfo = dict;
    [self.imageRequest setPostValue:[NSString stringWithFormat:@"%d",self.userID] forKey:@"id"];
    [self.imageRequest setPostValue:@"user" forKey:@"type"];
    [self.imageRequest addData:[NSData dataWithData:UIImageJPEGRepresentation(self.profilePic.image, 0.9)] withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"fileToUpload"];
    [self.imageRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{

    NSString *responseString = [request responseString];

    NSData *responseData = [request responseData];
    NSString *key = [request.userInfo objectForKey:@"key"];
    
    if ([key isEqualToString:@"pictureTag"]) {
        NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.imageURL = responseDict[@"url"];
        self.uploaded =1;
    }else if([key isEqualToString:@"save"]){
        NSDictionary *responseDictionary =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    }else if ([key isEqualToString:@"blocklist"]){
        NSArray *response =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.blockList = response;
        [self.tableView reloadData];
        NSLog(@"%@",response);
    }else if ([key isEqualToString:@"categories"]){
         NSArray *response =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.categories = response;
        NSLog(@"%@",self.categories);
        [self.tableView reloadData];
       
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}

-(void)setMarks{
    //
}

#pragma mark - Buttons

- (IBAction)btnSavePressed:(id)sender {
    NSDictionary *postDict = [[NSDictionary alloc]init ];
    NSMutableDictionary *saveTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"save",@"key", nil];
    
    if (self.name.length != 0 ) {
        postDict = @{@"FunctionName":@"editProfile" , @"inputs":@[@{@"id":@"6",
                                                                                  @"name":self.name,
                                                                                  
                                                                                  @"maskInbox":self.maskInbox}]};
        
        
    }else{
        postDict = @{@"FunctionName":@"editProfile" , @"inputs":@[@{@"id":@"6",
                                                                    @"maskInbox":self.maskInbox}]};
    }
    
    if (self.flag == 1) {
        if (self.uploaded==1) {
            [self postRequest:postDict withTag:saveTag];
        }
    }else {
        [self postRequest:postDict withTag:saveTag];
    }
    
    
    
}

- (IBAction)btnChooseImagePressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }

}

#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.profilePic.image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
        
        NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
        [self postPicturewithTag:pictureTag];
        self.flag = 1;
    }
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -TextField
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.editNameField resignFirstResponder];
    self.name = self.editNameField.text;
    return YES;
}

//- (IBAction)btnChecklistPressed:(id)sender {
//
//    NSMutableString *maskInbox = [[NSMutableString alloc]init];
//
//    if (self.maskInbox) {
//        maskInbox = [NSMutableString stringWithString:self.maskInbox];
//    }else{
//        maskInbox = [NSMutableString stringWithString:@"00000"];
//
//    }
//
//
//    if ([sender tag] == 0) {
//
//        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:0]];
//        NSInteger value = [c integerValue];
//        NSInteger notValue = !value;
//        [maskInbox replaceCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
//        self.maskInbox = maskInbox;
//        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
//        [self.userDefaults synchronize];
//       // NSLog(@"%@",maskInbox);
//
//        if (notValue == 1) {
//            [self.btn1 setTitle:@"الأعراس \u2713" forState:UIControlStateNormal];
//        }else{
//            [self.btn1 setTitle:@"الأعراس \u2001" forState:UIControlStateNormal];
//        }
//
//    }else if ([sender tag] == 1){
//
//        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:1]];
//        NSInteger value = [c integerValue];
//        NSInteger notValue = !value;
//        [maskInbox replaceCharactersInRange:NSMakeRange(1, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
//        self.maskInbox = maskInbox;
//        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
//        [self.userDefaults synchronize];
//        //NSLog(@"%@",maskInbox);
//        if (notValue == 1) {
//            [self.btn2 setTitle:@"العزاء \u2713" forState:UIControlStateNormal];
//        }else{
//            [self.btn2 setTitle:@"العزاء \u2001" forState:UIControlStateNormal];
//        }
//
//
//    }else if ([sender tag] == 2){
//
//        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:2]];
//        NSInteger value = [c integerValue];
//        NSInteger notValue = !value;
//        [maskInbox replaceCharactersInRange:NSMakeRange(2, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
//        self.maskInbox = maskInbox;
//        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
//        [self.userDefaults synchronize];
//        //NSLog(@"%@",maskInbox);
//
//        if (notValue == 1) {
//            [self.btn3 setTitle:@"تخرج \u2713" forState:UIControlStateNormal];
//        }else{
//            [self.btn3 setTitle:@"تخرج \u2001" forState:UIControlStateNormal];
//        }
//
//
//
//    }else if ([sender tag] == 3){
//
//        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:3]];
//        NSInteger value = [c integerValue];
//        NSInteger notValue = !value;
//        [maskInbox replaceCharactersInRange:NSMakeRange(3, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
//        self.maskInbox = maskInbox;
//        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
//        [self.userDefaults synchronize];
//        //NSLog(@"%@",maskInbox);
//        if (notValue == 1) {
//            [self.btn4 setTitle:@"تهنيئة \u2713" forState:UIControlStateNormal];
//        }else{
//            [self.btn4 setTitle:@"تهنيئة \u2001" forState:UIControlStateNormal];
//        }
//
//
//    }else if ([sender tag] == 4){
//
//        NSString *c = [NSString stringWithFormat:@"%c", [maskInbox characterAtIndex:4]];
//        NSInteger value = [c integerValue];
//        NSInteger notValue = !value;
//        [maskInbox replaceCharactersInRange:NSMakeRange(4, 1) withString:[NSString stringWithFormat:@"%ld",(long)notValue]];
//        self.maskInbox = maskInbox;
//        [self.userDefaults setValue:maskInbox forKey:@"maskInbox"];
//        [self.userDefaults synchronize];
////        NSLog(@"%@",maskInbox);
//        if (notValue == 1) {
//            [self.btn5 setTitle:@"مناسبات \u2713" forState:UIControlStateNormal];
//        }else{
//            [self.btn5 setTitle:@"مناسبات \u2001" forState:UIControlStateNormal];
//        }
//
//
//    }
//
//
//}

@end
