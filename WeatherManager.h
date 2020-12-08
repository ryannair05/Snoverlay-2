#import "WeatherHeaders.h"
@interface WeatherManager : NSObject

@property (nonatomic, strong) WALockscreenWidgetViewController *widgetVC;
@property (nonatomic, strong) City *myCity; 
@property (nonatomic, strong) NSTimer *autoUpdateTimer;

+ (instancetype)sharedManager;

- (void)updateModel;
- (void)updateCityForCity:(City *)city;
- (int)currentConditionCode;

@end