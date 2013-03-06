//
//  RectViewController.h
//  Newton
//
//  Created by omer iqbal on 8/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NPRectangle.h"
@interface RectViewController : NSObject <model>

@property(weak,nonatomic) UIView *sprite;
@property NPRectangle* model;
- (id)initWithSprite:(UIView*)sprite;
- (id)initWithSpriteAsWall:(UIView *)sprite;
- (void)updateController;
@end
