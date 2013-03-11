//
//  ViewController.m
//  bobblehead
//
//  Software copyright (c) 2013 Plaid Software, LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@implementation ViewController
@synthesize bobbleHead;
CMMotionManager *motionManager;


CGPoint defaultLocation;

CGPoint dragStartLocation;
CGPoint currentLocation;
CGPoint offset;

float weight = 0.4f;
float decay = 0.9f;

// Start with a little jiggle to show it is a bobblehead
float xVelocity = 2;
float yVelocity = 6;

bool draggingHead = NO;

#define kUpdateFrequency 20  // Hz
#define kNoReadingValue 999
- (void)viewDidLoad
{    
    defaultLocation = bobbleHead.center;
    
    motionManager = [[CMMotionManager alloc] init]; // motionManager is an instance variable
    motionManager.accelerometerUpdateInterval = 0.01; // 100Hz
    [motionManager startAccelerometerUpdates];
}

int MAX_X = 15;
int MAX_Y = 15;

- (void)update
{
    CMAccelerometerData *newestAccelerationData = motionManager.accelerometerData;    
    xVelocity += (newestAccelerationData.acceleration.x * 2);
    yVelocity = yVelocity + ((newestAccelerationData.acceleration.y + newestAccelerationData.acceleration.z) * 1.5);
    
    CGPoint pointOfInterest = defaultLocation;
    if (draggingHead)
    {
        // bobble around the user's location, but limit how far it can go
        float deltaX = dragStartLocation.x - currentLocation.x;
        if (deltaX < -MAX_X) 
        {
            deltaX = -MAX_X;
        } else if (deltaX > MAX_X)
        {
            deltaX = MAX_X;
        }
        
        float deltaY = dragStartLocation.y - currentLocation.y;
        if (deltaY < -MAX_Y)
        {
            deltaY = -MAX_Y;
        } else if (deltaY > MAX_Y)
        {
            deltaY = MAX_Y;
        }
        
        pointOfInterest = CGPointMake(defaultLocation.x - deltaX - offset.y, defaultLocation.y - deltaY - offset.y);
    }
    
    double xAcceleration = (pointOfInterest.x - bobbleHead.center.x) * weight;
    double yAcceleration = (pointOfInterest.y - bobbleHead.center.y) * weight;
    
    xVelocity = (xVelocity + xAcceleration) * decay;
    yVelocity = (yVelocity + yAcceleration) * decay;
    
    [bobbleHead setCenter:CGPointMake(bobbleHead.center.x + xVelocity, bobbleHead.center.y + yVelocity)];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - User Touch Events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (CGRectContainsPoint(bobbleHead.frame,[touch locationInView:self.view])) {
            draggingHead = YES;
            dragStartLocation = [touch locationInView:self.view];
            currentLocation = dragStartLocation;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    draggingHead = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentLocation = [[touches anyObject] locationInView:self.view];
}

#pragma mark - Accelerometer
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    xVelocity += (acceleration.x * 1.5);
    yVelocity = yVelocity + ((acceleration.y + acceleration.z) * 1.5);
}
@end
