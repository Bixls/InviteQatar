//
//  ChooseDateViewController.h
//  دعوات قطر
//
//  Created by Adham Gad on 10,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chooseDateViewControllerDelegate <NSObject>

-(void)selectedDate:(NSString *)date;

@end


@interface ChooseDateViewController : UIViewController

@property(nonatomic,weak) id <chooseDateViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)datePickerPressed:(id)sender;

- (IBAction)btnSavePressed:(id)sender;

@end
