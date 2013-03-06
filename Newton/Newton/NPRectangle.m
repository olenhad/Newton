//
//  NPRectangle.m
//  Newton
//
//  Created by omer iqbal on 8/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "NPRectangle.h"

@implementation NPRectangle
-(id)initWithCenter:(Vector2D *)center mass:(CGFloat)m height:(CGFloat)h width:(CGFloat)width velocity:(Vector2D *)v angularV:(CGFloat)w gravity:(Vector2D *)g deltaT:(CGFloat)dt rotation:(CGFloat)rot rest:(CGFloat)rest friction:(CGFloat)friction{
    _center = center;
    _mass = m;
    _velocity = v;
    _angularVelocity = w;
    _gravity = g;
    _dt = dt;
    _width = width;
    _height = h;
    _rotation = rot;
    _restituition = rest;
    _friction = friction;
    _forces = [Vector2D vectorWith:0 y:0];
    _torques = 0;
    _rectType = OBJECT;
    return self;
}
-(id)initWithCenter:(Vector2D*)center height:(CGFloat)h width:(CGFloat)w rotation:(CGFloat)rot {
    return [self initWithCenter:center mass:DEFAULT_MASS height:h width:w velocity:[Vector2D vectorWith:0 y:0] angularV:0 gravity:[Vector2D gravity] deltaT:WORLD_STEP rotation:rot rest:DEFAULT_RESTITUITION friction:DEFAULT_FRICTION];
}
-(CGFloat)momentOfInertia {
    return _mass*(_width*_width + _height*_height)/2.0;
}
-(void)applyForces {
    self.velocity = [[[self.gravity add:[self.forces multiply:1.0/self.mass]] multiply:self.dt] add:self.velocity];
}
-(void)applyTorques {
    self.angularVelocity = self.angularVelocity + ([self torques]*[self dt])/[self momentOfInertia];
}
-(Matrix2D*)rotationM {
    return [Matrix2D matrixWithValues:cos(self.rotation) and:sin(self.rotation) and:-sin(self.rotation) and:cos(self.rotation)];
}
-(Vector2D*)hVector {
    return [Vector2D vectorWith:self.width/2.0 y:self.height/2.0];
}
-(Vector2D*)distanceFrom:(NPRectangle*)other {
    return [[other center] subtract:self.center];
}
-(Vector2D*)distanceInSelfSystemFrom:(NPRectangle*)other {
    //dA = Rta x d
    //returns a distance between self and other projected in self's coordinate system
    return [[[self rotationM] transpose] multiplyVector:[self distanceFrom:other]];
}
-(Vector2D*)distanceInOtherSystemFrom:(NPRectangle*)other {
    //dB = Rtb x d
    //returns a distance between self and other projected in other's coordinate system
    return [[[other rotationM] transpose] multiplyVector:[self distanceFrom:other]];
}
-(Matrix2D*)transformOtherToSelfSystem:(NPRectangle*)other {
    //C = Rta x Rb
    //retruns a matrix that can convert from other's coordinate system to self
    return [[[self rotationM] transpose] multiply:[other rotationM]];
}
-(Vector2D*)fVectorSelf:(NPRectangle*)other {
    //fA = dA -hA -C x hB
    //helper function to calculate fA
    return [[[[self distanceInSelfSystemFrom:other] abs] subtract:[self hVector]] subtract:[[[self transformOtherToSelfSystem:other] abs] multiplyVector:[other hVector]]];
}
-(Vector2D*)fVectorOther:(NPRectangle*)other {
    //helper function to calculate fB
    return [[[[self distanceInOtherSystemFrom:other] abs] subtract:[other hVector]] subtract:[[[[self transformOtherToSelfSystem:other] transpose] abs] multiplyVector:[self hVector]]];
}
-(BOOL)checkNegativeFVectorComponents:(NPRectangle*)other {
    //retruns a YES if all fVector components are negative
    Vector2D* fself = [self fVectorSelf:other];
    Vector2D* fother = [self fVectorOther:other];
    return (fself.x <= 0) && (fself.y <= 0) && (fother.x <= 0) && (fother.y <= 0);
}
-(kfVectorComp)optimizedRefEdge:(NPRectangle*)other {
    Vector2D* fself = [self fVectorSelf:other];
    Vector2D* fother = [self fVectorOther:other];
    Vector2D* hself = [self hVector];
    Vector2D* hother = [other hVector];
    double fVals[4] = {fself.x,fself.y,fother.x,fother.y};
    
    CGFloat dAx = fself.x - BIAS_CONST_2*hself.x;
    CGFloat dAy = fself.y - BIAS_CONST_2*hself.y;
    CGFloat dBx = fother.x - BIAS_CONST_2*hother.x;
    CGFloat dBy = fother.y - BIAS_CONST_2*hother.y;
    double dVals[4] = {dAx,dAy,dBx,dBy};
    
    BOOL satisfies = YES;
    for (int i = 0; i < 4;i++ ) {
        satisfies = YES;
        for (int j= 0; j < 4; j++) {
            if (BIAS_ROW*fVals[j] >= dVals[i]) {
                satisfies = NO;
            }
        }
        if (satisfies) {
            return i;
        }
    }
    return [self detectMinComponent:other];
}
-(kfVectorComp)detectMinComponent:(NPRectangle*)other {
    //returns the fVector component with the smallest maginitude(or largest as they are all negative)
    Vector2D* fself = [self fVectorSelf:other];
    Vector2D* fother = [self fVectorOther:other];
    CGFloat min = fabs(fself.x);
    kfVectorComp res = AX;
    if (min > fabs(fself.y)) {
        min = fabs(fself.y);
        res = AY;
    }
    if (min > fabs(fother.x)) {
        min = fabs(fother.x);
        res = BX;
    }
    if (min > fabs(fother.y)) {
        min = fother.y;
        res = BY;
    }
    return res;
}
-(NSDictionary*)getRefEdge:(NPRectangle*)other {
    //returns a Dictionary of results regarding the reference edge including the normals, and distances dPos,dNeg, dRef etc
    kEdgeType collisionEdgeType;
    Vector2D* normal;
    Vector2D* normalF;
    Vector2D* normalS;
    CGFloat distanceWorldOriginAndRefEdge;
    CGFloat distanceWorldOriginAndPosEdge;
    CGFloat distanceWorldOriginAndNegEdge;
    CGFloat distanceWorldOriginAndS;
    kfVectorComp fVector = [self detectMinComponent:other];
    if (fVector == AX) {
        if ([self distanceInSelfSystemFrom:other].x > 0) {
            normal = [[self rotationM] col1];
            collisionEdgeType = E1;
        } else {
            normal = [[[self rotationM] col1] negate];
            collisionEdgeType = E3;
        }
        normalF = normal;
        distanceWorldOriginAndRefEdge = [self.center dot:normalF] + [self hVector].x;
        normalS = [self rotationM].col2;
        distanceWorldOriginAndS = [self.center dot:normalS];
        distanceWorldOriginAndNegEdge = [self hVector].y - distanceWorldOriginAndS;
        distanceWorldOriginAndPosEdge = [self hVector].y + distanceWorldOriginAndS;
        
    } else if (fVector == AY) {
        if ([self distanceInSelfSystemFrom:other].y > 0) {
            normal = [[self rotationM] col2];
            collisionEdgeType = E4;
        } else {
            normal = [[[self rotationM] col2] negate];
            collisionEdgeType = E2;
        }
        normalF = normal;
        distanceWorldOriginAndRefEdge = [self.center dot:normalF] + [self hVector].y;
        normalS = [self rotationM].col1;
        distanceWorldOriginAndS = [self.center dot:normalS];
        distanceWorldOriginAndNegEdge = [self hVector].x - distanceWorldOriginAndS;
        distanceWorldOriginAndPosEdge = [self hVector].x + distanceWorldOriginAndS;
    
    } else if (fVector == BX) {
        
        if ([self distanceInOtherSystemFrom:other].x > 0) {
            normal = [[other rotationM] col1];
            collisionEdgeType = E3;
        } else {
            normal = [[[other rotationM] col1] negate];
            collisionEdgeType = E1;
        }
        normalF = [normal negate];
        distanceWorldOriginAndRefEdge = [other.center dot:normalF] + [other hVector].x;
        normalS = [[other rotationM] col2];
        distanceWorldOriginAndS = [other.center dot:normalS];
        distanceWorldOriginAndNegEdge = [other hVector].y - distanceWorldOriginAndS;
        distanceWorldOriginAndPosEdge = [other hVector].y + distanceWorldOriginAndS;
    
    } else if (fVector == BY) {
        if ([self distanceInOtherSystemFrom:other].y > 0) {
            normal = [[other rotationM] col2];
            collisionEdgeType = E2;
        } else {
            normal = [[[other rotationM] col2] negate];
            collisionEdgeType = E4;
        }
        normalF = [normal negate];
        distanceWorldOriginAndRefEdge = [other.center dot:normalF] + [other hVector].y;
        normalS = [[other rotationM] col1];
        distanceWorldOriginAndS = [other.center dot:normalS];
        distanceWorldOriginAndNegEdge = [other hVector].x - distanceWorldOriginAndS;
        distanceWorldOriginAndPosEdge = [other hVector].x + distanceWorldOriginAndS;
    }
    return @{@"collisionEdgeType": [NSNumber numberWithInt:collisionEdgeType],
            @"distanceWorldAndNegEdge": [NSNumber numberWithFloat:distanceWorldOriginAndNegEdge],
            @"distanceWorldAndPosEdge": [NSNumber numberWithFloat:distanceWorldOriginAndPosEdge],
            @"distanceWorldAndRefEdge": [NSNumber numberWithFloat:distanceWorldOriginAndRefEdge],
            @"normalF": normalF,
            @"normalS": normalS,
            @"normal":normal};
}

