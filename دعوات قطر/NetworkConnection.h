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

@interface NetworkConnection : NSObject

@property (nonatomic,strong) NSData *response;
@property (nonatomic,strong) ASIFormDataRequest *imageRequest;

-(void)postRequest:(NSDictionary *)postDict withTag:(NSMutableDictionary *)dict;
-(void)postPicturewithTag:(NSMutableDictionary *)dict uploadImage:(UIImage *)image;

@end
