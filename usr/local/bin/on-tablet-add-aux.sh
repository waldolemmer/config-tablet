#!/bin/sh

# device-name
wait_for_device() {
	device_name="$1"
	while true; do
		# This command works when the stdout file descriptor exists
		xsetwacom --get "$device_name" Area > /dev/null
		if [ $? -eq 0 ]; then
			return
		fi

		sleep 0.2;
	done
}

# xsetwacom-set-arguments...
set_property() {
	xsetwacom --set "$@"
}

# device-name xsetwacom-set-argument-lists...
set_device_properties() {
	device_name="$1"
	shift 1

	for args in "$@"; do
		set_property "$device_name" $args
	done
}

# device-names...
configure_devices() {
	for device_name in "$@"; do
		wait_for_device "$device_name"

		# TODO (Area)
		#
		# 	Area <x1> <y1> <x2> <y2>
		#
		# Maps the screen area as follows:
		# (x1, y1) ----------------------|
		#    |                           |
		#    |        screen area        |
		#    |                           |
		#    | (0, 0) ----------|        |
		#    |   | drawing area |        |
		#    |   |------- (32767, 32767) |
		#    |                           |
		#    |----------------------- (x2, y2)
		#
		# The following variables must all be measured in the same unit
		# of length such as pixels or millimeters:
		#
		#        0  left         right  width
		#         |--|-------------|------|--->
		#         |                       |
		#         |    physical screen    |
		#         |                       |
		#    top -| |--------------|      |
		#         | | drawing area |      |
		# bottom -| |--------------|      |
		#         |                       |
		# height -|-----------------------|
		#         v
		#
		# These variables can then be used to calculate x1, y1, x2 and
		# y2:
		#
		# x1 = -left / (right - left) * 32767
		# y1 = -top / (bottom - top) * 32767
		# x2 = (width - left) / (right - left) * 32767
		# y2 = (height - top) / (bottom - top) * 32767
		set_device_properties "$device_name" \
			'Area -28165 -10037 60932 70848' \
			'Suppress 0' \
			'RawSample 1' \
			'Threshold 1'
	done
}

# TODO (user)
export XAUTHORITY=/home/user/.Xauthority
export DISPLAY=:0

# TODO (xsetwacom --list devices)
configure_devices 'UGTABLET 6 inch PenTablet stylus' 'UGTABLET 6 inch PenTablet eraser'
