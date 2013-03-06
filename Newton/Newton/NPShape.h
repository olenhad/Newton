//
//  NPShape.h
//  Newton
//
//  Created by omer iqbal on 8/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
@interface NPShape : NSObject

-(void)updateSelfWith:(NPShape*)other;

@end
