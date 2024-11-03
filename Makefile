ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

TARGET = iphone:clang:latest:latest
CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iOSImGui

$(TWEAK_NAME)_FRAMEWORKS =  UIKit Foundation Security QuartzCore CoreGraphics CoreText  AVFoundation Accelerate GLKit SystemConfiguration GameController
$(TWEAK_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -w
$(TWEAK_NAME)_FILES = Menu.mm Mods.mm $(wildcard ImGui/*.mm) $(wildcard ImGui/*.cpp) $(wildcard Includes/*.mm)  $(wildcard Includes/*.m) $(wildcard Includes/*.cpp) $(wildcard Includes/Esp/*.m) $(wildcard Includes/Hooking/*.mm) $(wildcard Includes/SCLAlertView/*.m)

$(TWEAK_NAME)_LIBRARIES += substrate
$(TWEAK_NAME)_LDFLAGS += -L./Includes/Libs
$(TWEAK_NAME)_LDFLAGS += -lz -stdlib=libc++ -ldobby_fixed

#LQMNemOS_LIBRARIES += substrate
# GO_EASY_ON_ME = 1

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/aggregate.mk
after-install::
   install.exec "killall -9 Springboard || :"
