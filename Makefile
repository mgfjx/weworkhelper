THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

ARCHS = armv7 arm64
TARGET = iphone:latest:8.0

FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeWorkHelper
WeWorkHelper_FILES = $(wildcard *.xm) $(wildcard *.m)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 wework"
