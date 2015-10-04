//
//  NetworkConnection.m
//  دعوات قطر
//
//  Created by Adham Gad on 10,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "NetworkConnection.h"



@interface NetworkConnection()

@property (nonatomic,strong) ASIFormDataRequest *imageRequest;

@property (nonatomic,strong) void (^completionHandler)(NSData *) ;

@end

@implementation NetworkConnection

//Inistantiation and assigning reference to the completion handler
-(instancetype)initWithCompletionHandler:(void (^)(NSData * response))completionHandler{
    self = [super init];
    if (self) {
        self.completionHandler = completionHandler;
    }
    return self;
}

#pragma mark - Images
-(void)downloadImageWithID:(NSInteger)imageID withCacheNameSpace:(NSString *)nameSpace withKey:(NSString *)key withWidth:(NSInteger)width andHeight:(NSInteger)height{
    
    NSString *imgURLString = [NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%ld&t=%ldx%ld",(long)imageID,(long)width,(long)height];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    
    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:imgURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image && finished) {
            [self.delegate downloadedImage:image];
//            SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:nameSpace];
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache storeImage:image forKey:key];
            
        }
    }];
    
}
-(void)downloadImageWithID:(NSInteger)imageID withCacheNameSpace:(NSString *)nameSpace withKey:(NSString *)key{
    
    NSString *imgURLString = [NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%ld",(long)imageID];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    
    [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:imgURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (image && finished) {
            [self.delegate downloadedImage:image];
            //            SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:nameSpace];
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache storeImage:image forKey:key];
            
        }
    }];
    
}


-(void)downloadImageWithID:(NSInteger)imageID{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imgURLString = [NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%ld",(long)imageID];
            NSURL *imgURL = [NSURL URLWithString:imgURLString];
            NSData *imgData = [NSData dataWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.downloadedImage = image;
                [self.delegate downloadedImage:image];
            });
        });
    
}


-(void)downloadImageWithID:(NSInteger)imageID andImageView:(UIImageView *)imageView{
    NSString *imgURLString = [NSString stringWithFormat:@"http://da3wat-qatar.com/api/image.php?id=%ld",(long)imageID];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    [imageView sd_setImageWithURL:imgURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
       
    }];
    
}

-(void)postPicturewithTag:(NSMutableDictionary *)dict uploadImage:(UIImage *)image {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"admin", @"admin"];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    
    self.imageRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://da3wat-qatar.com/api/upload.php"]];
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

#pragma mark - Content

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
    [request setPostBody:[NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:postDict options:kNilOptions error:nil]]];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.response = [request responseData];
    //NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:self.response options:kNilOptions error:nil]);
    
    if (self.completionHandler) {
        self.completionHandler(self.response);
    }
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

-(void)getUserWithID:(NSInteger)userID {
    
    NSDictionary *getUser = @{@"FunctionName":@"getUserbyID" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)userID],
                                                                             }]};
    NSMutableDictionary *getUserTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getUser",@"key", nil];
    
    [self postRequest:getUser withTag:getUserTag];
    
}

-(void)getInvitationsNumberWithMobile:(NSString *)userMobile password:(NSString *)userPassword{
    NSDictionary *getInvNum = @{
                                @"FunctionName":@"signIn" ,
                                @"inputs":@[@{@"Mobile":userMobile,
                                              @"password":userPassword}]};
    
    NSMutableDictionary *getInvNumTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"invNum",@"key", nil];
    [self postRequest:getInvNum withTag:getInvNumTag];
}

-(void)getUserEventsWithUserID:(NSInteger)userID startValue:(NSInteger)start limitValue:(NSInteger)limit{
    NSDictionary *getEvents = @{@"FunctionName":@"getUserEventsList" ,
                                @"inputs":@[@{@"userID":[NSString stringWithFormat:@"%ld",(long)userID],
                                              @"start":[NSString stringWithFormat:@"%ld",(long)start],
                                              @"limit":[NSString stringWithFormat:@"%ld",(long)limit]
                                                                                     }]};
    NSMutableDictionary *getEventsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getEvents",@"key", nil];
    [self postRequest:getEvents withTag:getEventsTag];
}

-(void)getCreateEventAdminMsg {
    NSDictionary *getAdminMsg = @{@"FunctionName":@"getString" , @"inputs":@[@{@"name":@"createEvent",
                                                                               }]};
    NSMutableDictionary *getAdminMsgTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAdminMsg",@"key", nil];
    
    [self postRequest:getAdminMsg  withTag:getAdminMsgTag];
}

