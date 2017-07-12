#!/system/bin/sh
#
# Copyright (C) 2017 Michele Beccalossi <beccalossi.michele@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#

mount -o rw,remount /;
mount -o rw,remount /system;

# z-ram initialization
swapoff "/dev/block/zram0/" > dev/null 2>&1;
echo "1" > /sys/block/zram0/reset;
echo "536870912" > sys/block/zram0/disksize;
mkswap "/dev/block/zram0/" > dev/null 2>&1;
swapon "/dev/block/zram0/" > dev/null 2>&1;
echo "lz4" > /sys/block/zram0/comp_algorithm;
echo "4" > /sys/block/zram0/max_comp_streams;

mount -o ro,remount /;
mount -o ro,remount /system;
