//
//  MiddleContainerViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 30,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkConnection.h"
#import <SDWebImage/UIImageView+WebCache.h>

@protocol MiddleContainerDelegate <NSObject>

-(void)removeContainerIfEmpty:(BOOL)isEmpty withContainerID:(NSInteger)containerID ;
-(void)setContainerHeight:(NSInteger)height withContainerID:(NSInteger)containerID;

@end

@interface MiddleContainerViewController : UIViewController

@property (nonatomic) NSInteger containerID;
@property (nonatomic,weak) id <MiddleContainerDelegate> delegate;

@end
