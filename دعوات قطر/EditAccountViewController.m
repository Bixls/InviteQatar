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
#import "EditAccountTableViewCell.h"

@interface EditAccountViewController ()

@property (nonatomic,strong) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSString *maskInbox;
@property (nonatomic,strong) NSString *name;
@property (strong,nonatomic) ASIFormDataRequest *imageRequest;
@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic) int uploaded;
@property (nonatomic) int flag;
@property (nonatomic) NSInteger launched;
@property (nonatomic) NSInteger chooseFlag;
@property (nonatomic)NSInteger userID;
@property (nonatomic)NSInteger btnPressed;
@property (nonatomic,strong)NSArray *categories;
@property (nonatomic,strong)NSArray *blockList;
@property (nonatomic,strong)NSMutableArray *listArray;
@property (nonatomic,strong)NSDictionary *user;
@property (nonatomic) NSInteger saved0;
@property (nonatomic) NSInteger saved1;
@property (nonatomic) NSInteger empty;
@property (nonatomic,strong)NSDictionary *selectedGroup;
@property (nonatomic) NSInteger selectedGroupID;
@property (nonatomic,strong) NSMutableArray *selectedRows;
@property (weak, nonatomic) IBOutlet UITextField *editNameField;
- (IBAction)btnSavePressed:(id)sender;
- (IBAction)btnChooseImagePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectedGroup;


@end

@implementation EditAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.blockList = [[NSMutableArray alloc]init];
    self.listArray = [[NSMutableArray alloc]init];
    self.selectedRows = [[NSMutableArray alloc]init];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.maskInbox = [self.userDefaults objectForKey:@"maskInbox"];
    self.userID = [self.userDefaults integerForKey:@"userID"];
    self.editNameField.text = self.userName;
    [self.btnSelectedGroup setTitle:self.groupName forState:UIControlStateNormal];
    NSLog(@"%@",self.groupName);
    [self.navigationItem setHidesBackButton:YES];
    self.selectedGroupID = self.groupID;
    self.chooseFlag = 0;
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.chooseFlag != 1 ) {
        self.editNameField.text = self.userName;
        if (self.userPic) {
            self.profilePic.image = self.userPic;
        }else{
            [self getUser];
        }
        [self getCategories];
        [self getBlockList];
    }else if (self.chooseFlag ==1 ){
        self.chooseFlag = 0;
    }
   
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

