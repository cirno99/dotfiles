const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const linux = std.os.linux;
const posix = std.posix;

const FIFO_PATH = "/tmp/dwm.fifo";
const PATH_MAX = 256;
const IO_BUF = 8192;

var cpu_prev_idle: u64 = 0;
var cpu_prev_total: u64 = 0;
var cpu_first = true;

const Statfs = extern struct {
    f_type: i64,
    f_bsize: i64,
    f_blocks: u64,
    f_bfree: u64,
    f_bavail: u64,
    f_files: u64,
    f_ffree: u64,
    f_fsid: [2]i32,
    f_namelen: i64,
    f_frsize: i64,
    f_flags: i64,
    f_spare: [4]i64,
};

fn ensureFifo() void {
    var cpath: [FIFO_PATH.len + 1:0]u8 = undefined;
    @memcpy(cpath[0..FIFO_PATH.len], FIFO_PATH);
    cpath[FIFO_PATH.len] = 0;

    const rc = linux.mknod(&cpath, linux.S.IFIFO | 0o644, 0);
    switch (linux.errno(rc)) {
        .SUCCESS, .EXIST => {},
        else => |e| std.log.err("ensureFifo: {s}", .{@tagName(e)}),
    }
}

inline fn cStr(s: []const u8) [PATH_MAX:0]u8 {
    var buf: [PATH_MAX:0]u8 = undefined;
    const n = @min(s.len, buf.len - 1);
    @memcpy(buf[0..n], s[0..n]);
    buf[n] = 0;
    return buf;
}

fn readFile(allocator: mem.Allocator, path: []const u8) ![]u8 {
    const cpath = cStr(path);
    const fd_rc = linux.openat(linux.AT.FDCWD, &cpath, .{}, 0);
    if (linux.errno(fd_rc) != .SUCCESS) return error.OpenFailed;
    const fd: i32 = @intCast(fd_rc);
    defer _ = linux.close(fd);

    var file_buf: [IO_BUF]u8 = undefined;
    var total: usize = 0;
    while (total < file_buf.len) {
        const rc = linux.read(fd, file_buf[total..].ptr, file_buf.len - total);
        const err = linux.errno(rc);
        if (err == .INTR) continue;
        if (err != .SUCCESS or rc == 0) break;
        total += rc;
    }

    const result = try allocator.alloc(u8, total);
    @memcpy(result[0..total], file_buf[0..total]);
    return result;
}

fn sysWrite(fd: i32, data: []const u8) void {
    var written: usize = 0;
    while (written < data.len) {
        const rc = linux.write(fd, data.ptr + written, data.len - written);
        const err = linux.errno(rc);
        if (err == .INTR) continue;
        if (err != .SUCCESS) break;
        written += rc;
    }
}

fn getCpuUsage(buf: []u8) []const u8 {
    const content = readFile(std.heap.page_allocator, "/proc/stat") catch
        return fmt.bufPrint(buf, "0.00%", .{}) catch "ERR";
    defer std.heap.page_allocator.free(content);

    var lines = mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        if (!mem.startsWith(u8, line, "cpu ")) continue;
        const rest = mem.trimStart(u8, line["cpu ".len..], " ");
        var it = mem.splitScalar(u8, rest, ' ');
        var vals: [7]u64 = undefined;
        var i: usize = 0;
        while (it.next()) |f| {
            if (f.len == 0) continue;
            if (i >= vals.len) break;
            vals[i] = fmt.parseInt(u64, f, 10) catch continue;
            i += 1;
        }
        if (i < 7) return fmt.bufPrint(buf, "0.00%", .{}) catch "ERR";

        var total: u64 = 0;
        var idle: u64 = 0;
        for (vals, 0..) |val, idx| {
            total += val;
            if (idx == 3) idle += val; // idle
            if (idx == 4) idle += val; // iowait
        }

        if (cpu_first) {
            cpu_first = false;
            cpu_prev_idle = idle;
            cpu_prev_total = total;
            return fmt.bufPrint(buf, "0.00%", .{}) catch "ERR";
        }

        const idle_delta = idle -| cpu_prev_idle;
        const total_delta = total -| cpu_prev_total;
        cpu_prev_idle = idle;
        cpu_prev_total = total;

        if (total_delta == 0) return fmt.bufPrint(buf, "0.00%", .{}) catch "ERR";

        const pct = 100.0 - (@as(f64, @floatFromInt(idle_delta)) / @as(f64, @floatFromInt(total_delta)) * 100.0);
        return fmt.bufPrint(buf, "{d:.2}%", .{pct}) catch "ERR";
    }
    return fmt.bufPrint(buf, "0.00%", .{}) catch "ERR";
}

fn formatBytes(v: u64) f64 {
    var val: f64 = @floatFromInt(v);
    var i: u32 = 0;
    while (val >= 1024.0 and i < 4) {
        val /= 1024.0;
        i += 1;
    }
    return val;
}

