#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# ---------------------------------------------------------------------------
# Passwall 第三方源：passwall_packages（内核/辅助程序）+ passwall_luci（面板），
# 两个都要挂，缺一个 luci-app-passwall 就装不上。
# 体积控制：.config 里只保留 SS/SSR-libev 客户端 + Simple-Obfs + Trojan-Plus，
#           Xray / Sing-Box / Hysteria / NaiveProxy / Geodata 等大内核显式关闭。
# ---------------------------------------------------------------------------

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add Passwall feed source
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >>feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >>feeds.conf.default
cat > target/linux/ramips/dts/mt7620a_hiwifi_hc5761.dts << EOF
#include "mt7620a.dtsi"

/ {
	compatible = "hiwifi,hc5761", "mediatek,mt7620a";
	model = "HiWiFi HC5761";

	aliases {
		led-boot = &led_system;
		led-failsafe = &led_system;
		led-running = &led_system;
		led-upgrade = &led_system;
	};

	leds {
		compatible = "gpio-leds";

		led_system: system {
			label = "hc5761:blue:system";
			gpios = <&gpio0 9 GPIO_ACTIVE_LOW>;
		};
	};
};

&spi0 {
	status = "okay";

	flash@0 {
		compatible = "jedec,spi-nor";
		reg = <0>;
		spi-max-frequency = <10000000>;

		partitions {
			compatible = "fixed-partitions";
			#address-cells = <1>;
			#size-cells = <1>;

			partition@0 {
				label = "u-boot";
				reg = <0x000000 0x030000>;
				read-only;
			};

			partition@30000 {
				label = "factory";
				reg = <0x030000 0x010000>;
				read-only;
			};

			partition@40000 {
				label = "firmware";
				reg = <0x040000 0x1fc0000>;
			};
		};
	};
};

&ethernet {
	pinctrl-names = "default";
	pinctrl-0 = <&ephy_pins>;
	mtd-mac-address = <&factory 0x4>;
	mediatek,portmap = "llllw";
};

&wmac {
	ralink,mtd-eeprom = <&factory 0x0>;
};

&pcie {
	status = "okay";
};

&pcie0 {
	wifi@0,0 {
		compatible = "mediatek,mt76";
		reg = <0x0000 0 0 0 0>;
		mediatek,mtd-eeprom = <&factory 0x8000>;
		ieee80211-freq-limit = <5000000 6000000>;
	};
};
EOF
