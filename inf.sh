#!/bin/bash
# (C) 2017 Joel Schneider
# MIT license
# TODO: don't duplicate output for SBo packages that are installed

INFO="no"
DEPS="no"
DEFAULT="yes"

if [ -t 1 ]; then # Terminal. Useful, as piping via less doesn't give colour properly
	HI='\033[1;33m' # Highlight colour (yellow)
	PURPLE='\033[0;35m' # Purple
	RED='\033[0;31m' # RED
	DC='\033[0m' # Defualt colour
fi

if [ "x$1" == "x-id" ]; then
	INFO="yes"
	DEPS="yes"
	DEFAULT="no"
	shift
elif [ "x$1" == "x-di" ]; then
	INFO="yes"
	DEPS="yes"
	DEFAULT="no"
	shift
elif [ "x$1" == "x-d" ]; then
	DEPS="yes"
	DEFAULT="no"
	shift
elif [ "x$1" == "x-i" ]; then
	INFO="yes"
	DEFAULT="no"
	shift
fi
if [ "x$1" == "x-d" ]; then
	DEPS="yes"
	DEFAULT="no"
	shift
fi
if [ "x$1" == "x" ]; then
	echo "Usage: $0 [-d] [-i] package"
	echo "(-d for possible dependant SBo packages)"
	echo "(-i for package info)"
	echo "Default: all"
	exit 1
fi

if [ "$DEFAULT" == "yes" ]; then
	INFO="yes"
	DEPS="yes"
fi

cd /var/log/packages/
EXACTMATCH="false"
for fullpackagename in `find . | grep $1 `; do
	PACKAGENAME=`echo $fullpackagename | sed 's/^\.\///' | sed 's/\-[0-9].*//'`
	if [ "x$1" == "x$PACKAGENAME" ]; then
		EXACTMATCH="true"
	fi
done


function package_info {
	echo -en "${HI}"
	cat /var/log/packages/$PACKAGENAME* | head -16 | tail -11 | grep -v "$PACKAGENAME:\$" | cut -f "2-" -d " "
	echo -en "${DC}"
	cd /var/lib/sbopkg/queues
	PACKDEPS=""
	if [ -f "$PACKAGENAME.sqf" ]; then
		echo -en "${HI}$PACKAGENAME requires:${DC} "
		for PACKN in `cat $PACKAGENAME.sqf `; do
			if [ "$PACKN" != "$PACKAGENAME" ]; then
				PACKDEPS="$PACKDEPS, $PURPLE$PACKN$DC"
			fi
		done
		echo -en "${PACKDEPS:2}\n"
	fi
}

function sbo_package_info {
	echo -en "${RED}"
	cd /var/lib/sbopkg/SBo/
	for file in `find . -type d | grep $PACKAGENAME$`; do
		cd /var/lib/sbopkg/SBo/
		cat "`echo $file`/slack-desc" | tail -11 | grep -v "$PACKAGENAME:\$" | cut -f "2-" -d " "
		cd /var/lib/sbopkg/queues
		PACKDEPS=""
		if [ -f "$PACKAGENAME.sqf" ]; then
			echo -en "${HI}$PACKAGENAME requires:${DC} "
			for PACKN in `cat $PACKAGENAME.sqf `; do
				if [ "$PACKN" != "$PACKAGENAME" ]; then
					PACKDEPS="$PACKDEPS, $PURPLE$PACKN$DC"
				fi
			done
			echo -en "${PACKDEPS:2}\n"
		fi
	done
	echo -en "${DC}"
}

function deps {
	cd /var/lib/sbopkg/queues
	PACKS=`grep -ir $PACKAGENAME$ . | sed 's/^\.\///' | sed 's/\.sqf\:.*//' | grep -v ^$PACKAGENAME$ | uniq`
	PACKTEXT=""
	if [ "x$PACKS" != "x" ]; then
		echo -en "${HI}These depend on $PACKAGENAME${DC}: "
		for PACK in $PACKS; do
			if [ "$PACK" != "$PACKAGENAME" ]; then
				PACKTEXT="$PACKTEXT, $PURPLE$PACK$DC"
			fi
		done
		echo -en "${PACKTEXT:2}\n"
	fi
}

if [ "x$PACKAGENAME" == "x" ]; then # Not installed
	PACKAGENAME="$1"
fi

if [ "$EXACTMATCH" == "true" ]; then
	PACKAGENAME="$1"
	if [ "$INFO" == "yes" ]; then
		package_info
	fi
	if [ "$DEPS" == "yes" ]; then
		deps
	fi
else
	echo -en "${HI}Multiple packages match '$1'.$DC "
	cd /var/log/packages
	for fullpackagename in `find . | grep -i $1 `; do
		PACKAGENAME=`echo $fullpackagename | sed 's/^\.\///' | sed 's/\-[0-9].*//'`
		echo
		if [ "$INFO" == "yes" ]; then
			package_info
		fi
		if [ "$DEPS" == "yes" ]; then
			deps
		fi
	done

	cd /var/lib/sbopkg/SBo/*/
	for file in `find . -type d | grep $PACKAGENAME | grep -v ^\./$PACKAGENAME`; do
		echo
		PACKAGENAME="`echo $file | sed 's/.*\///'`"
		if [ "$INFO" == "yes" ]; then
			sbo_package_info
		fi
		if [ "$DEPS" == "yes" ]; then
			deps
		fi
	done

fi

