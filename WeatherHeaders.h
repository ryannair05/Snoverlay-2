#import <Foundation/Foundation.h>
#import <Weather/City.h>
#import <Weather/TWCCityUpdater.h>
#import <Weather/WeatherPreferences.h>
#import <UIKit/UIKit.h>

@interface WUIWeatherCondition : NSObject <CALayerDelegate>
@property (assign,nonatomic) City *city;
@property (nonatomic,readonly) CALayer *layer;
-(void)setCity:(id)arg1 animationDuration:(double)arg2 ;
-(void)setAlpha:(double)arg1 animationDuration:(double)arg2;
-(void)resume;
-(void)pause;
@end


@interface WACurrentForecast
@property (assign,nonatomic) long long conditionCode;
@property (nonatomic, retain) WFTemperature *temperature;
@end

@interface WAForecastModel : NSObject
@property (nonatomic,retain) City * city;
@property (nonatomic,retain) WACurrentForecast *currentConditions;
-(WFTemperature *)temperature;
@end

@interface WATodayModel
+(id)autoupdatingLocationModelWithPreferences:(id)arg1 effectiveBundleIdentifier:(id)arg2 ;
-(BOOL)executeModelUpdateWithCompletion:(/*^block*/id)arg1 ;
@property (nonatomic,retain) WAForecastModel * forecastModel;
-(id)location;
@end


@interface WATodayAutoupdatingLocationModel : WATodayModel
-(void)setIsLocationTrackingEnabled:(BOOL)arg1;
-(void)setLocationServicesActive:(BOOL)arg1;
@end
  
@interface WFTemperature : NSObject 
@property (assign,nonatomic) CGFloat celsius; 
@property (assign,nonatomic) CGFloat fahrenheit; 
@property (assign,nonatomic) CGFloat kelvin; 
-(CGFloat)temperatureForUnit:(int)arg1 ;
@end


@interface WALockscreenWidgetViewController : UIViewController
@property (nonatomic, strong) WATodayModel *todayModel;
+ (WALockscreenWidgetViewController *)sharedInstanceIfExists;
- (id)_temperature;
- (id)_locationName;
- (void)updateWeather;
- (void)_updateTodayView;
- (void)_updateWithReason:(id)reason;
- (void)_setupWeatherModel;
- (void)todayModelWantsUpdate:(WATodayModel *)todayModel;
@end