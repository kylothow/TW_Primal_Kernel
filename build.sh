#!/bin/bash
#
# Kernel Build Script v3.2
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

KERNEL_NAME="Primal_Kernel"
KERNEL_VERSION="1.2.4β"
KERNEL_BASE="DQFM"

FUNC_CLEAN_ENVIRONMENT()
{
	tput reset

	echo ""
	echo "=================================================================="
	echo "START : FUNC_CLEAN_ENVIRONMENT"
	echo "=================================================================="
	echo ""

	make mrproper
	make distclean

	echo ""
	echo "=================================================================="
	echo "END   : FUNC_CLEAN_ENVIRONMENT"
	echo "=================================================================="
	echo ""

	exit 1
}

FUNC_UNKNOWN_INPUT()
{
	tput reset

	echo ""
	echo "=================================================================="
	echo "ERROR : UNKNOWN_INPUT"
	echo "=================================================================="
	echo ""
	echo "Usage: ./build.sh [option]"
	echo ""
	echo "Currently available options are:"
	echo "1 - to build for SM-G930F/FD/W8"
	echo "2 - to build for SM-G935F/FD/W8"
	echo "3 - to build for SM-G930S/L/K"
	echo "4 - to build for SM-G935S/L/K"
	echo "0 - to clean the build environment"
	echo ""
	echo "=================================================================="
	echo "ERROR : UNKNOWN_INPUT"
	echo "=================================================================="
	echo ""

	exit 1
}

if [ $1 == 0 ] ; then
	FUNC_CLEAN_ENVIRONMENT
elif [ $1 == 1 ] || [ $1 == 3 ] ; then
	export MODEL=herolte
elif [ $1 == 2 ] || [ $1 == 4 ] ; then
	export MODEL=hero2lte
else
	FUNC_UNKNOWN_INPUT
fi
if [ $1 == 1 ] || [ $1 == 2 ] ; then
	export VARIANT=eur
elif [ $1 == 3 ] || [ $1 == 4 ] ; then
	export VARIANT=kor
fi
export ARCH=arm64

if [ $(whoami) == kylothow ] && [ $(hostname) == xda-developers ] ; then
	BUILD_TYPE=""
else
	BUILD_TYPE="-UNOFFICIAL"
fi
export LOCALVERSION=-${KERNEL_NAME}-v${KERNEL_VERSION}${BUILD_TYPE}

