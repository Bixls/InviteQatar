//
//  backButton.m
//  دعوات قطر
//
//  Created by Adham Gad on 24,9//15.
//  Copyright © 2015 Bixls. All rights reserved.
//

#import "backButton.h"

@implementation backButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:@"backButton" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}


@end
