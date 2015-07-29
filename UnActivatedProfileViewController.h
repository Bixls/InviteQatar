//
//  UnActivatedProfileViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 28,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface UnActivatedProfileViewController : UIViewController <ASIHTTPRequestDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *myProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *myName;


@end
