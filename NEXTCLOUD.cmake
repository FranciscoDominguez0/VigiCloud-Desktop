# SPDX-FileCopyrightText: 2017 Nextcloud GmbH and Nextcloud contributors
# SPDX-FileCopyrightText: 2012 ownCloud GmbH
# SPDX-License-Identifier: GPL-2.0-or-later
#
# VigiCloud - personalizacion de VigiTec a partir de Nextcloud Desktop v34.0.5
# Mantener la licencia y las atribuciones del proyecto original.

# Keep development and production application identities separate.
if(NEXTCLOUD_DEV)
    set( APPLICATION_NAME       "VigiCloudDev" )
    set( APPLICATION_SHORTNAME  "VigiCloudDev" )
    set( APPLICATION_EXECUTABLE "vigiclouddev" )
    set( APPLICATION_ICON_NAME  "VigiCloud" )
else()
    set( APPLICATION_NAME       "VigiCloud" )
    set( APPLICATION_SHORTNAME  "VigiCloud" )
    set( APPLICATION_EXECUTABLE "vigicloud" )
    set( APPLICATION_ICON_NAME  "${APPLICATION_SHORTNAME}" )
endif()

set( APPLICATION_CONFIG_NAME "${APPLICATION_EXECUTABLE}" )
set( APPLICATION_DOMAIN     "vigitecpanama.com" )
set( APPLICATION_VENDOR     "VigiTec" )
# No use the official Nextcloud updater for an OEM-branded executable.
set( APPLICATION_UPDATE_URL "" CACHE STRING "URL for updater" )
set( APPLICATION_HELP_URL   "" CACHE STRING "URL for the help menu" )

