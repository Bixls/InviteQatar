//
//  EventsDataSource.h
//  دعوات قطر
//
//  Created by Adham Gad on 26,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EventsDataSource : NSObject <UICollectionViewDataSource,UICollectionViewDelegate>

- (instancetype)initWithEvents:(NSArray *)events withHeightConstraint:(NSLayoutConstraint *)height andViewController:(UIViewController*)viewController withSelectedEvent:(void (^)(NSDictionary * selectedEvent))completionHandler;

@end
