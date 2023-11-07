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
		# TODO (area according to screen size)
		set_device_properties "$device_name" \
			'Area -27268 -22937 59990 55704' \
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
