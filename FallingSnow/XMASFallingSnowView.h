#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIScreen.h>

@interface XMASFallingSnowView : UIView {
     CAEmitterLayer *_snowEmitterLayer;
}

@property (nonatomic, retain) NSMutableArray *flakesArray;
@property (nonatomic, retain) NSString *flakeFileName;
@property (nonatomic, assign) NSInteger flakesCount;
@property (nonatomic, assign) float animationDurationMin;
@property (nonatomic, assign) float animationDurationMax;

- (void)beginSnowAnimation;
- (void)beginSnowEmmitter;

@end

