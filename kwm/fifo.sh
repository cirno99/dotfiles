#!/bin/bash

# DWM状态栏脚本 - 包含CPU、内存、硬盘、电源信息
# 使用FIFO文件更新状态栏

# FIFO文件路径
FIFO_PATH="/tmp/dwm.fifo"

# 创建FIFO文件（如果不存在）
[ -e "$FIFO_PATH" ] || mkfifo "$FIFO_PATH"

# 获取CPU使用率（基于/proc/stat）
get_cpu_usage() {
    # 第一次采样 /proc/stat
    LAST_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
    LAST_SYS_IDLE=$(echo $LAST_CPU_INFO | awk '{print $4}')
    LAST_TOTAL_CPU_T=$(echo $LAST_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
    
    # 采样间隔1秒
    sleep 1
    
    # 第二次采样
    NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
    NEXT_SYS_IDLE=$(echo $NEXT_CPU_INFO | awk '{print $4}')
    NEXT_TOTAL_CPU_T=$(echo $NEXT_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
    
    # 系统空闲时间差
    SYSTEM_IDLE=$((NEXT_SYS_IDLE - LAST_SYS_IDLE))
    # CPU总时间差
    TOTAL_TIME=$((NEXT_TOTAL_CPU_T - LAST_TOTAL_CPU_T))
    
    # 计算CPU使用率（保留2位小数）
    if [ $TOTAL_TIME -eq 0 ]; then
        echo "0.00%"
    else
        # 使用awk进行浮点数计算
        CPU_USAGE=$(echo "${SYSTEM_IDLE} ${TOTAL_TIME}" | awk '{printf "%.2f", 100 - ($1/$2)*100}')
        echo "${CPU_USAGE}%"
    fi
}

# 获取硬盘使用率
get_disk_usage() {
    # 获取根分区的使用情况
    disk_info=$(df -h / | awk 'NR==2 {print $5, $3, $2}')
    echo "${disk_info}"
}

# 获取电源状态（电池信息）
get_battery_status() {
    if [ -d /sys/class/power_supply/BAT0 ]; then
        # 获取电池容量
        capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
        # 获取充电状态
        status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
        
        case "$status" in
            "Charging") status_icon="▲" ;;
            "Discharging") status_icon="▼" ;;
            "Full") status_icon="●" ;;
            *) status_icon="?" ;;
        esac
        
        # 根据容量显示不同图标
        if [ "$capacity" != "N/A" ]; then
            if [ "$capacity" -ge 80 ]; then
                icon=""
            elif [ "$capacity" -ge 60 ]; then
                icon=""
            elif [ "$capacity" -ge 40 ]; then
                icon=""
            elif [ "$capacity" -ge 20 ]; then
                icon=""
            else
                icon=""
            fi
            echo "${icon} ${status_icon} ${capacity}%"
        else
            echo "? ?"
        fi
    else
        # 如果没有电池，显示交流电状态
        echo " AC"
    fi
}

# 获取当前时间
get_datetime() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 主循环 - 持续更新状态栏
main_loop() {
    while true; do
        # 获取各个模块的信息
        # cpu_info="CPU:$(get_cpu_usage)"
        disk_info="DISK:$(get_disk_usage)"
        bat_info="BAT:$(get_battery_status)"
        date_info="$(get_datetime)"
        
        # 组合成完整的状态栏字符串
        # status_bar="${cpu_info} | ${disk_info} | ${bat_info} | ${date_info}"
        status_bar="${disk_info} | ${bat_info} | ${date_info}"
        
        # 写入FIFO文件
        echo "$status_bar" > "$FIFO_PATH"
        
        # 每2秒更新一次
        sleep 2
    done
}

# 启动主循环
main_loop
