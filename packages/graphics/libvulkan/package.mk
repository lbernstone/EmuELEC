# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libvulkan"
PKG_VERSION="v1.2.133"
PKG_SHA256="f6403ba19e5899593a9498bede3b1f73caaaca56fe63eea9f9cf294461797b97"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/KhronosGroup/Vulkan-Loader"
PKG_URL="https://github.com/KhronosGroup/Vulkan-Loader/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="cmake:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Vulkan graphics abstraction layer"
PKG_TOOLCHAIN="cmake-make"

PKG_LIBNAME="libvulkan.so*"
PKG_LIBPATH="build/loader/$PKG_LIBNAME"
PKG_LIBVAR="VULKAN_LIB"

PKG_CMAKE_OPTS_TARGET="-DBUILD_WSI_XCB_SUPPORT=OFF \
                       -DBUILD_WSI_XLIB_SUPPORT=OFF \
                       -DBUILD_WSI_WAYLAND_SUPPORT=OFF \
                       $PKG_ARCH_ARM"

pre_configure_target() {
  if [ "$VULKAN_TESTS_SUPPORT" = yes ]; then
    cd $PKG_BUILD
    git clone https://github.com/google/googletest.git external/googletest
    cd external/googletest
    git checkout tags/release-1.8.1
  fi

  LDFLAGS="$LDFLAGS -lpthread"
  mkdir $PKG_BUILD/build
  cd $PKG_BUILD/build
  ../scripts/update_deps.py
  cmake -C helper.cmake ..
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/
  cp -P $PKG_BUILD/build/loader/libvulkan.so* $INSTALL/usr/lib/
  ls $INSTALL/usr/lib/
  if [ "$VULKAN_TESTS_SUPPORT" = yes ]; then
    cp -P $PKG_BUILD/build/external/googletest/googletest/*.so* $INSTALL/usr/lib/
    mkdir -p $INSTALL/usr/share/vulkan/layers
    cp -L $PKG_BUILD/build/tests/*.sh $INSTALL/usr/share/vulkan/
    cp -P $PKG_BUILD/build/tests/vk_loader_validation_tests $INSTALL/usr/share/vulkan/
    cp -P $PKG_BUILD/build/tests/layers/*.json $INSTALL/usr/share/vulkan/layers/
  fi
}
