//
//  HomeLabel.m
//  MBaseProject
//
//  Created by Wisdom on 2017/12/21.
//  Copyright © 2017年 Wisdom. All rights reserved.
//

#import "HomeLabel.h"
#import "MConst.h"

@implementation HomeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.font = [UIFont systemFontOfSize:15];
        self.textColor = [UIColor colorWithRed:MRed green:MGreen blue:MBlue alpha:1.0];
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    //      R G B
    // 默认：0.4 0.6 0.7
    // 红色：1   0   0
    
    CGFloat red = MRed + (1 - MRed) * scale;
    CGFloat green = MGreen + (0 - MGreen) * scale;
    CGFloat blue = MBlue + (0 - MBlue) * scale;
    self.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    // 大小缩放比例
    CGFloat transformScale = 1 + scale * 0.3; // [1, 1.3]
    self.transform = CGAffineTransformMakeScale(transformScale, transformScale);
}

@end
