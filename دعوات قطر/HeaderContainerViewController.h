//
//  HeaderContainerViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 29,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol headerContainerDelegate <NSObject>

-(void)homePageBtnPressed;
-(void)backBtnPressed;

@end

@interface HeaderContainerViewController : UIViewController

@property (nonatomic,weak) id <headerContainerDelegate> delegate;

@end
