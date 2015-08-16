//
//  ChooseDateViewController.m
//  دعوات قطر
//
//  Created by Adham Gad on 10,7//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "ChooseDateViewController.h"

@interface ChooseDateViewController ()

@property (nonatomic,strong) NSString *selectedDate;

@end

@implementation ChooseDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    self.view.backgroundColor = [UIColor blackColor];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *formatedDate = [formatter stringFromDate:self.datePicker.date];
    self.selectedDate = formatedDate;
}


- (IBAction)datePickerPressed:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *formatedDate = [formatter stringFromDate:self.datePicker.date];
    self.selectedDate = formatedDate;
    NSLog(@"%@",self.selectedDate);
}

- (IBAction)btnSavePressed:(id)sender {
    [self.delegate selectedDate:self.selectedDate];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
