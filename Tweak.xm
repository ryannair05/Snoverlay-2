#import <UIKit/UIKit.h>
#define prefPath @"/User/Library/Preferences/com.ryannair05.snoverlay.plist"
#define DegreesToRadians(x) (CGFloat)((x) * M_PI / 180.0)

BOOL enabled = YES;
BOOL wallpaperOnly = NO;
BOOL changeWithOrientation;
BOOL snowFlakeType;
short numSnowflakes = 160;
UIDeviceOrientation lastInterfaceOrientation;

@interface UIView (Snow)
-(void)makeItSnow;
-(void)stopSnowing;
@end

%hook XMASFallingSnowView
-(NSInteger)flakesCount {
	return numSnowflakes;
}
%end

%hook XMASFallingSnowView
-(NSString *)flakeFileName {
	if (snowFlakeType)
		return @"XMASSnowflake1.png";
	return %orig;
}
%end

@interface SnoverlaySecureWindow : UIWindow
@end

@implementation SnoverlaySecureWindow

-(id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame])
	{

		if(enabled && !wallpaperOnly) {
			[self makeItSnow];
		}
		
		[[NSNotificationCenter defaultCenter] addObserverForName:@"com.ryannair05.snoverlay/prefsupdated" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			if(enabled && !wallpaperOnly)
				[self makeItSnow];
			else 
				[self stopSnowing];
			
		}];

		if (changeWithOrientation) {
			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			lastInterfaceOrientation = [[UIDevice currentDevice] orientation];
			[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
		}

	}

	return self;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || lastInterfaceOrientation == orientation) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object:nil];
    [self performSelector:@selector(orientationChangedMethod) withObject:nil afterDelay:0];
}

- (void)orientationChangedMethod
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	switch (orientation)
    {
        
		case UIDeviceOrientationPortrait:
        {
           self.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
		{
			self.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
			break;
		}
		case UIDeviceOrientationLandscapeLeft:
        {
           	self.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
            break;
        }
		case UIDeviceOrientationLandscapeRight:
		{
			 self.transform = CGAffineTransformMakeRotation(DegreesToRadians(270));
            break;
		}
		default:
			break;
	}
    //rotate rect
    lastInterfaceOrientation = orientation;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.ryannair05.snoverlay/prefsupdated"object:nil];
	if (changeWithOrientation) {
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	}
}

- (BOOL)_shouldCreateContextAsSecure {
	return YES;
}
@end

@interface SBFStaticWallpaperView : UIView
-(void)handlePrefs;
@end

%hook SBFStaticWallpaperView
-(void)_setupContentViewWithOptions:(NSUInteger)options {
    
	%orig;

	 [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handlePrefs) 
        name:@"com.ryannair05.snoverlay/prefsupdated"
        object:nil];

	[self handlePrefs];
}

-(void)_setupContentView {
	%orig;

	 [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handlePrefs) 
        name:@"com.ryannair05.snoverlay/prefsupdated"
        object:nil];

	[self handlePrefs];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.ryannair05.snoverlay/prefsupdated" object:nil];
}

%new
-(void)handlePrefs {
	 enabled  ? [self makeItSnow] : [self stopSnowing];
}
%end

// CarPlay

@interface SBStarkLockOutViewController : UIViewController
@end

%hook SBStarkLockOutViewController

-(void)viewDidAppear:(BOOL)arg1 {
	%orig;
	[self.view makeItSnow];
}

%end

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    %orig;
	CGRect frame = [UIScreen mainScreen].bounds;
	SnoverlaySecureWindow *window = [[SnoverlaySecureWindow alloc] initWithFrame:frame];
	window.windowLevel = 100000.0f;
	window.userInteractionEnabled = NO;
	window.hidden = NO;
}
%end

static void loadPrefs()
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
	if (prefs) {
		enabled = [prefs[@"enabled"] boolValue];
		wallpaperOnly = [prefs[@"wallpaperOnly"] boolValue];
		numSnowflakes = [prefs[@"numSnowflakes"] integerValue];
		changeWithOrientation = [prefs[@"changeWithOrientation"] boolValue];
		snowFlakeType = [prefs[@"snowFlakeType"] boolValue];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.ryannair05.snoverlay/prefsupdated" object:nil];
	}
	else {
		NSString *pathDefault = @"/Library/PreferenceBundles/snoverlayprefs.bundle/defaults.plist";
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:prefPath]) {
			NSError *error = nil;
			[fileManager copyItemAtPath:pathDefault toPath:prefPath error:&error];
			if (error != nil) {
				error = nil;
            	[[NSFileManager defaultManager] removeItemAtPath:prefPath error:&error];
        	}
			if (error == nil) {
				loadPrefs();
			}
		}
	}

}

%ctor {
	@autoreleasepool {
		loadPrefs();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,(CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.snoverlay/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		%init;
	}
}


