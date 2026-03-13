#!/bin/bash

# 获取显示器当前布局的脚本
# 用法: ./get_layout.sh [monitor_name]
# 示例: ./get_layout.sh eDP-1

# 默认显示器名称
MONITOR="${1:-eDP-1}"

# 获取布局信息
mmsg -g -o "$MONITOR" -t -l | sed -n '10p' | awk '{print $2}'