fn formatBytesUnit(v: u64) u8 {
    if (v < 1024) return 'B';
    if (v < 1024 * 1024) return 'K';
    if (v < 1024 * 1024 * 1024) return 'M';
    return 'G';
}

fn getMemoryUsage(buf: []u8) []const u8 {
    const content = readFile(std.heap.page_allocator, "/proc/meminfo") catch
        return fmt.bufPrint(buf, "N/A", .{}) catch "ERR";
    defer std.heap.page_allocator.free(content);

    var mem_total: u64 = 0;
    var mem_avail: u64 = 0;
    var lines = mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        if (mem.startsWith(u8, line, "MemTotal:")) {
            const v = mem.trim(u8, line["MemTotal:".len..], " \t");
            const space = mem.indexOfScalar(u8, v, ' ') orelse v.len;
            mem_total = fmt.parseInt(u64, v[0..space], 10) catch 0;
        } else if (mem.startsWith(u8, line, "MemAvailable:")) {
            const v = mem.trim(u8, line["MemAvailable:".len..], " \t");
            const space = mem.indexOfScalar(u8, v, ' ') orelse v.len;
            mem_avail = fmt.parseInt(u64, v[0..space], 10) catch 0;
        }
    }

    const used_kb = mem_total -| mem_avail;
    const used = formatBytes(used_kb * 1024);
    const avail = formatBytes(mem_avail * 1024);
    return fmt.bufPrint(buf, "{d:.1}{c} {d:.1}{c}", .{
        used,  formatBytesUnit(used_kb * 1024),
        avail, formatBytesUnit(mem_avail * 1024),
    }) catch "ERR";
}

fn getDiskUsage(buf: []u8) []const u8 {
    var st: Statfs = undefined;
    const cpath = cStr("/");
    const rc = linux.syscall2(.statfs, @intFromPtr(&cpath), @intFromPtr(&st));
    if (linux.errno(rc) != .SUCCESS)
        return fmt.bufPrint(buf, "N/A", .{}) catch "ERR";

    const total = st.f_blocks * @as(u64, @intCast(st.f_frsize));
    const free = st.f_bfree * @as(u64, @intCast(st.f_frsize));
    const used = total -| free;
    const pct = if (total > 0)
        @as(f64, @floatFromInt(used)) / @as(f64, @floatFromInt(total)) * 100.0
    else
        0.0;

    return fmt.bufPrint(buf, "{d:.0}% {d:.1}{c} {d:.1}{c}", .{
        pct,                formatBytes(used),      formatBytesUnit(used),
        formatBytes(total), formatBytesUnit(total),
    }) catch "ERR";
}

fn getBatteryStatus(buf: []u8) []const u8 {
    const capacity_raw = readFile(std.heap.page_allocator, "/sys/class/power_supply/BAT0/capacity") catch
        return fmt.bufPrint(buf, "\u{f0e7} AC", .{}) catch "ERR";
    defer if (capacity_raw.len > 0) std.heap.page_allocator.free(capacity_raw);
    if (capacity_raw.len == 0)
        return fmt.bufPrint(buf, "\u{f0e7} AC", .{}) catch "ERR";

    const cap_str = mem.trim(u8, capacity_raw, "\n\r ");
    const capacity = fmt.parseInt(u64, cap_str, 10) catch
        return fmt.bufPrint(buf, "? ?", .{}) catch "ERR";

    const status_raw = readFile(std.heap.page_allocator, "/sys/class/power_supply/BAT0/status") catch "";
    defer if (status_raw.len > 0) std.heap.page_allocator.free(status_raw);
    const st = mem.trim(u8, status_raw, "\n\r ");

    const status_icon: []const u8 = if (mem.eql(u8, st, "Charging"))
        "\u{25b2}"
    else if (mem.eql(u8, st, "Discharging"))
        "\u{25bc}"
    else if (mem.eql(u8, st, "Full"))
        "\u{25cf}"
    else if (mem.eql(u8, st, "Not charging"))
        " "
    else
        "?";

    return fmt.bufPrint(buf, "{s} {d}%", .{ status_icon, capacity }) catch "ERR";
}

fn getNowSec() i64 {
    var ts: linux.timespec = undefined;
    const rc = linux.syscall2(
        .clock_gettime,
        @intFromEnum(linux.CLOCK.REALTIME),
        @intFromPtr(&ts),
    );
    if (linux.errno(rc) != .SUCCESS) return 0;
    return ts.sec;
}

fn getDateTime(buf: []u8) []const u8 {
    const now = getNowSec();
    const epoch = std.time.epoch.EpochSeconds{ .secs = @as(u64, @intCast(now)) };
    const epoch_day = epoch.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const day_secs = epoch.getDaySeconds();
    return fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2}", .{
        year_day.year,              @as(u32, @intFromEnum(month_day.month)), month_day.day_index + 1,
        day_secs.getHoursIntoDay(), day_secs.getMinutesIntoHour(),           day_secs.getSecondsIntoMinute(),
    }) catch "ERR";
}

