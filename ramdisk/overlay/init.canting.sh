#!/system/bin/sh

write() { echo "$2" > "$1"; }

setprop sys.io.scheduler "cfq"

#Zram configs
write /sys/block/zram0/reset 1
write /proc/sys/vm/page-cluster 0
write /sys/block/zram0/disksize 1073741824
mkswap /dev/block/zram0
swapon /dev/block/zram0

#CPU configs
write /sys/module/cpu_boost/parameters/input_boost_ms 64
write /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us 500
write /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us 20000
write /sys/devices/system/cpu/cpufreq/schedutil/iowait_boost_enable 1
write /sys/devices/system/cpu/cpufreq/schedutil/hispeed_freq 0
write /sys/devices/system/cpu/cpufreq/schedutil/pl 0
