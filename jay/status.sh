#!/bin/bash

# jay 内置 bar 的状态脚本，移植自 ~/.config/kwm/fifo.sh。
# 与 fifo.sh 的区别：不再写 /tmp/dwm.fifo，而是直接把一行状态输出到 stdout。

set -u

# 获取 CPU 使用率（基于 /proc/stat 的两次采样）
# iowait 是 CPU 空闲等待 I/O 的时间，不能算作忙时；
# steal 是虚拟化环境被宿主机占用的时间，应计入总时间。
get_cpu_usage() {
    local user nice system idle iowait irq softirq steal
    local total1 idle1 total2 idle2 total_delta idle_delta

    read -r _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle1=$((idle + iowait))

    sleep 1

    read -r _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle2=$((idle + iowait))

    total_delta=$((total2 - total1))
    idle_delta=$((idle2 - idle1))

    if [ "$total_delta" -le 0 ]; then
        echo "0.00%"
    else
        LC_ALL=C awk -v idle="$idle_delta" -v total="$total_delta" \
            'BEGIN { printf "%.2f%%", 100 - (idle / total) * 100 }'
    fi
}

# 获取内存占用率
get_memory_usage() {
    free -m | awk 'NR==2{printf "%.1f%%", $3/$2*100}'
}

# 获取根分区使用率与已用/总量
get_disk_usage() {
    df -h / | awk 'NR==2 {print $5, $3, $2}'
}

# 获取电源状态（电池信息）
get_battery_status() {
    if [ -d /sys/class/power_supply/BAT0 ]; then
        local capacity status status_icon icon
        capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
        status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")

        case "$status" in
            "Charging") status_icon="▲" ;;
            "Discharging") status_icon="▼" ;;
            "Full"|"Not charging") status_icon="●" ;;
            *) status_icon="?" ;;
        esac

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
        # 没有电池时显示交流电图标
        echo " AC"
    fi
}

# 获取当前时间
get_datetime() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 获取各输出当前工作区的布局（H=水平分割，V=垂直分割，M=mono 堆叠）
get_layout_status() {
    local base wl out ws mono split layout pos x1 side token
    local -a tokens

    wl="${WAYLAND_DISPLAY:-wayland-1}"
    case "$wl" in
        /*) base="${wl}-jay/debugfs" ;;
        *) base="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/${wl}-jay/debugfs" ;;
    esac
    [ -d "$base/outputs" ] || return 0

    for out in "$base"/outputs/*; do
        [ -d "$out" ] || continue
        ws=$(cat "$out/workspace/name" 2>/dev/null) || continue
        [ -n "$ws" ] || continue
        [ -d "$base/workspaces/$ws/container" ] || continue

        mono=$(cat "$base/workspaces/$ws/container/is_mono_live" 2>/dev/null || echo false)
        if [ "$mono" = "true" ]; then
            layout="M"
        else
            split=$(cat "$base/workspaces/$ws/container/split_live" 2>/dev/null || true)
            case "$split" in
                Horizontal) layout="H" ;;
                Vertical) layout="V" ;;
                *) layout="-" ;;
            esac
        fi

        pos=$(cat "$out/pos_live" 2>/dev/null || true)
        x1=${pos#\[}
        x1=${x1%%,*}
        if [ "${x1:-0}" -le 0 ]; then
            side="L"
        else
            side="R"
        fi
        tokens+=("${x1:-0}|${side}${ws}-${layout}")
    done

    [ "${#tokens[@]}" -eq 0 ] && return 0

    local sep="" joined=""
    while IFS='|' read -r _ token; do
        joined+="${sep}${token}"
        sep=" "
    done < <(printf '%s\n' "${tokens[@]}" | sort -t'|' -k1,1n)
    printf 'LAYOUT:%s' "$joined"
}

print_status() {
    local cpu_info mem_info disk_info bat_info date_info music_info layout_info
    local -a parts

    cpu_info="CPU:$(get_cpu_usage)"
    mem_info="MEM:$(get_memory_usage)"
    disk_info="DISK:$(get_disk_usage)"
    bat_info="BAT:$(get_battery_status)"
    date_info="$(get_datetime)"
    layout_info="$(get_layout_status)"
    music_info="$(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null || true)"

    parts=()
    [ -n "$layout_info" ] && parts+=("$layout_info")
    [ -n "$music_info" ] && parts+=("$music_info")
    parts+=("$cpu_info" "$mem_info" "$disk_info" "$bat_info" "$date_info")

    local sep=""
    for part in "${parts[@]}"; do
        printf '%s%s' "$sep" "$part"
        sep=" | "
    done
    printf '\n'
}

# --once 用于手动检查输出，正常启动时进入循环
if [ "${1:-}" = "--once" ]; then
    print_status
    exit 0
fi

while true; do
    print_status
    sleep 2
done