fn getMusicInfo(allocator: mem.Allocator, envp: [*:null]const ?[*:0]const u8) []const u8 {
    var pipe_fds: [2]i32 = undefined;
    const prc = linux.pipe2(&pipe_fds, .{});
    if (linux.errno(prc) != .SUCCESS) return "";
    errdefer {
        _ = linux.close(pipe_fds[0]);
        _ = linux.close(pipe_fds[1]);
    }

    const pid_rc = linux.fork();
    if (linux.errno(pid_rc) != .SUCCESS) return "";
    const child_pid: i32 = @intCast(pid_rc);

    if (child_pid == 0) {
        _ = linux.close(pipe_fds[0]);

        const rc2 = linux.dup2(pipe_fds[1], 1);
        if (linux.errno(rc2) != .SUCCESS) linux.exit(1);
        _ = linux.close(pipe_fds[1]);

        const sh_c = cStr("sh");
        const sh_flag = cStr("-c");
        const sh_cmd = cStr("rmpc song | jq -r '.metadata.artist + \" - \" + .metadata.title'");
        const argv: [:null]const ?[*:0]const u8 = &.{ &sh_c, &sh_flag, &sh_cmd, null };

        _ = linux.execve(&cStr("sh"), argv, envp);
        _ = linux.execve(&cStr("/bin/sh"), argv, envp);
        _ = linux.execve(&cStr("/usr/bin/sh"), argv, envp);
        linux.exit(127);
    }

    _ = linux.close(pipe_fds[1]);

    var out: [IO_BUF]u8 = undefined;
    var total: usize = 0;
    while (total < out.len) {
        const rc = linux.read(pipe_fds[0], out[total..].ptr, out.len - total);
        const err = linux.errno(rc);
        if (err == .INTR) continue;
        if (err != .SUCCESS or rc == 0) break;
        total += rc;
    }
    _ = linux.close(pipe_fds[0]);

    var status: u32 = undefined;
    _ = linux.waitpid(child_pid, &status, 0);

    const trimmed = mem.trim(u8, out[0..total], "\n\r ");
    return allocator.dupe(u8, trimmed) catch "";
}

fn writeToFifo(data: []const u8) void {
    const cpath = cStr(FIFO_PATH);
    const fd_rc = linux.openat(linux.AT.FDCWD, &cpath, .{ .ACCMODE = .WRONLY }, 0);
    if (linux.errno(fd_rc) != .SUCCESS) {
        std.log.err("open FIFO: {s}", .{@tagName(linux.errno(fd_rc))});
        return;
    }
    const fd: i32 = @intCast(fd_rc);
    defer _ = linux.close(fd);
    sysWrite(fd, data);
}

fn nanosleep(ns: u64) void {
    var ts = linux.timespec{
        .sec = @as(isize, @intCast(ns / std.time.ns_per_s)),
        .nsec = @as(isize, @intCast(ns % std.time.ns_per_s)),
    };
    while (true) {
        const rc = linux.syscall2(.nanosleep, @intFromPtr(&ts), @intFromPtr(&ts));
        switch (linux.errno(rc)) {
            .SUCCESS => break,
            .INTR => continue,
            else => break,
        }
    }
}

pub fn main(init: std.process.Init.Minimal) void {
    ensureFifo();

    {
        const pid = linux.getpid();
        var msg: [64]u8 = undefined;
        const s = fmt.bufPrint(&msg, "Status bar started (PID {d})\n", .{pid}) catch "started\n";
        _ = linux.write(1, s.ptr, s.len);
    }

    const envp = init.environ.block.slice.ptr;

    while (true) {
        var cpu_b: [16]u8 = undefined;
        var mem_b: [24]u8 = undefined;
        var disk_b: [32]u8 = undefined;
        var bat_b: [32]u8 = undefined;
        var date_b: [24]u8 = undefined;

        const cpu = getCpuUsage(&cpu_b);
        const mem_usage = getMemoryUsage(&mem_b);
        const disk = getDiskUsage(&disk_b);
        const bat = getBatteryStatus(&bat_b);
        const dt = getDateTime(&date_b);

        const music = getMusicInfo(std.heap.page_allocator, envp);
        defer if (music.len > 0) std.heap.page_allocator.free(music);

        var status: [512]u8 = undefined;
        const bar = fmt.bufPrint(&status, " {s} | CPU:{s} | MEM:{s} | DISK:{s} | BAT:{s} | {s}", .{
            music,
            cpu,
            mem_usage,
            disk,
            bat,
            dt,
        }) catch continue;

        writeToFifo(bar);

        nanosleep(2 * std.time.ns_per_s);
    }
}
