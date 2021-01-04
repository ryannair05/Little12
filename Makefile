FINALPACKAGE = 1

export TARGET = iphone:clang:13.5:14.0
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Little12SpringBoard Little12UIKit
Little12SpringBoard_FILES = TweakSpring.xm
Little12UIKit_FILES = TweakUI.xm

ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += little12prefs
include $(THEOS_MAKE_PATH)/aggregate.mk