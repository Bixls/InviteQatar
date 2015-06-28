//
//  SignUpViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "SignUpViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseImage;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)signUp{
    NSDictionary *postDict = @{@"key":@"6", @"FunctionName":@"Register" , @"inputs":@[@{@"name":self.nameField.text,
                                                                                       @"username":self.usernameField.text,
                                                                                        @"password":self.passwordField.text,
                                                                                        @"groupID":@"4",
                                                                                        @"Mobile":self.mobileField.text,
                                                                                        @"ProfilePic":@"11"}]};
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = @"http://bixls.com/Qatar/" ;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST" ;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *receivedDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",receivedDictionary);
    }];
    
    [task resume];
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
        self.profilePicture.image = image;
        
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
    
    [self signUp];
}
@end
