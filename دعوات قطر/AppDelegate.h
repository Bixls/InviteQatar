//
//  AppDelegate.h
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;


@end

