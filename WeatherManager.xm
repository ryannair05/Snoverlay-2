#import "WeatherManager.h"

@implementation WeatherManager



+ (instancetype)sharedManager {
    static dispatch_once_t onceToken = 0;
    __strong static WeatherManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {

        double interval = (double)600;
        _autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateModel) userInfo:nil repeats:YES];
        
    }
    return self;
}


- (void)updateModel {
     if (!self.widgetVC) {
        self.widgetVC = [[%c(WALockscreenWidgetViewController) alloc] init];

        if ([self.widgetVC respondsToSelector:@selector(_setupWeatherModel)]) {
            [self.widgetVC _setupWeatherModel];
            
        }
    }

    if (self.widgetVC) {
        if ([self.widgetVC respondsToSelector:@selector(todayModelWantsUpdate:)] && self.widgetVC.todayModel) {
            [self.widgetVC todayModelWantsUpdate:self.widgetVC.todayModel];
        }
        if ([self.widgetVC respondsToSelector:@selector(updateWeather)]) {
            [self.widgetVC updateWeather];
        }
        if ([self.widgetVC respondsToSelector:@selector(_updateTodayView)]) {
		    [self.widgetVC _updateTodayView];
        }
        if ([self.widgetVC respondsToSelector:@selector(_updateWithReason:)]) {
            [self.widgetVC _updateWithReason:nil];
        }
    }


   if (self.widgetVC.todayModel.forecastModel.city) {
        self.myCity = self.widgetVC.todayModel.forecastModel.city;
    }
}


- (void)updateCityForCity:(City *)city {
    city = self.myCity;
}




- (int)currentConditionCode {
    if (self.widgetVC != nil && self.widgetVC.todayModel.forecastModel.currentConditions != nil) {
        int conditionCode = (int)self.widgetVC.todayModel.forecastModel.currentConditions.conditionCode;
	    return conditionCode;
    }
    return 0;
}
@end