#import "FallingSnow/XMASFallingSnowView.h"
#import <UIKit/UIWindow.h>
#import <UIKit/UIViewController.h>
#import <UIKit/NSLayoutAnchor.h>
#import <version.h>

@interface SnoverlaySecureWindow : UIWindow
@property (nonatomic, retain) XMASFallingSnowView* snowView;
@end

@implementation SnoverlaySecureWindow

-(id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame])
	{

		Boolean found;

		if (CFPreferencesGetAppBooleanValue(CFSTR("wallpaperOnly"), CFSTR("com.ryannair05.snoverlay"), &found) == false && found) {
			self.snowView = [[XMASFallingSnowView alloc] initWithFrame:self.frame];
			[self addSubview:self.snowView];
		}

		[[NSNotificationCenter defaultCenter] addObserverForName:@"com.ryannair05.snoverlay/prefsupdated" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			Boolean found;

			[self.snowView removeFromSuperview];
			self.snowView = nil;

			if (CFPreferencesGetAppBooleanValue(CFSTR("wallpaperOnly"), CFSTR("com.ryannair05.snoverlay"), &found) == false && found) {
				self.snowView = [[XMASFallingSnowView alloc] initWithFrame:self.frame];
				[self addSubview:self.snowView];
			}
		}];
	}

	return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.ryannair05.snoverlay/prefsupdated"object:nil];
}

- (BOOL)_shouldCreateContextAsSecure {
	return YES;
}
@end

@interface SBFStaticWallpaperView : UIView
@property (nonatomic, retain) XMASFallingSnowView* snowView;
@end

static void SBFStaticWallpaperView_handlePrefs(__unsafe_unretained SBFStaticWallpaperView* const self) {
	self.snowView = [[XMASFallingSnowView alloc] initWithFrame:self.frame];
	[self addSubview:self.snowView];
	
	self.snowView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.snowView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.snowView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.snowView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.snowView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
}

%hook SBFStaticWallpaperView
%property (nonatomic, retain) XMASFallingSnowView* snowView;
-(void)_setupContentViewWithOptions:(NSUInteger)options {
    
	%orig;

	SBFStaticWallpaperView_handlePrefs(self);
}

-(void)_setupContentView {
	%orig;

	SBFStaticWallpaperView_handlePrefs(self);
}

%end

%hook CarplayLockOutViewController
%property (nonatomic, retain) XMASFallingSnowView* snowView;
-(void)viewDidAppear:(BOOL)arg1 {
	%orig;

	[self setSnowView:[[XMASFallingSnowView alloc] initWithFrame:[self view].frame]];
	[[self view] addSubview:[self snowView]];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.ryannair05.snoverlay/prefsupdated" object:nil];
}

%ctor {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,(CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.snoverlay/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		%init(_ungrouped, CarplayLockOutViewController = objc_getClass(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0 ?  "CARLockOutViewController" : "SBStarkLockOutViewController"))
	}
}


