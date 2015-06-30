//
//  SignUpViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SignUpViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseGroup;

@property (strong,nonatomic) NSDictionary *selectedGroup;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedGroup = @{@"id":@"default"} ;
    
}

-(void)selectedGroup:(NSDictionary *)group {
    self.selectedGroup = group;
    [self.btnChooseGroup setTitle:self.selectedGroup[@"name"] forState:UIControlStateNormal];
    NSLog(@"%@",group);
    
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chooseGroupSegue"]) {
        chooseGroupViewController *chooseGroupController = segue.destinationViewController;
        chooseGroupController.delegate = self;
    }
}

#pragma mark - Connection setup

-(void)postRequest:(NSDictionary *)postDict{
    
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
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    
    ASIFormDataRequest *imageRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://bixls.com/Qatar/upload.php"]];
    [imageRequest setUseKeychainPersistence:YES];
    imageRequest.delegate = self;
    imageRequest.username = @"admin";
    imageRequest.password = @"admin";
    [imageRequest setRequestMethod:@"POST"];
    [imageRequest addRequestHeader:@"Authorization" value:authValue];
    [imageRequest addRequestHeader:@"Accept" value:@"application/json"];
    [imageRequest addRequestHeader:@"content-type" value:@"application/json"];
    imageRequest.allowCompressedResponse = NO;
    imageRequest.useCookiePersistence = NO;
    imageRequest.shouldCompressRequestBody = NO;
    [imageRequest setPostValue:@"6" forKey:@"id"];
    [imageRequest setPostValue:@"user" forKey:@"type"];
    [imageRequest addData:[NSData dataWithData:UIImageJPEGRepresentation(self.profilePicture.image, 0.9)] withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"fileToUpload"];
    
    

    
    [request startAsynchronous];
    [imageRequest startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@",responseString);
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil]);
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@",error);
}



#pragma mark - Textfield delegate method 

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Image Picker delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.profilePicture.image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        
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

#pragma mark - Buttons 

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


- (IBAction)btnSignUpPressed:(id)sender {
    
   
    
    NSDictionary *postDict = @{@"FunctionName":@"Register" ,
                               @"inputs":@[@{@"name":self.nameField.text,
                                             @"Mobile":self.mobileField.text,
                                             @"password":self.passwordField.text,
                                             @"groupID":(NSString *)self.selectedGroup[@"id"]}]};
    
    NSLog(@"%@",(NSString *)self.selectedGroup[@"id"]);
    [self postRequest:postDict];
}
@end



