//
//  BuyInvitationsViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 1,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface BuyInvitationsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *vipTableView;
- (IBAction)btnBuyNowPressed:(id)sender;

@property (nonatomic,strong) NSArray *allProducts;
@property (nonatomic,strong) NSArray *myProducts;

@property (nonatomic,strong) SKProduct *selectedProduct;

-(void)validateProductIdentifiers;
-(void)makeThePurchase;


@end
