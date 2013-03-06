//
//  NPWorld.m
//  Newton
//
//  Created by omer iqbal on 12/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NPWorld.h"

@implementation NPWorld
-(id)init {
    _bucket = [[NSMutableArray alloc] init];
    _isOn = NO;
    return self;
}
-(void)addObject:(NPRectangle *)rect {
    [self.bucket addObject:rect];
}
-(void)removeObject:(NPRectangle *)rect {
    //[_bucket removeObjectForKey:[self hash:rect]];
}
-(id)hash:(NSObject*)o {
    return [[NSNumber numberWithUnsignedInt:[o hash]] stringValue];
}
-(void)startWorldWithInterval:(CGFloat)interval {
    _timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(updateWorld:) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
    _isOn = YES;
}
-(void)startWorld {
    [self startWorldWithInterval:1/60.0];
}
-(void)stopWorld {
    [self.timer invalidate];
    self.timer = nil;
    _isOn = NO;
}
-(void)resetWorld {
    NSMutableArray* rmObjects = [NSMutableArray new];
    for (NPRectangle* rect in _bucket) {
        if (rect.rectType != OBJECT) {
            [rmObjects addObject:rect];
        }
    }
    _bucket = rmObjects;
    [self stopWorld];
}
-(void)updateWorld:(NSTimer*)t {
   // NSArray* mutateContainer = [[NSArray alloc] initWithArray:self.bucket];
    for (int i= 0; i < [self.bucket count]; i++) {
        for (int j = i + 1; j < [self.bucket count]; j++) {
            NPRectangle* recti = [self.bucket objectAtIndex:i];
            NPRectangle* rectj = [self.bucket objectAtIndex:j];
            [rectj updateSelfWith:recti];
        }
    }
}
-(void)updateGravity:(Vector2D*)g {
    _curGravity = g;
    for (NPRectangle* rect in self.bucket) {
        if (rect.rectType == OBJECT) {
            rect.gravity = g;
        }
    }
}
@end