- (NSDictionary*)getIncidentEdge:(NPRectangle*)other {
    //returns a dictionary of vectors describing the incident edge
    Vector2D *incidentV1;
    Vector2D *incidentV2;
    Vector2D *incidentP;
    Vector2D *incidentHVector;
    Vector2D *normalI;
    Matrix2D *incidentRotation;
    kfVectorComp fVector = [self detectMinComponent:other];
    NSDictionary* refResults = [self getRefEdge:other];
    Vector2D *normalF = (Vector2D*)[refResults objectForKey:@"normalF"];
    if (fVector == AX || fVector == AY) {
        // nI = -Rtb x nF
        normalI = [[[[other rotationM] transpose] multiplyVector:normalF] negate];
        incidentP = [other center];
        incidentRotation = [other rotationM];
        incidentHVector = [other hVector];
    } else {
        // nI = -Rta x nF
        normalI = [[[[self rotationM] transpose] multiplyVector:normalF] negate];
        incidentP = [self center];
        incidentRotation = [self rotationM];
        incidentHVector = [self hVector];
    }
    if ([normalI abs].x > [normalI abs].y && normalI.x > 0) {
        incidentV1 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:incidentHVector.x y:-1*incidentHVector.y]]];
        incidentV2 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:incidentHVector.x y:incidentHVector.y]]];
        
    } else if ([normalI abs].x > [normalI abs].y && normalI.x <= 0) {
        incidentV1 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:-1*incidentHVector.x y:incidentHVector.y]]];
        incidentV2 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:-1*incidentHVector.x y:-1*incidentHVector.y]]];
    
    } else if ([normalI abs].x <= [normalI abs].y && normalI.y > 0) {
        incidentV1 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:incidentHVector.x y:incidentHVector.y]]];
        incidentV2 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:-1*incidentHVector.x y:incidentHVector.y]]];
    
    } else if ([normalI abs].x <= [normalI abs].y && normalI.y <= 0) {
        incidentV1 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:-1*incidentHVector.x y:-1*incidentHVector.y]]];
        incidentV2 = [incidentP add:[incidentRotation multiplyVector:[Vector2D vectorWith:incidentHVector.x y:-1*incidentHVector.y]]];
    }
    return @{@"incidentV1": incidentV1,
             @"incidentV2": incidentV2}
    ;
}
-(NSDictionary*)clippingWith:(NPRectangle*)other {
    //checks for collision, applies clipping, returns either a dict containing the contact points, normal and tangent vectors etc if a collision occurs, else just returns a bool collision : NO
    if (![self checkNegativeFVectorComponents:other]) {
        return @{@"collision":[[NSNumber alloc] initWithBool:NO]};
    }
    NSDictionary* incidentRes = [self getIncidentEdge:other];
    Vector2D* incidentV1 = [incidentRes objectForKey:@"incidentV1"];
    Vector2D* incidentV2 = [incidentRes objectForKey:@"incidentV2"];
    Vector2D* clippedV1;
    Vector2D* clippedV2;
    NSDictionary* refRes = [self getRefEdge:other];
    Vector2D* normalS = [refRes objectForKey:@"normalS"];
    Vector2D* normalF = [refRes objectForKey:@"normalF"];
    NSNumber* distanceNeg = [refRes objectForKey:@"distanceWorldAndNegEdge"];
    
    CGFloat dist1 = -[normalS dot:incidentV1] - [distanceNeg floatValue];
    CGFloat dist2 = -[normalS dot:incidentV2] - [distanceNeg floatValue];
    if (dist1 > 0 && dist2 > 0) {
        return @{@"collision":[[NSNumber alloc] initWithBool:NO]};
    } else if (dist1 <= 0 && dist2 <= 0) {
        clippedV1 = incidentV1;
        clippedV2 = incidentV2;
    } else if (dist1 <= 0 && dist2 > 0) {
        clippedV1 = incidentV1;
        clippedV2 = [incidentV1 add:[[incidentV2 subtract:incidentV1] multiply:(dist1/(dist1 - dist2))]];
    } else {
        clippedV1 = incidentV2;
        clippedV2 = [incidentV1 add:[[incidentV2 subtract:incidentV1] multiply:(dist1/(dist1 - dist2))]];
    }
    Vector2D* clipped2V1;
    Vector2D* clipped2V2;
    NSNumber* distancePos = [refRes objectForKey:@"distanceWorldAndPosEdge"];
    dist1 = [normalS dot:clippedV1] - [distancePos floatValue];
    dist2 = [normalS dot:clippedV2] - [distancePos floatValue];
    if (dist1 > 0 && dist2 > 0) {
        return @{@"collision":[[NSNumber alloc] initWithBool:NO]};
    } else if (dist1 <=0 && dist2 <= 0) {
        clipped2V1 = clippedV1;
        clipped2V2 = clippedV2;
    } else if (dist1 <= 0 && dist2 > 0) {
        clipped2V1 = clippedV1;
        clipped2V2 = [clippedV1 add:[[clippedV2 subtract:clippedV1] multiply:(dist1/(dist1 - dist2))]];
    } else {
        clipped2V1 = clippedV2;
        clipped2V2 = [clippedV1 add:[[clippedV2 subtract:clippedV1] multiply:(dist1/(dist1 - dist2))]];
    }
    NSNumber* distanceRef = [refRes objectForKey:@"distanceWorldAndRefEdge"];
    CGFloat separation1 = [normalF dot:clipped2V1] - [distanceRef floatValue];
    CGFloat separation2 = [normalF dot:clipped2V2] - [distanceRef floatValue];
    Vector2D* contact1 = nil;
    if (separation1 <= 0) {
        contact1 = [clipped2V1 subtract:[normalF multiply:separation1]];

    }
    Vector2D* contact2 = nil;
    if (separation2 <= 0) {
        contact2 = [clipped2V2 subtract:[normalF multiply:separation2]];
    }
    
    Vector2D* normal = [refRes objectForKey:@"normal"];
    Vector2D* tangent = [normal crossZ:1];
    if (contact1 && contact2) {
        return @{@"contact1":contact1,
            @"contact2":contact2,
            @"sep1":[NSNumber numberWithFloat:separation1],
            @"sep2":[NSNumber numberWithFloat:separation2],
            @"normal":normal,
            @"tangent":tangent,
            @"collision":[[NSNumber alloc] initWithBool:YES]};

    } else if (contact1) {
        return @{@"contact1":contact1,
        @"sep1":[NSNumber numberWithFloat:separation1],
        @"sep2":[NSNumber numberWithFloat:separation2],
        @"normal":normal,
        @"tangent":tangent,
        @"collision":[[NSNumber alloc] initWithBool:YES]};
    } else if (contact2){
        return @{@"contact2":contact2,
        @"sep1":[NSNumber numberWithFloat:separation1],
        @"sep2":[NSNumber numberWithFloat:separation2],
        @"normal":normal,
        @"tangent":tangent,
        @"collision":[[NSNumber alloc] initWithBool:YES]};
    } else {
        NSLog(@"fucked");
        return @{@"collision":[[NSNumber alloc] initWithBool:NO]};
    }
    
}
+(CGFloat)normalMassAtContact:(NPRectangle*)A with:(NPRectangle*)B rA:(Vector2D*)rA rB:(Vector2D*)rB normal:(Vector2D*)n {
    return 1.0/(1.0/A.mass + 1.0/B.mass + ([rA dot:rA] - ([rA dot:n]*[rA dot:n]))/[A momentOfInertia] + ([rB dot:rB] - [rB dot:n]*[rB dot:n])/[B momentOfInertia]);
}
+(CGFloat)tangentMassAtContact:(NPRectangle*)A with:(NPRectangle*)B rA:(Vector2D*)rA rB:(Vector2D*)rB tangent:(Vector2D*)t {
    return 1.0/(1.0/A.mass + 1.0/B.mass + ([rA dot:rA] - ([rA dot:t]*[rA dot:t]))/[A momentOfInertia] + ([rB dot:rB] - [rB dot:t]*[rB dot:t])/[B momentOfInertia]);
}

