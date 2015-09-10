//
//  NetworkConnection.h
//  دعوات قطر
//
//  Created by Adham Gad on 10,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkConnection : NSObject

@property (nonatomic,strong) NSData *response;


-(void)postRequest:(NSDictionary *)postDict;

@end
