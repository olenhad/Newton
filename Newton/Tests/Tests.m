//
//  Tests.m
//  Tests
//
//  Created by omer iqbal on 9/2/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "Tests.h"

@implementation Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNegativeFVectors
{
    NPRectangle* rect1 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:10 y:10] height:100 width:100 rotation:0];
     NPRectangle* rect2 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:20 y:20] height:100 width:100 rotation:0];
    // rect1 and rect2 overlap for sure
    
    STAssertTrue([rect1 checkNegativeFVectorComponents:rect2], @"",@"");
}
- (void)testClipping {
    NPRectangle* rect1 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:10 y:10] height:50 width:20 rotation:0];
    
    NPRectangle* rect2 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:500 y:10] height:50 width:20 rotation:0];
    NSDictionary* clipRes = [rect1 clippingWith:rect2];
    NSNumber* collidewrap = [clipRes objectForKey:@"collision"];
    STAssertFalse([collidewrap boolValue], @"",@"");
    NPRectangle* rect3 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:31 y:10] height:50 width:20 rotation:0.6];
    clipRes = [rect1 clippingWith:rect3];
    STAssertTrue([[clipRes objectForKey:@"collision"] boolValue], @"",@"");
    
}
- (void)testContactPointsE2 {
    NPRectangle* rect1 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:0 y:0] height:50 width:50 rotation:0];
    NPRectangle* rect2 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:50 y:0] height:50 width:50 rotation:0];
    NSDictionary* clipRes = [rect1 clippingWith:rect2];
    Vector2D* c1 = [clipRes objectForKey:@"contact1"];
    Vector2D* c2 = [clipRes objectForKey:@"contact2"];
    STAssertTrue(c1.x < 25.01 && c1.x > 24.99, @"",@"");
    STAssertTrue(c1.y < 25.01 && c1.y > 24.99, @"",@"");
    STAssertTrue(c2.x < 25.01 && c2.x > 24.99, @"",@"");
    STAssertTrue(c2.y > -25.01 && c2.y < -24.99, @"",@"");
}
- (void)testContactPointsE1 {
    NPRectangle* rect1 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:0 y:0] height:50 width:50 rotation:0];
    NPRectangle* rect2 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:0 y:50] height:50 width:50 rotation:0];
    NSDictionary* clipRes = [rect2 clippingWith:rect1];
    Vector2D* c1 = [clipRes objectForKey:@"contact1"];
    Vector2D* c2 = [clipRes objectForKey:@"contact2"];
    STAssertTrue(c1.x < 25.01 && c1.x > 24.99, @"",@"");
    STAssertTrue(c1.y < 25.01 && c1.y > 24.99, @"",@"");
    STAssertTrue(c2.x > -25.01 && c2.x < -24.99, @"",@"");
    STAssertTrue(c2.y < 25.01 && c2.y > 24.99, @"",@"");
}
- (void)testContactPointsE3 {
    NPRectangle* rect1 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:0 y:0] height:50 width:50 rotation:0];
    NPRectangle* rect2 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:0 y:50] height:50 width:50 rotation:0];
    NSDictionary* clipRes = [rect1 clippingWith:rect2];
    Vector2D* c1 = [clipRes objectForKey:@"contact1"];
    Vector2D* c2 = [clipRes objectForKey:@"contact2"];
    STAssertTrue(c1.x > -25.01 && c1.x < -24.99, @"",@"");
    STAssertTrue(c1.y < 25.01 && c1.y > 24.99, @"",@"");
    STAssertTrue(c2.x < 25.01 && c2.x > 24.99, @"",@"");
    STAssertTrue(c2.y < 25.01 && c2.y > 24.99, @"",@"");
}
- (void)testContactPointsE4 {
    NPRectangle* rect1 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:0 y:0] height:50 width:50 rotation:0];
    NPRectangle* rect2 = [[NPRectangle alloc] initWithCenter:[Vector2D vectorWith:50 y:0] height:50 width:50 rotation:0];
    NSDictionary* clipRes = [rect2 clippingWith:rect1];
    Vector2D* c1 = [clipRes objectForKey:@"contact1"];
    Vector2D* c2 = [clipRes objectForKey:@"contact2"];
    STAssertTrue(c1.x < 25.01 && c1.x > 24.99, @"",@"");
    STAssertTrue(c1.y > -25.01 && c1.y < -24.99, @"",@"");
    STAssertTrue(c2.x < 25.01 && c2.x > 24.99, @"",@"");
    STAssertTrue(c2.y < 25.01 && c2.y > 24.99, @"",@"");
}

@end
