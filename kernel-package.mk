RELEASE_NUMBER ?= 1
KERNEL_DEFCONFIG ?= rockchip_linux_defconfig

KERNEL_VERSION ?= $(shell $(KERNEL_MAKE) -s kernelversion)
KERNEL_RELEASE ?= $(shell $(KERNEL_MAKE) -s kernelrelease)
KDEB_PKGVERSION ?= $(KERNEL_VERSION)-$(RELEASE_NUMBER)-rockchip

KERNEL_MAKE ?= make \
	ARCH=arm64 \
	CROSS_COMPILE="/usr/local/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"

.config: arch/arm64/configs/$(KERNEL_DEFCONFIG)
	$(KERNEL_MAKE) $(KERNEL_DEFCONFIG)

.PHONY: .scmversion
.scmversion:
ifneq (,$(RELEASE_NUMBER))
	@echo "-$(RELEASE_NUMBER)-rockchip-g$$(git rev-parse --short HEAD)" > .scmversion
else
	@echo "-rockchip-dev" > .scmversion
endif

version:
	@echo "$(KDEB_PKGVERSION)"

.PHONY: info
info: .config .scmversion
	@echo $(shell cat .scmversion)

.PHONY: kernel-package
kernel-package: .config .scmversion
	KDEB_PKGVERSION=$(KDEB_PKGVERSION) $(KERNEL_MAKE) bindeb-pkg -j$$(nproc)
