#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#import <ControlCenterUIKit/CCUIToggleModule.h>

#define prefPath @"/User/Library/Preferences/com.ryannair05.snoverlay.plist"

@interface snoverlaymodule : CCUIToggleModule
{
  BOOL _selected;
}

@end
