//
//  NPConstants.m
//  Newton
//
//  Created by omer iqbal on 12/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NPConstants.h"

@implementation NPConstants
const CGFloat WORLD_STEP = 1.0/60.0;
const CGFloat DEFAULT_MASS = 50.0;
const CGFloat GRAVITY = 10.0;
const CGFloat DEFAULT_RESTITUITION = 0.5;
const CGFloat DEFAULT_FRICTION = 0.5;
const CGFloat BIAS_CONST_1 = 0.05;
const CGFloat BIAS_CONST_2 = 0.01;
const CGFloat BIAS_ROW = 0.95;
const int IMPULSE_ITERATIONS = 2;
const CGFloat ROTATION_EPSILON1 = 0.01;
const CGFloat ROTATION_EPSILON2= 0.001;
const CGFloat ACC_FACTOR = 10;
const CGFloat VELOCITY_EPSILON = 0.8;
@end
