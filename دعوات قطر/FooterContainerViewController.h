//
//  FooterContainerViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 30,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "NetworkConnection.h"

@protocol FooterContainerDelegate <NSObject>

-(void)removeFooter:(BOOL)remove ;

@end

@interface FooterContainerViewController : UIViewController

@property (nonatomic,strong) NSArray *footerAds;
@property (nonatomic,strong) id <FooterContainerDelegate> delegate;

@end
