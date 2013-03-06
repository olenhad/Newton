//
//  RectViewController.m
//  Newton
//
//  Created by omer iqbal on 8/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "RectViewController.h"

@interface RectViewController ()

@end

@implementation RectViewController


- (id)initWithSprite:(UIView *)sprite {
    self = [super init];
    if (self) {
        _sprite = sprite;
        //_sprite.userInteractionEnabled = TRUE;
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translate:)];
        [_sprite addGestureRecognizer:pan];
        _model = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:sprite.center.x y:sprite.center.y] height:sprite.frame.size.height width:sprite.frame.size.width rotation:0];
        [_model setDelegate:self];
        
    }
    return self;
}
- (id)initWithSpriteAsWall:(UIView *)sprite {
    self = [self initWithSprite:sprite];
    if (self) {
        _model.mass = INFINITY;
        _model.gravity = [Vector2D vectorWith:0 y:0];
        _model.rectType = WALL;
    }
    return self;
}
- (void)translate:(UIPanGestureRecognizer*)gesture {
    CGPoint translate = [gesture translationInView:_sprite];
    
    
    _sprite.transform = CGAffineTransformTranslate(_sprite.transform, translate.x, translate.y);
    
    [gesture setTranslation:CGPointMake(0, 0) inView:_sprite];
}
-(void)updateController {
    //_sprite.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, _model.center.x, _model.center.y);
    
    _sprite.center = CGPointMake(_model.center.x, _model.center.y);
    _sprite.transform = CGAffineTransformRotate(CGAffineTransformIdentity, _model.rotation);
}
@end
