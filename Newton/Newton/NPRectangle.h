//
//  NPRectangle.h
//  Newton
//
//  Created by omer iqbal on 8/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "Matrix2D.h"
#import "NPShape.h"
typedef enum {AX,AY,BX,BY} kfVectorComp;
typedef enum {E1,E2,E3,E4} kEdgeType;
typedef enum {OBJECT,WALL} kRectType;
@protocol model <NSObject>
-(void)updateController;
@end
@interface NPRectangle : NPShape
@property(nonatomic) CGFloat mass;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) Vector2D *center;
@property(nonatomic) Vector2D *forces;
@property(nonatomic) CGFloat torques;
@property(nonatomic) Vector2D *gravity;
@property(nonatomic) Vector2D *velocity;
@property(nonatomic) CGFloat angularVelocity;
@property(nonatomic) CGFloat dt;
@property(nonatomic) CGFloat rotation;
@property(nonatomic) CGFloat restituition;
@property(nonatomic) CGFloat friction;
@property(nonatomic) Vector2D *dVelocity;
@property(nonatomic) CGFloat dAngularVelocity;
@property kRectType rectType;
@property id delegate;
- (void)applyForces;
- (void)applyTorques;
- (id)initWithCenter:(Vector2D*)center mass:(CGFloat)m height:(CGFloat)h width:(CGFloat)width velocity:(Vector2D*)v angularV:(CGFloat)w gravity:(Vector2D*)g deltaT:(CGFloat)dt rotation:(CGFloat)rot rest:(CGFloat)rest friction:(CGFloat)friction;
- (id)initWithCenter:(Vector2D*)center height:(CGFloat)h width:(CGFloat)w rotation:(CGFloat)rot;
-(Matrix2D*)rotationM;

-(BOOL)checkNegativeFVectorComponents:(NPRectangle*)other;
-(NSDictionary*)clippingWith:(NPRectangle*)other;
-(void)updateSelfWith:(NPRectangle*)other;
@end
