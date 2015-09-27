//
//  NetworkConnection.h
//  دعوات قطر
//
//  Created by Adham Gad on 10,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

@protocol NetworkConnectionDelegate <NSObject>

-(void)downloadedImage:(UIImage *)image;

@end

@interface NetworkConnection : NSObject

@property (nonatomic,strong) NSData *response;
@property (nonatomic,weak) id <NetworkConnectionDelegate> delegate;

-(instancetype)initWithCompletionHandler:(void (^)(NSData * response))completionHandler;

-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict;
-(void)postPicturewithTag:(NSMutableDictionary *)dict uploadImage:(UIImage *)image;

-(void)searchDataBaseWithText:(NSString*)text;
-(void)signUpWithName:(NSString *)name mobile:(NSString *)mobile password:(NSString *)password groupID:(NSString *)groupID imageURL:(NSString*)imageURL;
-(void)downloadImageWithID:(NSInteger)imageID;
-(void)downloadImageWithID:(NSInteger)imageID withCacheNameSpace:(NSString *)nameSpace withKey:(NSString *)key withWidth:(NSInteger)width andHeight:(NSInteger)height;
-(void)getUserWithID:(NSInteger)userID;
-(void)getInvitationsNumberWithMobile:(NSString *)userMobile password:(NSString *)userPassword;
-(void)getUserEventsWithUserID:(NSInteger)userID startValue:(NSInteger)start limitValue:(NSInteger)limit;
-(void)getCreateEventAdminMsg ;
-(void)getSpecialEventWithType:(NSInteger)type startFrom:(NSInteger)start limit:(NSInteger)limit ;
-(void)getFullServiceWithID:(NSInteger)serviceID;
-(void)likePostWithMemberID:(NSInteger)memberID EventsOrService:(NSString *)table postID:(NSInteger)postID;
-(void)getAllLikesWithMemberID:(NSInteger)memberID EventsOrService:(NSString *)table postID:(NSInteger)postID;
-(void)addInvitationPointsWithMemberID:(NSInteger)memberID andInvitationID:(NSInteger)invitationID;

@end
