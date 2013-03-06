//
//  ViewController.h
//  Newton
//
//  Created by omer iqbal on 7/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <stdlib.h>
#import "RectViewController.h"
#import "NPWorld.h"
@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *worldView;
@property (strong, nonatomic) IBOutlet UIImageView *sp1;
@property NSMutableArray* rectViews;
@property NPWorld* world;
@property UIView* nRect;
@property CMMotionManager* mManager;
@end
