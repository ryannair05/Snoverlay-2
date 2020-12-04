ARCHS = armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = snoverlayprefs
snoverlayprefs_FILES = SNOWRootListController.m
snoverlayprefs_INSTALL_PATH = /Library/PreferenceBundles
snoverlayprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/snoverlayprefs.plist$(ECHO_END)
