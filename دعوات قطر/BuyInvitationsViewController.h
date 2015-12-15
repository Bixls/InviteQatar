//
//  BuyInvitationsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "HeaderContainerViewController.h"
#import "FooterContainerViewController.h"

@interface BuyInvitationsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SKProductsRequestDelegate,UIAlertViewDelegate , headerContainerDelegate,FooterContainerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *vipTableView;
- (IBAction)btnBuyNowPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *InvitationsNum;

@property (weak, nonatomic) IBOutlet UILabel *invitationsType;
@property (weak, nonatomic) IBOutlet UILabel *invitationsPrice;


@property (nonatomic,strong) NSMutableArray *productsIdentifiers;
@property (nonatomic,strong) NSArray *products;
@property (nonatomic,strong) SKProduct *selectedProduct;

-(void)validateProductIdentifiers;
-(void)makeThePurchase;


@end
