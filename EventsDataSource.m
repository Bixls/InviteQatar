//
//  EventsDataSource.m
//  دعوات قطر
//
//  Created by Adham Gad on 26,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import "EventsDataSource.h"
#import "customEventCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EventsDataSource()

@property (nonatomic,strong) NSArray *events;
@property (nonatomic,strong) NSDictionary *selectedEvent;
@property (nonatomic,strong) NSLayoutConstraint *height;
@property (nonatomic,strong) UIViewController *viewController;
@property (nonatomic,strong) void (^completionHandler)(NSDictionary *selectedEvent);

@end

@implementation EventsDataSource

- (instancetype)initWithEvents:(NSArray *)events withHeightConstraint:(NSLayoutConstraint *)height andViewController:(UIViewController*)viewController withSelectedEvent:(void (^)(NSDictionary * selectedEvent))completionHandler
{
    self = [super init];
    if (self) {
        _events = events;
        _height = height;
        _viewController = viewController;
        _completionHandler = completionHandler;
    }
    return self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.events.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    customEventCollectionViewCell *cell = (customEventCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"eventCell" forIndexPath:indexPath];
    
    NSDictionary *tempEvent = self.events[indexPath.row];
    
    cell.eventName.text =tempEvent[@"subject"];
    cell.eventCreator.text = tempEvent[@"CreatorName"];
    
    cell.likesNumber.text = [self arabicNumberFromEnglish:[tempEvent[@"Likes"]integerValue]];
    cell.viewsNumber.text = [self arabicNumberFromEnglish:[tempEvent[@"views"]integerValue]];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSLocale *qatarLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"ar_QA"];
    [formatter setLocale:qatarLocale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [formatter dateFromString:[NSString stringWithFormat:@"%@",tempEvent[@"TimeEnded"]]];
    NSString *date = [formatter stringFromDate:dateString];
    NSString *dateWithoutSeconds = [date substringToIndex:16];
    cell.eventDate.text = [dateWithoutSeconds stringByReplacingOccurrencesOfString:@"-" withString:@"/"];

    cell.eventPic.layer.masksToBounds = YES;
    cell.eventPic.layer.cornerRadius = cell.eventPic.bounds.size.width/2;
    
    NSString *imgURLString = [NSString stringWithFormat:@"http://bixls.com/Qatar/image.php?id=%@&t=150x150",tempEvent[@"EventPic"]];
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
     UIActivityIndicatorView *eventsSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [cell.eventPic sd_setImageWithURL:imgURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            eventsSpinner.center = cell.eventPic.center;
            eventsSpinner.hidesWhenStopped = YES;
            [cell addSubview:eventsSpinner];
            [eventsSpinner startAnimating];
        });
       
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.eventPic.image = image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [eventsSpinner stopAnimating];
        });

    }];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setSectionInset:UIEdgeInsetsMake(5, 0, 5, 0)];
    
    if (self.height != nil) {
        self.height.constant = collectionView.contentSize.height;

    }
    
    return cell ;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedEvent = self.events[indexPath.item];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.completionHandler(self.selectedEvent);
    [self.viewController performSegueWithIdentifier:@"event" sender:self];
}

-(NSString *)arabicNumberFromEnglish:(NSInteger)num {
    NSNumber *someNumber = [NSNumber numberWithInteger:num];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
    [formatter setLocale:gbLocale];
    return [formatter stringFromNumber:someNumber];
}


@end
