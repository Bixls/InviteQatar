//
//  AppDelegate.m
//  دعوات قطر
//
//  Created by Adham Gad on 28,6//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "AppDelegate.h"
#import <URBNAlert/URBNAlert.h>
#import "EventViewController.h"
#import "HomePageViewController.h"
@interface AppDelegate ()

@property (nonatomic,strong)NetworkConnection *inAppPurchase;
@property (nonatomic,strong) NetworkConnection *adsConnection;
@property (nonatomic,strong)NSUserDefaults *userDefaults;
@property (nonatomic)NSInteger memberID;
@property (nonatomic)NSInteger invitationID;
@property (nonatomic)NSInteger requestSuccess;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.backgroundColor = [UIColor blackColor];


    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    self.userDefaults  = [NSUserDefaults standardUserDefaults];
    [self.userDefaults setBool:YES forKey:@"refreshFooter"];
    [self.userDefaults synchronize];
   // [self initAds];
   // [self.userDefaults setBool:false forKey:@"removeFrames"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    [self.userDefaults setBool:YES forKey:@"showNotification"];
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"home"]];
    
    
    EventViewController *eventVC = [storyboard instantiateViewControllerWithIdentifier:@"event"];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:eventVC];
    [navCtrl setNavigationBarHidden:YES];
    [self.window.rootViewController presentViewController:navCtrl animated:NO completion:nil];
//    [self.window.rootViewController.navigationController pushViewController:eventVC animated:NO];
    
  
    
    
    
    //[self.window setRootViewController:eventVC];
    
//    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    HomePageViewController *homeVC = [mainstoryboard instantiateViewControllerWithIdentifier:@"home"];
//    UINavigationController *homeNav = [[UINavigationController alloc]initWithRootViewController:homeVC];
//    
//    
//    [homeNav pushViewController:eventVC animated:NO];
    
    
}

#pragma mark - StoreKit Methods

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased: {
                //Add user vip points
                [self addUserPointsWithTransaction:transaction];

                break;
            }
            case SKPaymentTransactionStatePurchasing:{
                break;
            }
                
            case SKPaymentTransactionStateRestored:{
                break;
            }
            case SKPaymentTransactionStateFailed:{
                break;
            }
                
                
                
            default:
                break;
        }
    }
}

#pragma mark - Store Methods

-(void)addUserPointsWithTransaction:(SKPaymentTransaction *)transaction{
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.memberID = [self.userDefaults integerForKey:@"memberID"];
    self.invitationID = [self.userDefaults integerForKey:@"invitationID"];
    self.requestSuccess = [self.userDefaults integerForKey:@"requestSuccess"];
    
    self.inAppPurchase = [[NetworkConnection alloc]initWithCompletionHandler:^(NSData *response) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
        if ([dict[@"success"]boolValue] == true) {
            [self.userDefaults setInteger:1 forKey:@"requestSuccess"];
            [self.userDefaults synchronize];
            
            [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
            [self saveReceipts];
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"تمت عملية الشراء بنجاح" delegate:nil cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }else if ([dict[@"success"]boolValue] == false){
            [self.userDefaults setInteger:0 forKey:@"requestSuccess"];
            [self.userDefaults synchronize];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"لم تتم عملية الشراء بنجاح" delegate:nil cancelButtonTitle:@"إغلاق" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
    [self.inAppPurchase addInvitationPointsWithMemberID:self.memberID andInvitationID:self.invitationID];
    
    
    NSLog(@"Add User Points Called");
}

-(void)saveReceipts{
    
}
-(void)restore{
    
}

@end