-(void)applyImpulseAt:(Vector2D*)contact with:(NPRectangle*)other normal:(Vector2D*)normal tangent:(Vector2D*)tangent sep:(CGFloat)separation{

    //applies impulse at a contact point
    Vector2D* dirCToSelf = [contact subtract:self.center];
    Vector2D* dirCToOther = [contact subtract:other.center];
    
    Vector2D* uVectorSelf = [self.velocity add:[dirCToSelf crossZ:-self.angularVelocity]];
    Vector2D* uVectorOther = [other.velocity add:[dirCToOther crossZ:-other.angularVelocity]];
    
    Vector2D* uRelative = [uVectorOther subtract:uVectorSelf];
    
    CGFloat uNormal = [uRelative dot:normal];
 
    CGFloat uTangent = [uRelative dot:tangent];
    
    CGFloat normalMass = [NPRectangle normalMassAtContact:self with:other rA:dirCToSelf rB:dirCToOther normal:normal];
    CGFloat tangentMass = [NPRectangle tangentMassAtContact:self with:other rA:dirCToSelf rB:dirCToOther tangent:tangent];
    CGFloat combinedRest = sqrt(self.restituition*other.restituition);
    Vector2D* normalImpulse = [normal multiply: fmin(0, normalMass*((1 + combinedRest)*uNormal)- [self bias:separation])];
    
    CGFloat dTangentImpulse = tangentMass*uTangent;
    CGFloat tangentImpulseMax = self.friction*other.friction*[normalImpulse magnitude];
    dTangentImpulse = fmax(-tangentImpulseMax, fmin(dTangentImpulse,tangentImpulseMax));
    Vector2D* tangentImpulse = [tangent multiply:dTangentImpulse];
    
    self.velocity = [self.velocity add:[[normalImpulse add:tangentImpulse] multiply:1.0/self.mass]];
    other.velocity = [other.velocity subtract:[[normalImpulse add:tangentImpulse] multiply:1.0/other.mass]];
    
    self.angularVelocity = self.angularVelocity + [dirCToSelf cross:[normalImpulse add:tangentImpulse]]*1.0/[self momentOfInertia];
    other.angularVelocity = other.angularVelocity - [dirCToOther cross:[normalImpulse add:tangentImpulse]]*1.0/[other momentOfInertia];
    
}
-(void)applyAllWith:(NPRectangle*)other {
    //helper method to update position and rotation
    self.center = [self.center add:[self.velocity multiply:self.dt]];
    other.center = [other.center add:[other.velocity multiply:other.dt]];
    self.rotation = self.rotation + self.dt*self.angularVelocity;
    other.rotation = other.rotation + other.dt*other.angularVelocity;
    [self.delegate updateController];
    [other.delegate updateController];

}
-(CGFloat)bias:(CGFloat)separation {
    //evaluates a bias to stop sinking into walls
    return -BIAS_CONST_1/self.dt*(BIAS_CONST_2 + separation);
}
-(void)applyEpsilon {
    if (fabs(self.angularVelocity) < ROTATION_EPSILON1) {
        self.angularVelocity = 0;
    }
    if (fabs(self.velocity.y) < VELOCITY_EPSILON) {
        self.velocity = [Vector2D vectorWith:self.velocity.x y:0];
    }
    if (fabs(self.velocity.x) < VELOCITY_EPSILON) {
        self.velocity = [Vector2D vectorWith:0 y:self.velocity.y];
    }
}
-(void)updateSelfWith:(NPRectangle*)other {
    //applies an upadte with another Rectangle. Detects if collision occurs, and updates state accordingly
    if (self.rectType == WALL && other.rectType == WALL) {
        return;
    }
    [self applyForces];
    [self applyTorques];
    [other applyForces];
    [other applyTorques];
    NSDictionary* clipRes = [self clippingWith:other];
    BOOL collision = [[clipRes objectForKey:@"collision"] boolValue];
    if (!collision) {
        [self applyAllWith:other];
        return;
    }
    Vector2D* contact1 = [clipRes objectForKey:@"contact1"];
    Vector2D* contact2 = [clipRes objectForKey:@"contact2"];
    NSNumber* sep1 = [clipRes objectForKey:@"sep1"];
    NSNumber* sep2 = [clipRes objectForKey:@"sep2"];
    Vector2D* normal = [clipRes objectForKey:@"normal"];
    Vector2D* tangent = [clipRes objectForKey:@"tangent"];

    for (int i = 0; i < IMPULSE_ITERATIONS; i++) {
        if (contact1) {
            [self applyImpulseAt:contact1 with:other normal:normal tangent:tangent sep:[sep1 floatValue]];
        }
        if (contact2) {
            [self applyImpulseAt:contact2 with:other normal:normal tangent:tangent sep:[sep2 floatValue]];
        }
        [self applyEpsilon];
        [other applyEpsilon];

    }
 
 
    [self applyAllWith:other];
}
@end
