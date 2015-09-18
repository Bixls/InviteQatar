//
//  adSpace.m
//  دعوات قطر
//
//  Created by Adham Gad on 17,9//15.
//  Copyright (c) 2015 Bixls. All rights reserved.
//

#import "adSpace.h"

@implementation adSpace

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
        [[NSBundle mainBundle]loadNibNamed:@"adSpace" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

@end
