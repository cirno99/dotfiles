#!/bin/sh

# 切换屏幕开关：config.toml 里绑定在 mod4-shift-p。
# jay 没有 wlr-randr 的 --off/--on，改用 jay randr 直接 disable/enable 输出。
# 只要还有屏幕亮着就全部关掉；全部关着时才全部打开，避免误关剩下的那一块。

outputs="HDMI-A-1 eDP-1"

# 取当前处于启用状态的屏幕名（未连接的 DP-1/DP-2 在 jay 里也报告 enabled，
# 所以只从上面这个固定列表里查）。
enabled=$(
    jay --json randr show |
        jq -r --arg names "$outputs" '
            ($names | split(" ")) as $wanted
            | .drm_devices[].connectors[]
            | select(.name as $n | $wanted | index($n))
            | select(.enabled)
            | .name
        '
)

if [ -n "$enabled" ]; then
    for o in $enabled; do
        jay randr output "$o" disable
    done
else
    for o in $outputs; do
        jay randr output "$o" enable
    done
fi
