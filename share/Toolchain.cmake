set(DEPENDS_PATH "/home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug")
set(NATIVEPREFIX "/home/garrett/Documents/steamlink-sdk/kodi-deps/x86_64-linux-gnu-native")

set(OS "linux")
set(CPU "armv7a")
set(PLATFORM "steamlink")

# set CORE_SYSTEM_NAME and CMAKE_SYSTEM_NAME (sets CMAKE_CROSSCOMPILING)
if(OS STREQUAL linux)
  set(CMAKE_SYSTEM_NAME Linux)
  set(CORE_SYSTEM_NAME linux)
  if(PLATFORM STREQUAL raspberry-pi)
    set(CORE_PLATFORM_NAME rbpi)
    # wrapping libdvd fails with gold on rbpi
    # todo: revisit after toolchain bump
    set(ENABLE_LDGOLD OFF CACHE BOOL "Disabling Gnu Gold Linker" FORCE)
  elseif(NOT "steamlink" STREQUAL "")
    set(CORE_PLATFORM_NAME steamlink)
  endif()
  if(NOT "" STREQUAL "")
    set(WAYLAND_RENDER_SYSTEM  CACHE STRING "Render system to use with Wayland: \"gl\" or \"gles\"")
  else()
    set(WAYLAND_RENDER_SYSTEM gl CACHE STRING "Render system to use with Wayland: \"gl\" or \"gles\"")
  endif()
elseif(OS STREQUAL android)
  set(CMAKE_SYSTEM_NAME Android)
  set(CORE_SYSTEM_NAME android)
elseif(OS STREQUAL osx)
  set(CMAKE_SYSTEM_NAME Darwin)
  set(CORE_SYSTEM_NAME osx)
elseif(OS STREQUAL ios)
  set(CMAKE_SYSTEM_NAME Darwin)
  set(CORE_SYSTEM_NAME ios)
endif()

if(CORE_SYSTEM_NAME STREQUAL ios)
  # Necessary to build the main Application (but not other dependencies)
  # with Xcode (and a bundle with Makefiles) (https://cmake.org/Bug/view.php?id=15329)
  if(NOT PROJECT_SOURCE_DIR MATCHES "tools/depends")
    message(STATUS "Toolchain enabled IOS bundle for project ${PROJECT_NAME}")
    set(CMAKE_MACOSX_BUNDLE YES)
    set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")

    # set this to YES once we have a deployment target of at least iOS 6.0
    set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
  endif()
endif()

if(CORE_SYSTEM_NAME STREQUAL ios OR CORE_SYSTEM_NAME STREQUAL osx)
  set(CMAKE_OSX_SYSROOT )
endif()
set(CMAKE_SYSTEM_VERSION 1)

# specify the cross compiler
set(CMAKE_C_COMPILER /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-gcc)
set(CMAKE_CXX_COMPILER /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-g++)
set(CMAKE_AR /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-ar CACHE FILEPATH "Archiver")
set(CMAKE_LINKER /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-ld CACHE FILEPATH "Linker")
set(CMAKE_STRIP /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-strip CACHE PATH "strip binary" FORCE)
set(CMAKE_OBJDUMP /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-objdump CACHE FILEPATH "Objdump")
set(CMAKE_RANLIB /home/garrett/Documents/steamlink-sdk/toolchain/bin/armv7a-cros-linux-gnueabi-ranlib CACHE FILEPATH "Ranlib")

if(PROJECT_SOURCE_DIR MATCHES "tools/depends")
  if(yes STREQUAL "yes")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "/usr/bin/ccache")
  endif()
endif()

