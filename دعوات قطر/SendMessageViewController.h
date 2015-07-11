//
//  SendMessageViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 12,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendMessageViewController : UIViewController

@property (nonatomic)NSInteger receiverID;

@property (weak, nonatomic) IBOutlet UITextField *messageSubject;
@property (weak, nonatomic) IBOutlet UITextView *messageContent;

- (IBAction)btnSendPressed:(id)sender;
@end
