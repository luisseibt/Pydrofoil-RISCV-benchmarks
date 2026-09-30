HELLO_WORLD_VERSION = 1.0
HELLO_WORLD_SITE = $(BR2_EXTERNAL_RISCV_APPS_PATH)/hello_world
HELLO_WORLD_SITE_METHOD = local

define HELLO_WORLD_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(HELLO_WORLD_PKGDIR)/S99hello_world \
        $(TARGET_DIR)/etc/init.d/S99hello_world
endef

$(eval $(cmake-package))