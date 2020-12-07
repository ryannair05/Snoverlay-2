ARCHS = armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = snoverlaymodule
snoverlaymodule_BUNDLE_EXTENSION = bundle
snoverlaymodule_FILES = snoverlaymodule.m
snoverlaymodule_CFLAGS = -fobjc-arc
snoverlaymodule_PRIVATE_FRAMEWORKS = ControlCenterUIKit
snoverlaymodule_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
