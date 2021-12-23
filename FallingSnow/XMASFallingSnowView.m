#import "XMASFallingSnowView.h"
#import <math.h>

#define selfFlakeWidth 20.0
#define selfFlakeHeight 23.0
#define flakeMinimumSize 0.4

@implementation XMASFallingSnowView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.animationDurationMin = 5;
        self.animationDurationMax = 11;

        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.ryannair05.snoverlay"];

        [userDefaults registerDefaults:@{
            @"enabled": @YES,
            @"numSnowflakes": @160,
            @"snowFlakeType": @0,
            @"highQuality" : @NO
        }];

        if ([userDefaults boolForKey:@"enabled"]) {
            self.flakeFileName = [userDefaults integerForKey:@"snowFlakeType"] ? @"XMASSnowflake1.png" : @"XMASSnowflake.png";
            self.flakesCount = [userDefaults integerForKey:@"numSnowflakes"];

            if ([userDefaults boolForKey:@"highQuality"]) {
                [self performSelector:@selector(beginSnowAnimation) withObject:nil afterDelay:1.5];
            }
            else {
                [self beginSnowEmmitter];
            }
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handlePrefs) 
        name:@"com.ryannair05.snoverlay/prefsupdated"
        object:nil];

    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.ryannair05.snoverlay/prefsupdated"object:nil];
}

