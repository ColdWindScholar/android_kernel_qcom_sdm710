# Android makefile for audio kernel modules

# Assume no targets will be supported

# Check if this driver needs be built for current target
ifeq ($(call is-board-platform-in-list,msmnile sdmshrike),true)
TARGET := msmnile
ifeq ($(TARGET_BOARD_AUTO),true)
AUDIO_SELECT  := CONFIG_SND_SOC_SA8155=m
else
AUDIO_SELECT  := CONFIG_SND_SOC_SM8150=m
endif
endif

ifeq ($(call is-board-platform,$(MSMSTEPPE)),true)
TARGET := talos
ifeq ($(TARGET_BOARD_AUTO),true)
AUDIO_SELECT  := CONFIG_SND_SOC_SA6155=m
else
AUDIO_SELECT  := CONFIG_SND_SOC_SM6150=m
endif
endif

ifeq ($(call is-board-platform,$(TRINKET)),true)
TARGET := trinket
AUDIO_SELECT  := CONFIG_SND_SOC_SM6150=m
endif

ifeq ($(call is-board-platform,kona),true)
TARGET := kona
AUDIO_SELECT  := CONFIG_SND_SOC_KONA=m
endif

ifeq ($(call is-board-platform,lito),true)
TARGET := lito
AUDIO_SELECT  := CONFIG_SND_SOC_LITO=m
endif

ifeq ($(call is-board-platform,bengal),true)
TARGET := bengal
AUDIO_SELECT  := CONFIG_SND_SOC_BENGAL=m
endif

ifeq ($(call is-board-platform,sdm660),true)
TARGET := sdm660
AUDIO_SELECT  := CONFIG_SND_SOC_SDM660=m
endif

ifeq ($(call is-board-platform-in-list,msm8953 msm8937),true)
TARGET := sdm450
AUDIO_SELECT  += CONFIG_SND_SOC_SDM450=m
AUDIO_SELECT  += CONFIG_SND_SOC_EXT_CODEC_SDM450=m
endif

ifeq ($(call is-board-platform,sdm710),true)
TARGET := sdm710
AUDIO_SELECT  := CONFIG_SND_SOC_SDM670=m
endif

AUDIO_CHIPSET := audio
# Build/Package only in case of supported target
ifeq ($(call is-board-platform-in-list,msmnile $(MSMSTEPPE) $(TRINKET) kona lito bengal sdmshrike sdm660 msm8953 msm8937 sdm710),true)

LOCAL_PATH := $(call my-dir)

# This makefile is only for DLKM
ifneq ($(findstring vendor,$(LOCAL_PATH)),)

ifneq ($(findstring opensource,$(LOCAL_PATH)),)
	AUDIO_BLD_DIR := $(shell pwd)/vendor/qcom/opensource/audio-kernel
endif # opensource

DLKM_DIR := $(TOP)/device/qcom/common/dlkm

# Build audio.ko as $(AUDIO_CHIPSET)_audio.ko
###########################################################
# This is set once per LOCAL_PATH, not per (kernel) module
KBUILD_OPTIONS := AUDIO_ROOT=$(AUDIO_BLD_DIR)

# We are actually building audio.ko here, as per the
# requirement we are specifying <chipset>_audio.ko as LOCAL_MODULE.
# This means we need to rename the module to <chipset>_audio.ko
# after audio.ko is built.
KBUILD_OPTIONS += MODNAME=platform_dlkm
KBUILD_OPTIONS += BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)
KBUILD_OPTIONS += $(AUDIO_SELECT)

###########################################################
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_platform.ko
LOCAL_MODULE_KBUILD_NAME  := platform_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
###########################################################
ifeq ($(call is-board-platform-in-list, sdm660 msm8953 msm8937 sdm710),true)
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_cpe_lsm.ko
LOCAL_MODULE_KBUILD_NAME  := cpe_lsm_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
endif
###########################################################
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_machine_$(TARGET).ko
LOCAL_MODULE_KBUILD_NAME  := machine_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
###########################################################
ifeq ($(call is-board-platform-in-list,msm8953 msm8937),true)
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_machine_ext_$(TARGET).ko
LOCAL_MODULE_KBUILD_NAME  := machine_ext_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
endif
###########################################################

endif # DLKM check
endif # supported target check
