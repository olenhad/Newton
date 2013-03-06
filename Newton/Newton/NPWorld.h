//
//  NPWorld.h
//  Newton
//
//  Created by omer iqbal on 12/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPRectangle.h"
#import "NPConstants.h"
@interface NPWorld : NSObject
@property NSMutableArray *bucket;
@property NSTimer *timer;
@property Vector2D *curGravity;
@property BOOL isOn;
-(id)init;
-(void)addObject:(NPRectangle*)rect;
-(void)removeObject:(NPRectangle*)rect;
-(void)startWorld;
-(void)stopWorld;
-(void)resetWorld;
-(void)updateGravity:(Vector2D*)g;
@end
