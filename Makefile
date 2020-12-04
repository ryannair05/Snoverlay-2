THEOS_DEVICE_IP = 192.168.1.237

export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

FINALPACKAGE=1

export TARGET = iphone:13.5:7.0

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc -O3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Snoverlay
Snoverlay_FILES = Tweak.xm ./FallingSnow/UIView+XMASFallingSnow.m ./FallingSnow/XMASFallingSnowView.m

ARCHS = armv7 arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += snoverlayprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
