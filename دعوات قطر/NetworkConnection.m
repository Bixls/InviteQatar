//
//  NetworkConnection.m
//  دعوات قطر
//
//  Created by Adham Gad on 10,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "NetworkConnection.h"

#import <AFNetworking/AFNetworking.h>

@interface NetworkConnection()
@property (nonatomic,strong) ASIFormDataRequest *imageRequest;
//@property (nonatomic,strong) UIImage *downloadedImage;
@end

@implementation NetworkConnection

-(void)downloadImageWithID:(NSInteger)imageID{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%ld",(long)imageID];
        NSURL *imgURL = [NSURL URLWithString:imgURLString];
        NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
        UIImage *image = [[UIImage alloc]initWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.downloadedImage = image;
            [self.delegate downloadedImage:image];
        });
    });
}

-(void)postPicturewithTag:(NSMutableDictionary *)dict uploadImage:(UIImage *)image {
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
    //    [self.imageRequest addRequestHeader:@"Accept" value:@"application/json"];
    //    [self.imageRequest addRequestHeader:@"content-type" value:@"application/json"];
    self.imageRequest.allowCompressedResponse = NO;
    self.imageRequest.useCookiePersistence = NO;
    self.imageRequest.shouldCompressRequestBody = NO;
    self.imageRequest.userInfo = dict;
    [self.imageRequest addData:[NSData dataWithData:UIImageJPEGRepresentation(image,1.0)] withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"fileToUpload"];
    [self.imageRequest startAsynchronous];
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
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.response = [request responseData];
    //NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:self.response options:kNilOptions error:nil]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    //NSLog(@"%@",error);
}

-(void)searchDataBaseWithText:(NSString*)text {
    NSDictionary *postDict = @{
                      @"FunctionName":@"searchUsers" ,
                      @"inputs":@[@{@"Key":text,
                                    @"start":@"0",
                                    @"limit":@"50000"}]};
    
    [self postRequest:postDict withTag:nil];
}

-(void)signUpWithName:(NSString *)name mobile:(NSString *)mobile password:(NSString *)password groupID:(NSString *)groupID imageURL:(NSString*)imageURL {
    
    NSDictionary *postDict = @{@"FunctionName":@"Register" ,
                               @"inputs":@[@{@"name":name,
                                             @"Mobile":mobile,
                                             @"password":password,
                                             @"groupID":groupID,
                                             @"ProfilePic":imageURL}]};
    
    NSMutableDictionary *registerTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"registerTag",@"key", nil];
    [self postRequest:postDict withTag:registerTag];
}


@end
