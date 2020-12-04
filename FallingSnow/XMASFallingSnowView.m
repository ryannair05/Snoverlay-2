#import "XMASFallingSnowView.h"
#import <math.h>
@implementation XMASFallingSnowView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

        // Set default values
        self.flakesCount          = 160;
        self.flakeWidth           = 20;
        self.flakeHeight          = 23;
        self.flakeFileName        = @"XMASSnowflake.png";
        self.flakeMinimumSize     = 0.4;
        self.animationDurationMin = 5;
        self.animationDurationMax = 11;
    }

    return self;
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
        UIImage *flakeImg = [UIImage imageWithContentsOfFile: [NSString stringWithFormat: @"/Library/Application Support/Snoverlay/%@", self.flakeFileName]];

        double flakeXPosition, flakeYPosition;

        for (int i = 0; i < self.flakesCount; i++) {
            // Randomize Flake size
            double flakeScale = ((double)arc4random() / UINT32_MAX);

            // Make sure that we don't break the current size rules
            flakeScale          = flakeScale < self.flakeMinimumSize ? self.flakeMinimumSize : flakeScale;
            double flakeWidth    = self.flakeWidth * flakeScale;
            double flakeHeight   = self.flakeHeight * flakeScale;

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
