//
//  ConnectionAdapter.h
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionAdapter : NSObject

@property(nonatomic,strong) NSArray *responseArray;



- (instancetype)initConnectionWithDictionary:(NSDictionary *)postDict withBlock:(void (^)(void))block ;

@end