-(void)selectedGroup:(NSDictionary *)group{
    self.selectedGroup = group;
    [self.btnSelectedGroup setTitle:self.selectedGroup[@"name"] forState:UIControlStateNormal];
    self.selectedGroupID =[self.selectedGroup[@"id"]integerValue];
    NSLog(@"%@",group);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.categories.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    EditAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[EditAccountTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *category = self.categories[indexPath.row];
    cell.detailLabel.text =category[@"catName"];
    NSLog(@"%lu",(unsigned long)self.blockList.count);
    
    if (self.blockList.count > 0) {
        for (NSDictionary *blocked in self.listArray) {
            NSInteger blockedID = [blocked[@"id"]integerValue];
            NSInteger categoryID = [category[@"catID"]integerValue];
            if (blockedID == categoryID) {
                cell.leftLabel.text = @"\u2713";
                [self.selectedRows addObject:indexPath];
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

        cell.leftLabel.text = @"";
        
        //    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
        for(NSIndexPath *i in self.selectedRows)
        {
            if([i isEqual:indexPath])
            {
                cell.leftLabel.text = @"\u2713";
            }
        }



    return cell ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EditAccountTableViewCell *cell =(EditAccountTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *category = self.categories[indexPath.row];
    
    if (self.blockList.count > 0 ) {
        for (NSDictionary *blocked in self.blockList) {
            NSInteger blockedID = [blocked[@"InvitationID"]integerValue];
            NSInteger categoryID = [category[@"catID"]integerValue];
            
            if (blockedID == categoryID && [cell.leftLabel.text isEqualToString:@"\u2713"]) {
//                cell.leftLabel.text = @"";
                NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
                [self.listArray removeObject:selected];
                [self.selectedRows removeObject:indexPath];
//                NSLog(@"%@",self.listArray);
                  [tableView reloadData];
                return;
            }else if (blockedID == categoryID){
//                cell.leftLabel.text = @"\u2713";
                NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
                [self.listArray addObject:selected];
                [self.selectedRows addObject:indexPath];
//                NSLog(@"%@",self.listArray);
                  [tableView reloadData];
                return;
            }else if (blockedID !=categoryID && [cell.leftLabel.text isEqualToString:@""]){
//                cell.leftLabel.text = @"\u2713";
                NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
                [self.listArray addObject:selected];
                [self.selectedRows addObject:indexPath];
//                NSLog(@"%@",self.listArray);
                  [tableView reloadData];
                return;
            }else if (blockedID !=categoryID && [cell.leftLabel.text isEqualToString:@"\u2713"]){
//                cell.leftLabel.text = @"";
                NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
                [self.listArray removeObject:selected];
                [self.selectedRows removeObject:indexPath];
               // NSLog(@"%@",self.listArray);
                  [tableView reloadData];
                return;
            }
        }
    }else if (self.empty == 1){
        NSInteger categoryID = [category[@"catID"]integerValue];

        if ([cell.leftLabel.text isEqualToString:@"\u2713"]) {
            //cell.leftLabel.text = @"";
            NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
            [self.listArray removeObject:selected];
            [self.selectedRows removeObject:indexPath];
            //NSLog(@"%@",self.listArray);
              [tableView reloadData];
            return;
        }
//            else if (blockedID == categoryID){
//            cell.leftLabel.text = @"\u2713";
//            NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
//            [self.listArray addObject:selected];
//            NSLog(@"%@",self.listArray);
//            return;
        else if ([cell.leftLabel.text isEqualToString:@""]){
            //cell.leftLabel.text = @"\u2713";
            NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
            [self.listArray addObject:selected];
            [self.selectedRows addObject:indexPath];
           // NSLog(@"%@",self.listArray);
              [tableView reloadData];
            return;
        }
//        else if (blockedID !=categoryID && [cell.leftLabel.text isEqualToString:@"\u2713"]){
//            cell.leftLabel.text = @"";
//            NSDictionary *selected = @{@"id":[NSString stringWithFormat:@"%ld",(long)categoryID]};
//            [self.listArray removeObject:selected];
//            NSLog(@"%@",self.listArray);
//            return;
//        }
//
    }
  
    
}

#pragma mark - Connection setup

-(void)getUser {
    
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)self.userID],
                                                                             }]};
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self postRequest:getUser withTag:getUserTag];
    
}


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
    [self.imageRequest setPostValue:[NSString stringWithFormat:@"%ld",(long)self.userID] forKey:@"id"];
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
        NSLog(@"%@",responseDict);
        self.uploaded =1;
    }else if ([key isEqualToString:@"blocklist"]){
        NSArray *response =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.blockList = response;
//        [self.selectedRows addObjectsFromArray:self.blockList];
        if (self.blockList.count == 0){
            self.empty = 1;
        }
        for (NSDictionary *invit in self.blockList) {
            NSInteger invitID = [invit[@"InvitationID"]integerValue];
            NSDictionary *dict = @{@"id":[NSString stringWithFormat:@"%ld",(long)invitID]};
            [self.listArray addObject:dict];
        }
        [self.tableView reloadData];

        NSLog(@"%@",response);
    }else if ([key isEqualToString:@"categories"]){
         NSArray *response =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.categories = response;
        NSLog(@"%@",self.categories);
        [self.tableView reloadData];
       
    }else if ([key isEqualToString:@"getUser"]){
        NSDictionary *responseDict =[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        self.user = responseDict;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@",self.user[@"ProfilePic"]];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profilePic.image = image;
            });
        });
    }else if ([key isEqualToString:@"editBlockList"]){
        self.saved0 = 1;
    }else if([key isEqualToString:@"editName"]){
        self.saved1 = 1;
    }
    
    
    if (self.saved0 ==1 && self.saved1 ==1 ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"تم تعديل الحساب بنجاح" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
        self.saved0 = 0;
        self.saved1 = 0 ;
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if (error) {
        if (self.btnPressed == 1) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عفواً" message:@"لم يتم تعديل الحساب" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
            self.btnPressed = 0;

        }
    }
    NSLog(@"%@",error);
}



