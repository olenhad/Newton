//
//  ViewController.m
//  Newton
//
//  Created by omer iqbal on 7/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _rectViews = [NSMutableArray new];
    UIView *rectv1 = [[UIView alloc] initWithFrame:CGRectMake(200, 250, 150, 50)];
    UIView *wallv2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1000, 800, 60)];
    UIView *rectv2 = [[UIView alloc] initWithFrame:CGRectMake(300, 50, 50, 50)];
    UIView *wallv1 = [[UIView alloc] initWithFrame:CGRectMake(768, 0, 50, 1024)];
    UIView *wallv3 = [[UIView alloc] initWithFrame:CGRectMake(-50, 0, 50, 1024)];
    UIView *wallv4 = [[UIView alloc] initWithFrame:CGRectMake(0,-50, 800, 50)];
    
    [rectv1 setBackgroundColor:[[UIColor alloc] initWithRed:0.5 green:0.1 blue:0.7 alpha:0.5]];
    [wallv2 setBackgroundColor:[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [wallv1 setBackgroundColor:[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [wallv3 setBackgroundColor:[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
      [wallv4 setBackgroundColor:[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [rectv2 setBackgroundColor:[[UIColor alloc] initWithRed:0.5 green:0.1 blue:0.7 alpha:1.0]];
       [_worldView addSubview:wallv1];
    [_worldView addSubview:wallv2];
    [_worldView addSubview:wallv3];
    [_worldView addSubview:wallv4];

    [self addRectToView:rectv1];
    [self addRectToView:rectv2];
 
    RectViewController* rect1 = [[RectViewController alloc] initWithSprite:rectv1];
    RectViewController* rect2 = [[RectViewController alloc] initWithSprite:rectv2];
    RectViewController* wall2 = [[RectViewController alloc] initWithSpriteAsWall:wallv2];
    RectViewController* wall1 = [[RectViewController alloc] initWithSpriteAsWall:wallv1];
    RectViewController* wall3 = [[RectViewController alloc] initWithSpriteAsWall:wallv3];
    RectViewController* wall4 = [[RectViewController alloc] initWithSpriteAsWall:wallv4];
    _world = [[NPWorld alloc] init];
  
        [_world addObject:wall1.model];
    [_world addObject:wall2.model];
    [_world addObject:wall3.model];
    [_world addObject:wall4.model];
    [_world addObject:rect1.model];
    [_world addObject:rect2.model];
    [_world startWorld];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMode:)];
    [self.view addGestureRecognizer:tap];
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(addRectangle:)];
    [self.view addGestureRecognizer:pinch];
    
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reset:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self initMotion];
    
}
- (void)initMotion {
    
    // Determine the update interval
    NSTimeInterval delta = 0.05;
    //NSTimeInterval updateInterval = accelerometerMin + delta * sliderValue;
    
    // Create a CMMotionManager
    _mManager = [[CMMotionManager alloc] init];
    // Check whether the accelerometer is available
    if ([_mManager isAccelerometerAvailable] == YES) {
        // Assign the update interval to the motion manager
        [_mManager setAccelerometerUpdateInterval:delta];
        [_mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accData, NSError *error) {
            [_world updateGravity:[Vector2D vectorWith: ACC_FACTOR*accData.acceleration.x y:-ACC_FACTOR*accData.acceleration.y]];
        }];
    }
}
- (void)addRectToView:(UIView*)view {
    [self.view addSubview:view];
    [self.rectViews addObject:view];
}
- (void)reset:(UIGestureRecognizer*)gesture {
    [self.world resetWorld];
    for (UIView* view in _rectViews) {
        [view removeFromSuperview];
    }

}
- (void)move:(UIGestureRecognizer*)gesture {
    NSLog(@"Trnalsate");
}
- (void)changeMode:(UITapGestureRecognizer*)tap {
    if (self.world.isOn) {
        [self.world stopWorld];
    } else {
        [self.world startWorld];
    }
}
- (void)addRectangle:(UIPinchGestureRecognizer*)pinch {

    if (pinch.state == UIGestureRecognizerStateBegan)
    {
        _nRect = [[UIView alloc] initWithFrame:CGRectMake([pinch locationInView:self.view].x, [pinch locationInView:self.view].y, 50 + arc4random()%100, 50 + arc4random()%100)];
        [_nRect setBackgroundColor:[[UIColor alloc] initWithRed:[self genRandom] green:[self genRandom] blue:[self genRandom] alpha:1.0]];
        [self addRectToView:_nRect];
        RectViewController* temp = [[RectViewController alloc] initWithSprite:_nRect];
        temp.model.gravity = self.world.curGravity;
        [_world addObject:temp.model];
    }
}
- (double)genRandom {
    int r = arc4random()%1000;
    return (double) 1.0*r/1000;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)orientationChanged:(NSNotification *)notification {
    // Respond to changes in device orientation
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait) {
        [_world updateGravity:[Vector2D vectorWith:0 y:GRAVITY]];
    } else if (orientation == UIDeviceOrientationLandscapeLeft) {
        [_world updateGravity:[Vector2D vectorWith:-GRAVITY y:0]];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        [_world updateGravity:[Vector2D vectorWith:GRAVITY y:0]];
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown){
        [_world updateGravity:[Vector2D vectorWith:0 y:-GRAVITY]];
    } else {
        [_world updateGravity:[Vector2D vectorWith:0 y:GRAVITY]];
    }
}

-(void) viewDidDisappear {
    // Request to stop receiving accelerometer events and turn off accelerometer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

    if (toInterfaceOrientation == UIInterfaceOrientationPortrait){
        return YES;
    } else {
        return NO;
    }
}

@end