-(void)handlePrefs {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.ryannair05.snoverlay"];

    [userDefaults registerDefaults:@{
        @"enabled": @YES,
        @"numSnowflakes": @160,
        @"snowFlakeType": @0,
        @"highQuality" : @NO
    }];

    [[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    self.layer.sublayers = nil;
    self.flakesArray = nil;

    if ([userDefaults boolForKey:@"enabled"]) {
        self.flakeFileName = [userDefaults integerForKey:@"snowFlakeType"] ? @"XMASSnowflake1.png" : @"XMASSnowflake.png";
        self.flakesCount = [userDefaults integerForKey:@"numSnowflakes"];

        if ([userDefaults boolForKey:@"highQuality"]) {
            [self beginSnowAnimation];
        }
        else {
            [self beginSnowEmmitter];
        }
    }
}

- (void)beginSnowEmmitter {
    UIImage *flakeImg = [UIImage imageWithContentsOfFile: [@"/Library/Application Support/Snoverlay/" stringByAppendingString: self.flakeFileName]];

    CAEmitterCell *flakeEmitterCell = [CAEmitterCell emitterCell];
    flakeEmitterCell.contents = (__bridge id _Nullable) flakeImg.CGImage;
    if ([self.flakeFileName isEqualToString:@"XMASSnowflake.png"]) {
        flakeEmitterCell.scale = 0.3;
        flakeEmitterCell.scaleRange = 0.25;
    }
    else {
        flakeEmitterCell.scale = 0.05;
        flakeEmitterCell.scaleRange = 0.03;
    }
    flakeEmitterCell.lifetime = 15.0;
    flakeEmitterCell.birthRate = self.flakesCount >> 3;
    flakeEmitterCell.emissionRange = M_PI;
    flakeEmitterCell.velocity = -20;
    flakeEmitterCell.velocityRange = 100;
    flakeEmitterCell.yAcceleration = 20;
    flakeEmitterCell.zAcceleration = 10;
    flakeEmitterCell.xAcceleration = 5;
    flakeEmitterCell.spinRange = M_PI * 2;

    _snowEmitterLayer = [CAEmitterLayer layer];
    _snowEmitterLayer.emitterPosition = CGPointMake(self.bounds.size.width / 2.0 - 50, -50);
    _snowEmitterLayer.emitterSize = CGSizeMake(self.bounds.size.width, 0);
    _snowEmitterLayer.emitterShape =  kCAEmitterLayerLine;
    _snowEmitterLayer.beginTime = CACurrentMediaTime();
    _snowEmitterLayer.timeOffset = 10;
    _snowEmitterLayer.emitterCells = [NSArray arrayWithObject:flakeEmitterCell];

    [self.layer addSublayer:_snowEmitterLayer];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (_snowEmitterLayer) {
        _snowEmitterLayer.emitterPosition = CGPointMake(self.center.x, -50);
    }
    else {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (UIDeviceOrientationIsLandscape(orientation)) {
            self.transform = CGAffineTransformMakeRotation(M_PI * 1.5);
            
        }
        else {
            self.transform = CGAffineTransformMakeRotation(0);
        }

        self.frame = CGRectOffset(self.frame, 0.0, [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width);
    }
}

- (void)beginSnowAnimation {
    // Clean up if we go to the background as CABasicAnimations tend to do odd things then

    // Prepare Rotation Animation
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.repeatCount       = HUGE_VALF;
    rotationAnimation.autoreverses      = NO;
    rotationAnimation.toValue = [NSNumber numberWithDouble:M_PI * 2];	// 360 degrees in radians

    // Prepare Vertical Motion Animation
    CABasicAnimation *fallAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    fallAnimation.repeatCount       = HUGE_VALF;
    fallAnimation.autoreverses      = NO;

    for (UIImageView *flake in self.flakesArray) {
        CGPoint flakeStartPoint     = flake.center;
        double flakeStartY           = flakeStartPoint.y;
        double flakeEndY             = self.frame.size.height;
        flakeStartPoint.y           = flakeEndY;
        flake.center                = flakeStartPoint;

        // Randomize the time each flake takes to animate to give texture
        double timeInterval = (self.animationDurationMax - self.animationDurationMin) * arc4random() / UINT32_MAX;
        fallAnimation.duration = timeInterval + self.animationDurationMin;
        fallAnimation.fromValue = [NSNumber numberWithDouble:-flakeStartY];
        [flake.layer addAnimation:fallAnimation forKey:@"transform.translation.y"];

        rotationAnimation.duration = timeInterval * 2; // Makes sure that we don't get super-fast spinning flakes
        [flake.layer addAnimation:rotationAnimation forKey:@"transform.rotation.y"];
    }
}

-(NSMutableArray *)flakesArray {
    if (!_flakesArray) {
        srandomdev();
        self.flakesArray = [[NSMutableArray alloc] initWithCapacity:self.flakesCount];
        // UIImage *flakeImg = [UIImage imageNamed:self.flakeFileName];
        // I'm not really fond of the practice of putting files in a system app directory, even if it is technically harmless :/
        UIImage *flakeImg = [UIImage imageWithContentsOfFile: [@"/Library/Application Support/Snoverlay/" stringByAppendingString: self.flakeFileName]];

        double flakeXPosition, flakeYPosition;

        for (int i = 0; i < self.flakesCount; i++) {
            // Randomize Flake size
            double flakeScale = ((double)arc4random() / UINT32_MAX);

            // Make sure that we don't break the current size rules
            flakeScale          = flakeScale < flakeMinimumSize ? flakeMinimumSize : flakeScale;
            double flakeWidth    = selfFlakeWidth * flakeScale;
            double flakeHeight   = selfFlakeHeight * flakeScale;

            // Allow flakes to be partially offscreen
            flakeXPosition = self.frame.size.width * arc4random() / UINT32_MAX;
            flakeXPosition -= flakeWidth;

            // enlarge content height by 1/2 view height, screen is always well populated
            flakeYPosition = self.frame.size.height * 1.5 * arc4random() / UINT32_MAX;
            // flakes start y position is above upper view bound, add view height
            flakeYPosition += self.frame.size.height;

            CGRect frame = CGRectMake(flakeXPosition, flakeYPosition, flakeWidth, flakeHeight);

            UIImageView *imageView = [[UIImageView alloc] initWithImage:flakeImg];
            imageView.frame = frame;
            imageView.userInteractionEnabled = NO;

            [self.flakesArray addObject:imageView];
            [self addSubview:imageView];
        }
    }
    return _flakesArray;
}

@end
