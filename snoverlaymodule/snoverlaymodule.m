#import "snoverlaymodule.h"
BOOL enabled = false;

@implementation snoverlaymodule

//Return the icon of your module here
- (UIImage *)iconGlyph
{
	return [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

//Return the color selection color of your module here
- (UIColor *)selectedColor
{
	return [UIColor blueColor];
}

- (BOOL)isSelected
{
  return _selected;
}

- (void)setSelected:(BOOL)selected
{
	_selected = selected;

  [super refreshState];
  
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

  [prefs setObject: [NSNumber numberWithBool:_selected] forKey:@"enabled"];
  [prefs writeToFile:prefPath atomically:YES];
  CFStringRef notificationName = (__bridge CFStringRef)@"com.ryannair05.snoverlay/prefsupdated";
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
  //[[NSNotificationCenter defaultCenter] postNotificationName:@"com.ryannair05.snoverlay/prefsupdated" object:nil];
}

@end