# where is the target environment
set(CMAKE_FIND_ROOT_PATH /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug)
set(CMAKE_LIBRARY_PATH /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/lib)
if(NOT "/home/garrett/Documents/steamlink-sdk/toolchain" STREQUAL "")
  list(APPEND CMAKE_FIND_ROOT_PATH /home/garrett/Documents/steamlink-sdk/toolchain /home/garrett/Documents/steamlink-sdk/toolchain/armv7a-cros-linux-gnueabi /home/garrett/Documents/steamlink-sdk/toolchain/armv7a-cros-linux-gnueabi/sysroot /home/garrett/Documents/steamlink-sdk/toolchain/armv7a-cros-linux-gnueabi/sysroot/usr /home/garrett/Documents/steamlink-sdk/toolchain/armv7a-cros-linux-gnueabi/libc /home/garrett/Documents/steamlink-sdk/toolchain/lib/armv7a-cros-linux-gnueabi/sysroot /home/garrett/Documents/steamlink-sdk/toolchain/usr /home/garrett/Documents/steamlink-sdk/toolchain/sysroot/usr)
  set(CMAKE_LIBRARY_PATH "${CMAKE_LIBRARY_PATH}:/home/garrett/Documents/steamlink-sdk/toolchain/usr/lib/armv7a-cros-linux-gnueabi:/home/garrett/Documents/steamlink-sdk/toolchain/lib/armv7a-cros-linux-gnueabi")
endif()
if(NOT "" STREQUAL "")
  list(APPEND CMAKE_FIND_ROOT_PATH  /usr)
endif()

# add RBPI's firmware directories
if(CORE_PLATFORM_NAME STREQUAL rbpi)
  list(APPEND CMAKE_FIND_ROOT_PATH /opt/vc)
  list(APPEND CMAKE_LIBRARY_PATH /opt/vc/lib)
  list(APPEND CMAKE_INCLUDE_PATH /opt/vc/include)
endif()

# add Android directories and tools
if(CORE_SYSTEM_NAME STREQUAL android)
  set(NDKROOT )
  set(SDKROOT )
  set(TOOLCHAIN /home/garrett/Documents/steamlink-sdk/toolchain)
  set(HOST armv7a-cros-linux-gnueabi)
  string(REPLACE ":" ";" SDK_BUILDTOOLS_PATH "")
endif()

# add Steam Link's sdk directory
if(CORE_PLATFORM_NAME STREQUAL steamlink)
  list(APPEND CMAKE_FIND_ROOT_PATH /home/garrett/Documents/steamlink-sdk/toolchain/../rootfs)
  list(APPEND CMAKE_LIBRARY_PATH /home/garrett/Documents/steamlink-sdk/toolchain/../rootfs/lib)
  list(APPEND CMAKE_INCLUDE_PATH /home/garrett/Documents/steamlink-sdk/toolchain/../rootfs/include)
endif()

set(CMAKE_C_FLAGS "--sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB -O0 -g -D_DEBUG   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_CXX_FLAGS "-std=c++11 --sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB -O0 -g -D_DEBUG   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_C_FLAGS_RELEASE "--sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB  -O0   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_CXX_FLAGS_RELEASE "-std=c++11 --sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB  -O0   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_C_FLAGS_DEBUG "--sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB -O0 -g -D_DEBUG   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_CXX_FLAGS_DEBUG "-std=c++11 --sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB -O0 -g -D_DEBUG   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_CPP_FLAGS "--sysroot=/home/garrett/Documents/steamlink-sdk/toolchain/../rootfs -marm -mfpu=neon -mfloat-abi=hard -DEGL_API_FB -O0 -g -D_DEBUG   -isystem /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/include")
set(CMAKE_EXE_LINKER_FLAGS "-L/home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/lib -static-libgcc -static-libstdc++ -lstdc++  ")
set(ENV{CFLAGS} ${CMAKE_C_FLAGS})
set(ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS})
set(ENV{CPPFLAGS} ${CMAKE_CPP_FLAGS})
set(ENV{LDFLAGS} ${CMAKE_EXE_LINKER_FLAGS})
# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_FRAMEWORK LAST)
set(ENV{PKG_CONFIG_LIBDIR} /home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/lib/pkgconfig:/home/garrett/Documents/steamlink-sdk/kodi-deps/armv7a-cros-linux-gnueabi-debug/share/pkgconfig)

# Binary Addons
if(NOT CORE_SYSTEM_NAME STREQUAL linux)
  set(ADDONS_PREFER_STATIC_LIBS ON)
endif()

set(KODI_DEPENDSBUILD 1)

