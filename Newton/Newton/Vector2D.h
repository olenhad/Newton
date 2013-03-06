//
//
//  NUS CS3217 2012 
//  Problem Set 4
//  The Physics Engine
//
//

#import <Foundation/Foundation.h>
#import "NPConstants.h"

@interface Vector2D : NSObject {
// OVERVIEW: This class implements an immutable 2-dimensional vector
//             and supports some basic vector operations. 
  CGFloat x, y;
}

@property (readonly) CGFloat x;
@property (readonly) CGFloat y;

@property (readonly) CGFloat length;
// EFFECTS: Returns the length of this vector

// Static method for return auto-released Vector2D
+(Vector2D*)vectorWith:(CGFloat)x y:(CGFloat)y;
  // EFFECTS: Returns an autoreleased 2D vector

-(Vector2D*)add:(Vector2D*)v;
  // REQUIRES: v != nil 
  // EFFECTS: Returns a new vector that is the sum of self and v.

-(Vector2D*)subtract:(Vector2D*)v;
  // REQUIRES: v != nil 
  // EFFECTS: Returns a new vector that is equal to self minus v.

-(Vector2D*)multiply:(CGFloat)scalar;
  // EFFECTS: Returns a new vector that is the scalar multiple of self.

-(Vector2D*)abs;
  // EFFECTS: Returns a new vector consisting of the absolute (abs) values of the various components.

-(Vector2D*)negate;
  // EFFECTS: Returns a new vector that is the negation of this vector

-(CGFloat)dot:(Vector2D*)v;
  // REQUIRES: v != nil 
  // EFFECTS: Returns the dot product of self and v

-(CGFloat)cross:(Vector2D*)v;
  // REQUIRES: v != nil 
  // EFFECTS: Returns the cross product of self and v
  //		Since cross product is a vector perpendicular to x-y-plane,
  //		x and y components are zero, thus only the z-component
  //		is returned, which is a double.

-(Vector2D*)crossZ:(CGFloat)v;
  // EFFECTS: Returns the cross product of this vector
  //		with a Z-component of double v
+(Vector2D*)gravity;
// EFFECT: returns a default gravity vector
-(CGFloat)magnitude;
@end