export BUILD_CROSS_COMPILE=../aarch64-uber-linux-android-6.3.1-20170615/bin/aarch64-linux-android-
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`

PAGE_SIZE=2048
DTB_PADDING=0

KERNEL_DEFCONFIG=primal-${MODEL}${VARIANT}_defconfig

RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
ZIPDIR=$RDIR/build/$MODEL

FUNC_CLEAN()
{
	echo ""
	echo "=================================================================="
	echo "START : FUNC_CLEAN"
	echo "=================================================================="
	echo ""

	if [ -d $RDIR/arch/$ARCH/boot/dts/ ] ; then
		echo -e "Delete .dtb files in:\n "$RDIR/arch/$ARCH/boot/dts/""
		rm -f $RDIR/arch/$ARCH/boot/dts/*.dtb
	fi
	if [ -d $RDIR/arch/$ARCH/boot/dtb/ ] ; then
		echo -e "Delete all the files in:\n "$RDIR/arch/$ARCH/boot/dtb/""
		rm -f $RDIR/arch/$ARCH/boot/dtb/*.dtb
	fi
	if [ -a $RDIR/arch/$ARCH/boot/dtb.img ] ; then
		echo -e "Delete dtb.img in:\n "$RDIR/arch/$ARCH/boot/""
		rm $RDIR/arch/$ARCH/boot/dtb.img
	fi
	if [ -a $RDIR/arch/$ARCH/boot/Image ] ; then
		echo -e "Delete Image in:\n "$RDIR/arch/$ARCH/boot/""
		rm $RDIR/arch/$ARCH/boot/Image
	fi
	if [ -a $ZIPDIR/zImage ] ; then
		echo -e "Delete zImage in:\n "$ZIPDIR/""
		rm $ZIPDIR/zImage
	fi
	if [ -a $ZIPDIR/dtb ] ; then
		echo -e "Delete dtb in:\n "$ZIPDIR/""
		rm $ZIPDIR/dtb
	fi
	if [ -a $RDIR/out/*-$MODEL$VARIANT.zip ] ; then
		echo -e "Delete zip (for "$MODEL - $VARIANT") in:\n "$RDIR/out/""
		rm $RDIR/out/*-$MODEL$VARIANT.zip
	fi

	echo ""
	echo "=================================================================="
	echo "END   : FUNC_CLEAN"
	echo "=================================================================="
	echo ""
}

FUNC_BUILD_DTIMAGE_TARGET()
{
	echo ""
	echo "=================================================================="
	echo "START : FUNC_BUILD_DTIMAGE_TARGET"
	echo "=================================================================="
	echo ""

	if [ $MODEL == herolte ] && [ $VARIANT == eur ] ; then
		DTSFILES="exynos8890-herolte_eur_open_00 exynos8890-herolte_eur_open_01
				exynos8890-herolte_eur_open_02 exynos8890-herolte_eur_open_03
				exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09"
	elif [ $MODEL == hero2lte ] && [ $VARIANT == eur ] ; then
		DTSFILES="exynos8890-hero2lte_eur_open_00 exynos8890-hero2lte_eur_open_01
				exynos8890-hero2lte_eur_open_03 exynos8890-hero2lte_eur_open_04
				exynos8890-hero2lte_eur_open_08"
	elif [ $MODEL == herolte ] && [ $VARIANT == kor ] ; then
		DTSFILES="exynos8890-herolte_kor_all_00 exynos8890-herolte_kor_all_01
				exynos8890-herolte_kor_all_02 exynos8890-herolte_kor_all_03
				exynos8890-herolte_kor_all_04 exynos8890-herolte_kor_all_08
				exynos8890-herolte_kor_all_09"
	elif [ $MODEL == hero2lte ] && [ $VARIANT == kor ] ; then
		DTSFILES="exynos8890-hero2lte_kor_all_00 exynos8890-hero2lte_kor_all_01
				exynos8890-hero2lte_kor_all_03 exynos8890-hero2lte_kor_all_04
				exynos8890-hero2lte_kor_all_08 exynos8890-hero2lte_kor_all_09"
	fi

	if ! [ -d $DTBDIR ] ; then
		mkdir $DTBDIR
	fi
	cd $DTBDIR
	echo "Processing dts files..."
	echo ""
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done

	echo ""
	echo "Generating dtb.img..."
	echo ""
	$RDIR/scripts/dtbTool/dtbTool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE

	echo ""
	echo "=================================================================="
	echo "END   : FUNC_BUILD_DTIMAGE_TARGET"
	echo "=================================================================="
	echo ""
}

FUNC_BUILD_KERNEL()
{
	echo ""
	echo "=================================================================="
	echo "START : FUNC_BUILD_KERNEL"
	echo "=================================================================="
	echo ""
	echo "Build defconfig:	"$KERNEL_DEFCONFIG""
	echo "Build model:		"$MODEL""
	echo "Build variant:		"$VARIANT""
	echo ""

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	echo ""
	echo "=================================================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "=================================================================="
	echo ""
}

FUNC_BUILD_ZIP()
{
	echo ""
	echo "=================================================================="
	echo "START : FUNC_BUILD_ZIP"
	echo "=================================================================="
	echo ""

	cp $RDIR/arch/$ARCH/boot/Image $ZIPDIR/zImage
	cp $RDIR/arch/$ARCH/boot/dtb.img $ZIPDIR/dtb

	VERSION=$(grep -Po -m 1 '(?<=VERSION = ).*' $RDIR/Makefile)
	PATCHLEVEL=$(grep -Po -m 1 '(?<=PATCHLEVEL = ).*' $RDIR/Makefile)
	SUBLEVEL=$(grep -Po -m 1 '(?<=SUBLEVEL = ).*' $RDIR/Makefile)
	echo "kernel.version=$KERNEL_VERSION" > $ZIPDIR/.version
	echo "kernel.base=$KERNEL_BASE" >> $ZIPDIR/.version
	echo "linux.version=$VERSION.$PATCHLEVEL.$SUBLEVEL" >> $ZIPDIR/.version

	if ! [ -d $RDIR/out ] ; then
		mkdir $RDIR/out
	fi
	cd $ZIPDIR
	echo "=> Output: ${KERNEL_NAME}-v${KERNEL_VERSION}${BUILD_TYPE}-${MODEL}${VARIANT}.zip"
	echo ""
	zip -r9 ../../out/${KERNEL_NAME}-v${KERNEL_VERSION}${BUILD_TYPE}-${MODEL}${VARIANT}.zip * .version -x modules/\*

	echo ""
	echo "=================================================================="
	echo "END   : FUNC_BUILD_ZIP"
	echo "=================================================================="
	echo ""
}

# MAIN FUNCTION
rm -f ./build.log
(

	tput reset

	START_TIME=`date +%s`

	FUNC_CLEAN
	FUNC_BUILD_KERNEL
	FUNC_BUILD_DTIMAGE_TARGET
	FUNC_BUILD_ZIP

	END_TIME=`date +%s`

	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time was $ELAPSED_TIME seconds."
	echo ""

) 2>&1 | tee -a ./build.log