# Default macOS builds (Nextcloud + NextcloudDev) use the Icon Composer (.icon)
# format for the app icon. That format can only be compiled by a recent enough
# toolchain (Xcode 26 ships the actool that understands .icon, and macOS 26
# provides the matching SDK), so we gate the modern pipeline on the build
# environment. Older environments — and branded customer builds, which use a
# different APPLICATION_NAME and ship their own colourful icon SVG — fall back
# to the historical Inkscape + ECM (ecm_add_app_icon) .icns pipeline instead.
#
# The Xcode/actool version is the real capability gate; the macOS check is a
# coarse secondary guard. Detection runs every configure and is intentionally
# NOT cached, so the decision self-heals once the build host is upgraded without
# requiring a clean reconfigure. Pass -DMACOS_USE_ICON_COMPOSER=ON/OFF to
# override auto-detection entirely.
if(APPLE)
    execute_process(COMMAND sw_vers -productVersion
        OUTPUT_VARIABLE _macos_product_version RESULT_VARIABLE _macos_ver_result
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    execute_process(COMMAND xcodebuild -version
        OUTPUT_VARIABLE _xcodebuild_version_raw RESULT_VARIABLE _xcode_ver_result
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)

    set(MACOS_ICON_COMPOSER_TOOLCHAIN_SUPPORTED OFF)
    if(_macos_ver_result EQUAL 0 AND _xcode_ver_result EQUAL 0)
        string(REGEX MATCH "Xcode ([0-9]+\\.[0-9]+)" _ "${_xcodebuild_version_raw}")
        set(_xcode_version "${CMAKE_MATCH_1}")
        message(STATUS "Detected build environment: macOS ${_macos_product_version}, Xcode ${_xcode_version}")
        if(_macos_product_version VERSION_GREATER_EQUAL "26.5"
           AND _xcode_version VERSION_GREATER_EQUAL "26.5")
            set(MACOS_ICON_COMPOSER_TOOLCHAIN_SUPPORTED ON)
        endif()
    endif()

    if(NOT DEFINED MACOS_USE_ICON_COMPOSER)
        if((APPLICATION_NAME STREQUAL "Nextcloud" OR NEXTCLOUD_DEV)
           AND EXISTS "${CMAKE_SOURCE_DIR}/theme/colored/AppIcon.icon/icon.json"
           AND MACOS_ICON_COMPOSER_TOOLCHAIN_SUPPORTED)
            set(MACOS_USE_ICON_COMPOSER ON)
            message(STATUS "Using Icon Composer (.icon) format for the macOS app icon.")
        else()
            set(MACOS_USE_ICON_COMPOSER OFF)
        endif()
    endif()

    if(NOT MACOS_USE_ICON_COMPOSER)
        message(STATUS "macOS app icon: using legacy ECM .icns pipeline.")
        # Restore the macOS-specific (squircle) icon for the default builds so the
        # legacy pipeline emits Nextcloud-macOS.icns rather than the generic logo.
        # Branded builds keep their own ${APPLICATION_ICON_NAME}-icon.svg.
        if((APPLICATION_NAME STREQUAL "Nextcloud" OR NEXTCLOUD_DEV)
           AND EXISTS "${CMAKE_SOURCE_DIR}/theme/colored/Nextcloud-macOS-icon.svg")
            set(APPLICATION_ICON_NAME "Nextcloud-macOS")
            message(STATUS "Using macOS-specific application icon: ${APPLICATION_ICON_NAME}")
        endif()
    endif()
endif()

set( APPLICATION_ICON_SET   "SVG" )
set( APPLICATION_SERVER_URL "https://icloud.vigitecpanama.com" CACHE STRING "URL for the server to use. If entered, the UI field will be pre-filled with it" )
set( APPLICATION_SERVER_URL_ENFORCE ON ) # Restrict login to configured server
set( APPLICATION_REV_DOMAIN "com.vigitec.vigicloud" )
set( APPLICATION_REV_DOMAIN_DBUS "desktopclient.vigitecpanama.com" )
set( DEVELOPMENT_TEAM "NKUJUXUJ3B" CACHE STRING "Apple Development Team ID" )
# Keep the underlying virtual-file suffix for compatibility with Nextcloud.
set( APPLICATION_VIRTUALFILE_SUFFIX "nextcloud" CACHE STRING "Virtual file suffix (not including the .)" )
set( APPLICATION_OCSP_STAPLING_ENABLED OFF )
set( APPLICATION_FORBID_BAD_SSL OFF )

set( LINUX_PACKAGE_SHORTNAME "nextcloud" )
set( LINUX_APPLICATION_ID "${APPLICATION_REV_DOMAIN}.${LINUX_PACKAGE_SHORTNAME}")

set( THEME_CLASS            "NextcloudTheme" )
set( WIN_SETUP_BITMAP_PATH  "${CMAKE_SOURCE_DIR}/admin/win/nsi" )

set( MAC_INSTALLER_BACKGROUND_FILE "${CMAKE_SOURCE_DIR}/admin/osx/installer-background.png" CACHE STRING "The MacOSX installer background image" )

# set( THEME_INCLUDE          "${OEM_THEME_DIR}/mytheme.h" )
# set( APPLICATION_LICENSE    "${OEM_THEME_DIR}/license.txt" )

## Updater options
# Do not allow the stock updater to overwrite branded builds.
option( BUILD_UPDATER "Build updater" OFF )

option( WITH_PROVIDERS "Build with providers list" OFF )

option( ENFORCE_VIRTUAL_FILES_SYNC_FOLDER "Enforce use of virtual files sync folder when available" OFF )
option( DISABLE_VIRTUAL_FILES_SYNC_FOLDER "Disable use of virtual files sync folder when available" OFF )

option(ENFORCE_SINGLE_ACCOUNT "Enforce use of a single account in desktop client" OFF)

option( DO_NOT_USE_PROXY "Do not use system wide proxy, instead always do a direct connection to server" OFF )

option( WIN_DISABLE_USERNAME_PREFILL "Do not prefill the Windows user name when creating a new account" OFF )

## Theming options: VigiTec red and black
set(NEXTCLOUD_BACKGROUND_COLOR "#C8102E" CACHE STRING "Default application background color")
set( APPLICATION_WIZARD_HEADER_BACKGROUND_COLOR "#111111" CACHE STRING "Hex color of the wizard header background")
set( APPLICATION_WIZARD_HEADER_TITLE_COLOR "#FFFFFF" CACHE STRING "Hex color of the text in the wizard header")
option( APPLICATION_WIZARD_USE_CUSTOM_LOGO "Use the logo from ':/client/theme/colored/wizard_logo.(png|svg)' else the default application icon is used" ON )

# Windows Shell Extensions & MSI: unique GUIDs for this branded application.
if(WIN32)
    set( WIN_SHELLEXT_CONTEXT_MENU_GUID      "{39A2D2E0-C80A-422C-A3E8-B76071E02530}" )

    set( WIN_SHELLEXT_OVERLAY_GUID_ERROR     "{846DAF5F-CE87-4907-A53C-D706590A5476}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK        "{B8B5CAED-E5BE-4C1F-8D8D-B4B84222296A}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK_SHARED "{280750AD-C107-4D9A-8A8C-53B6B9C93D2A}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_SYNC      "{E4290087-109F-4362-9678-77E1B8CF2F60}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_WARNING   "{7ABD68FD-451A-4ECB-AF92-6F6E052D8048}" )

    set( WIN_MSI_UPGRADE_CODE                "2291AEF4-43B7-44BA-B47D-DB9184424DA0" )

    option( BUILD_WIN_MSI "Build MSI scripts and helper DLL" OFF )
    option( BUILD_WIN_TOOLS "Build Win32 migration tools" OFF )
endif()

if (APPLE AND CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 11.0)
    option( BUILD_FILE_PROVIDER_MODULE "Build the macOS virtual files File Provider module" OFF )
endif()
