THEOS_DEVICE_IP = localhost

# export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

FINALPACKAGE=1

export TARGET = iphone:13.3:10.0

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc -O3
PACKAGE_VERSION=1.1b1

include $(THEOS)/makefiles/common.mk

PACKAGE_VERSION=1.1b1

TWEAK_NAME = Snoverlay
Snoverlay_FILES = Tweak.xm ./FallingSnow/UIView+XMASFallingSnow.m ./FallingSnow/XMASFallingSnowView.m WeatherManager.xm
Snoverlay_PRIVATE_FRAMEWORKS = Weather WeatherUI
Snoverlay_LDFLAGS = $(THEOS)/sdks/iPhoneOS13.3.sdk/System/Library/PrivateFrameworks/WeatherUI.framework/WeatherUI.tbd

ARCHS = armv7 arm64 arm64e
# ARCHS = arm64
include $(THEOS_MAKE_PATH)/tweak.mk


SUBPROJECTS += snoverlayprefs snoverlaymodule

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard" #