#pragma mark - Buttons

- (IBAction)btnSavePressed:(id)sender {
    NSDictionary *editName = [[NSDictionary alloc]init ];
    NSDictionary *editBlockList = [[NSDictionary alloc]init ];
    NSMutableDictionary *editNameTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"editName",@"key", nil];
    NSMutableDictionary *editBlockListTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"editBlockList",@"key", nil];
    
    if (self.editNameField.text.length != 0) {
        editName = @{@"FunctionName":@"editProfile" , @"inputs":@[@{@"id":[NSString stringWithFormat:
                                                                           @"%ld",self.userID],
                                                                    @"name":self.editNameField.text,
                                                                    @"groupID":[NSString stringWithFormat:@"%ld",(long)self.selectedGroupID],
                                                                    
                                                                                    }]};
        editBlockList = @{@"FunctionName":@"SetBlockList" , @"inputs":@[@{@"memberID":[NSString stringWithFormat:@"%ld",self.userID],
                                                                    @"listArray":self.listArray,
    
                                                                    }]};
        if (self.flag == 1) {
            NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
            self.btnPressed = 1;
            [self postPicturewithTag:pictureTag];

            [self postRequest:editName withTag:editNameTag];
            [self postRequest:editBlockList withTag:editBlockListTag];
            
           
        }else {
            self.btnPressed = 1;
            [self postRequest:editName withTag:editNameTag];
            [self postRequest:editBlockList withTag:editBlockListTag];
            
        }
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"عذرا" message:@"من فضلك تأكد من إدخال الإسم" delegate:self cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
    
}

-(void)selectedPicture:(UIImage *)image{
    self.profilePic.image = image;
    [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
    
    NSMutableDictionary *pictureTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"pictureTag",@"key", nil];
   // [self postPicturewithTag:pictureTag];
    self.flag = 1;

}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([segue.identifier isEqualToString:@"offlinePic"]){
        OfflinePicturesViewController *offlinePicturesController = segue.destinationViewController;
        offlinePicturesController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"chooseGroup"]){
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.delegate = self;
        self.chooseFlag = 1;
    }
    
}

#pragma mark - Action Sheet Delegate Methods
- (void)actionSheet:(UIActionSheet * )actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            imagePicker.allowsEditing = NO;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }
    else if(buttonIndex == 1){
        self.chooseFlag = 1 ;
        [self performSegueWithIdentifier:@"offlinePic" sender:self];
        
    }
}


#pragma mark - Button

- (IBAction)btnChooseImagePressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"ضع صورتك الشخصية أو اختار صورة رمزية" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"صورة شخصية",@"صورة رمزية", nil];
    [actionSheet showInView:self.view];
    
}

#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.profilePic.image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        [self.btnChooseImage setImage:nil forState:UIControlStateNormal];
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
- (IBAction)btnHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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


//NSLog(@"EDIT ACC USER ID %ld",(long)self.userID);
//    NSInteger first = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:0]] integerValue];
//    NSInteger second = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:1]]integerValue];
//    NSInteger third = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:2]]integerValue];
//    NSInteger fourth = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:3]]integerValue];
//    NSInteger fifth = [[NSString stringWithFormat:@"%c", [self.maskInbox characterAtIndex:4]]integerValue];

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

- (IBAction)btnSelectedGroupPressed:(id)sender {
    [self performSegueWithIdentifier:@"chooseGroup" sender:self];
}
@end