-(void)getSpecialEventWithType:(NSInteger)type startFrom:(NSInteger)start limit:(NSInteger)limit {
    NSDictionary *getAdminMsg = @{@"FunctionName":@"getServicesList" , @"inputs":@[@{@"start":[NSString stringWithFormat:@"%ld",(long)start],
                                                                                     @"limit":[NSString stringWithFormat:@"%ld",(long)limit],
                                                                                     @"type":[NSString stringWithFormat:@"%ld",(long)type]
                                                                               }]};
    NSMutableDictionary *getAdminMsgTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAdminMsg",@"key", nil];
    
    [self postRequest:getAdminMsg  withTag:getAdminMsgTag];
}


-(void)getFullServiceWithID:(NSInteger)serviceID {
    NSDictionary *getService = @{@"FunctionName":@"getServicesFull" , @"inputs":@[@{@"id":[NSString stringWithFormat:@"%ld",(long)serviceID]
                                                                                     
                                                                                     }]};
    NSMutableDictionary *getServiceTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"GetServices",@"key", nil];
    
    [self postRequest:getService  withTag:getServiceTag];
}

-(void)likePostWithMemberID:(NSInteger)memberID EventsOrService:(NSString *)table postID:(NSInteger)postID{
    NSDictionary *getService = @{@"FunctionName":@"Like" , @"inputs":@[@{@"memberID":[NSString stringWithFormat:@"%ld",(long)memberID],
                                                                         @"table":table,
                                                                         @"PostID":[NSString stringWithFormat:@"%ld",(long)postID]
                                                                                    
                                                                                    }]};
    NSMutableDictionary *getServiceTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"GetServices",@"key", nil];
    
    [self postRequest:getService  withTag:getServiceTag];
}
-(void)isLikeWithMemberID:(NSInteger)memberID EventsOrService:(NSString *)table postID:(NSInteger)postID{
    NSDictionary *getService = @{@"FunctionName":@"isLike" , @"inputs":@[@{@"memberID":[NSString stringWithFormat:@"%ld",(long)memberID],
                                                                         @"table":table,
                                                                         @"PostID":[NSString stringWithFormat:@"%ld",(long)postID]
                                                                         
                                                                         }]};
    NSMutableDictionary *getServiceTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"GetServices",@"key", nil];
    
    [self postRequest:getService  withTag:getServiceTag];
}


-(void)getAllLikesWithMemberID:(NSInteger)memberID EventsOrService:(NSString *)table postID:(NSInteger)postID{
    NSDictionary *getService = @{@"FunctionName":@"getLikes" , @"inputs":@[@{@"memberID":[NSString stringWithFormat:@"%ld",(long)memberID],
                                                                         @"table":table,
                                                                         @"PostID":[NSString stringWithFormat:@"%ld",(long)postID]
                                                                         
                                                                         }]};
    NSMutableDictionary *getServiceTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getLikes",@"key", nil];
    
    [self postRequest:getService  withTag:getServiceTag];
}

-(void)addInvitationPointsWithMemberID:(NSInteger)memberID andInvitationID:(NSInteger)invitationID{
    NSDictionary *getService = @{@"FunctionName":@"addInvPoints" , @"inputs":@[@{@"memberID":[NSString stringWithFormat:@"%ld",(long)memberID],
                                                                        
                                                                             @"invitationID":[NSString stringWithFormat:@"%ld",(long)invitationID]
                                                                             
                                                                             }]};
    NSMutableDictionary *getServiceTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"addInvitationPoints",@"key", nil];
    
    [self postRequest:getService  withTag:getServiceTag];
}

-(void)getAdsWithStart:(NSInteger)start andLimit:(NSInteger)limit{
    NSDictionary *getAds = @{@"FunctionName":@"getAds" , @"inputs":@[@{@"start":[NSString stringWithFormat:@"%ld",(long)start],
                                                                                 
                                                                                 @"limit":[NSString stringWithFormat:@"%ld",(long)limit]
                                                                                 
                                                                                 }]};
    NSMutableDictionary *getAdsTag = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"getAdsTag",@"key", nil];
    
    [self postRequest:getAds  withTag:getAdsTag];
}

@end
