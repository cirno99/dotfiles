#!/bin/bash

# 循环切换窗口管理器布局的脚本
# 用法: ./set_layout_cycle.sh [monitor_name]
# 示例: ./set_layout_cycle.sh eDP-1

# 默认显示器名称
MONITOR="${1:-eDP-1}"

# 所有可用的布局列表
LAYOUTS=("T" "S" "G" "M" "K" "CT" "RT" "VS" "VT" "VG" "VK" "TG")

# 状态文件路径（基于显示器名称，支持多显示器）
STATE_DIR="$HOME/.config/vibepanel"
STATE_FILE="$STATE_DIR/${MONITOR}_layout_index"

# 创建状态目录（如果不存在）
mkdir -p "$STATE_DIR"

# 读取当前布局索引
if [ -f "$STATE_FILE" ]; then
    CURRENT_INDEX=$(cat "$STATE_FILE")
else
    CURRENT_INDEX=0
fi

# 确保索引在有效范围内
if [ "$CURRENT_INDEX" -ge "${#LAYOUTS[@]}" ] || [ "$CURRENT_INDEX" -lt 0 ]; then
    CURRENT_INDEX=0
fi

# 获取当前要设置的布局
CURRENT_LAYOUT="${LAYOUTS[$CURRENT_INDEX]}"

# 设置布局
echo "正在为显示器 $MONITOR 设置布局: $CURRENT_LAYOUT"
mmsg -s -o "$MONITOR" -l "$CURRENT_LAYOUT"

# 计算下一个索引（循环）
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#LAYOUTS[@]} ))

# 保存下一个索引到状态文件
echo "$NEXT_INDEX" > "$STATE_FILE"

echo "下次将切换到布局: ${LAYOUTS[$NEXT_INDEX]}"

return 1
