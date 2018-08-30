#!/bin/bash

# ============= FUTURE YUNOHOST HELPER =============
# Delete a file checksum from the app settings
#
# $app should be defined when calling this helper
#
# usage: ynh_remove_file_checksum file
# | arg: file - The file for which the checksum will be deleted
ynh_delete_file_checksum () {
	local checksum_setting_name=checksum_${1//[\/ ]/_}	# Replace all '/' and ' ' by '_'
	ynh_app_setting_delete $app $checksum_setting_name
}

# Internal helper design to allow helpers to use getopts to manage their arguments
#
# example: function my_helper()
# {
#     declare -Ar args_array=( [a]=arg1= [b]=arg2= [c]=arg3 )
#     local arg1
#     local arg2
#     local arg3
#     ynh_handle_getopts_args "$@"
#
#     [...]
# }
# my_helper --arg1 "val1" -b val2 -c
#
# usage: ynh_handle_getopts_args "$@"
# | arg: $@    - Simply "$@" to tranfert all the positionnal arguments to the function
#
# This helper need an array, named "args_array" with all the arguments used by the helper
# 	that want to use ynh_handle_getopts_args
# Be carreful, this array has to be an associative array, as the following example:
# declare -Ar args_array=( [a]=arg1 [b]=arg2= [c]=arg3 )
# Let's explain this array:
# a, b and c are short options, -a, -b and -c
# arg1, arg2 and arg3 are the long options associated to the previous short ones. --arg1, --arg2 and --arg3
# For each option, a short and long version has to be defined.
# Let's see something more significant
# declare -Ar args_array=( [u]=user [f]=finalpath= [d]=database )
#
# NB: Because we're using 'declare' without -g, the array will be declared as a local variable.
#
# Please keep in mind that the long option will be used as a variable to store the values for this option.
# For the previous example, that means that $finalpath will be fill with the value given as argument for this option.
#
# Also, in the previous example, finalpath has a '=' at the end. That means this option need a value.
# So, the helper has to be call with --finalpath /final/path, --finalpath=/final/path or -f /final/path, the variable $finalpath will get the value /final/path
# If there's many values for an option, -f /final /path, the value will be separated by a ';' $finalpath=/final;/path
# For an option without value, like --user in the example, the helper can be called only with --user or -u. $user will then get the value 1.
#
# To keep a retrocompatibility, a package can still call a helper, using getopts, with positional arguments.
# The "legacy mode" will manage the positional arguments and fill the variable in the same order than they are given in $args_array.
# e.g. for `my_helper "val1" val2`, arg1 will be filled with val1, and arg2 with val2.
ynh_handle_getopts_args () {
	# Manage arguments only if there's some provided
	set +x
	if [ $# -ne 0 ]
	then
		# Store arguments in an array to keep each argument separated
		local arguments=("$@")

		# For each option in the array, reduce to short options for getopts (e.g. for [u]=user, --user will be -u)
		# And built parameters string for getopts
		# ${!args_array[@]} is the list of all keys in the array (A key is 'u' in [u]=user, user is a value)
		local getopts_parameters=""
		local key=""
		for key in "${!args_array[@]}"
		do
			# Concatenate each keys of the array to build the string of arguments for getopts
			# Will looks like 'abcd' for -a -b -c -d
			# If the value of a key finish by =, it's an option with additionnal values. (e.g. --user bob or -u bob)
			# Check the last character of the value associate to the key
			if [ "${args_array[$key]: -1}" = "=" ]
			then
				# For an option with additionnal values, add a ':' after the letter for getopts.
				getopts_parameters="${getopts_parameters}${key}:"
			else
				getopts_parameters="${getopts_parameters}${key}"
			fi
			# Check each argument given to the function
			local arg=""
			# ${#arguments[@]} is the size of the array
			for arg in `seq 0 $(( ${#arguments[@]} - 1 ))`
			do
				# And replace long option (value of the key) by the short option, the key itself
				# (e.g. for [u]=user, --user will be -u)
				# Replace long option with =
				arguments[arg]="${arguments[arg]//--${args_array[$key]}/-${key} }"
				# And long option without =
				arguments[arg]="${arguments[arg]//--${args_array[$key]%=}/-${key}}"
			done
		done

		# Read and parse all the arguments
		# Use a function here, to use standart arguments $@ and be able to use shift.
		parse_arg () {
			# Read all arguments, until no arguments are left
			while [ $# -ne 0 ]
			do
				# Initialize the index of getopts
				OPTIND=1
				# Parse with getopts only if the argument begin by -, that means the argument is an option
				# getopts will fill $parameter with the letter of the option it has read.
				local parameter=""
				getopts ":$getopts_parameters" parameter || true

				if [ "$parameter" = "?" ]
				then
					ynh_die "Invalid argument: -${OPTARG:-}"
				elif [ "$parameter" = ":" ]
				then
					ynh_die "-$OPTARG parameter requires an argument."
				else
					local shift_value=1
					# Use the long option, corresponding to the short option read by getopts, as a variable
					# (e.g. for [u]=user, 'user' will be used as a variable)
					# Also, remove '=' at the end of the long option
					# The variable name will be stored in 'option_var'
					local option_var="${args_array[$parameter]%=}"
					# If this option doesn't take values
					# if there's a '=' at the end of the long option name, this option takes values
					if [ "${args_array[$parameter]: -1}" != "=" ]
					then
						# 'eval ${option_var}' will use the content of 'option_var'
						eval ${option_var}=1
					else
						# Read all other arguments to find multiple value for this option.
						# Load args in a array
						local all_args=("$@")

						# If the first argument is longer than 2 characters,
						# There's a value attached to the option, in the same array cell
						if [ ${#all_args[0]} -gt 2 ]; then
							# Remove the option and the space, so keep only the value itself.
							all_args[0]="${all_args[0]#-${parameter} }"
							# Reduce the value of shift, because the option has been removed manually
							shift_value=$(( shift_value - 1 ))
						fi

						# Then read the array value per value
						for i in `seq 0 $(( ${#all_args[@]} - 1 ))`
						do
							# If this argument is an option, end here.
							if [ "${all_args[$i]:0:1}" == "-" ] || [ -z "${all_args[$i]}" ]
							then
								# Ignore the first value of the array, which is the option itself
								if [ "$i" -ne 0 ]; then
									break
								fi
							else
								# Declare the content of option_var as a variable.
								eval ${option_var}=""
								# Else, add this value to this option
								# Each value will be separated by ';'
								if [ -n "${!option_var}" ]
								then
									# If there's already another value for this option, add a ; before adding the new value
									eval ${option_var}+="\;"
								fi
								eval ${option_var}+=\"${all_args[$i]}\"
								shift_value=$(( shift_value + 1 ))
							fi
						done
					fi
				fi

				# Shift the parameter and its argument(s)
				shift $shift_value
			done
		}

		# LEGACY MODE
		# Check if there's getopts arguments
		if [ "${arguments[0]:0:1}" != "-" ]
		then
			# If not, enter in legacy mode and manage the arguments as positionnal ones.
			echo "! Helper used in legacy mode !"
			for i in `seq 0 $(( ${#arguments[@]} -1 ))`
			do
				# Use getopts_parameters as a list of key of the array args_array
				# Remove all ':' in getopts_parameters
				getopts_parameters=${getopts_parameters//:}
				# Get the key from getopts_parameters, by using the key according to the position of the argument.
				key=${getopts_parameters:$i:1}
				# Use the long option, corresponding to the key, as a variable
				# (e.g. for [u]=user, 'user' will be used as a variable)
				# Also, remove '=' at the end of the long option
				# The variable name will be stored in 'option_var'
				local option_var="${args_array[$key]%=}"

				# Store each value given as argument in the corresponding variable
				# The values will be stored in the same order than $args_array
				eval ${option_var}+=\"${arguments[$i]}\"
			done
		else
			# END LEGACY MODE
			# Call parse_arg and pass the modified list of args as an array of arguments.
			parse_arg "${arguments[@]}"
		fi
	fi
	set -x
}

# Start (or other actions) a service,  print a log in case of failure and optionnaly wait until the service is completely started
#
# usage: ynh_systemd_action [-n service_name] [-a action] [ [-l "line to match"] [-p log_path] [-t timeout] [-e length] ]
# | arg: -n, --service_name= - Name of the service to reload. Default : $app
# | arg: -a, --action=       - Action to perform with systemctl. Default: start
# | arg: -l, --line_match=   - Line to match - The line to find in the log to attest the service have finished to boot.
#                              If not defined it don't wait until the service is completely started.
# | arg: -p, --log_path=     - Log file - Path to the log file. Default : /var/log/$app/$app.log
# | arg: -t, --timeout=      - Timeout - The maximum time to wait before ending the watching. Default : 300 seconds.
# | arg: -e, --length=       - Length of the error log : Default : 20
ynh_systemd_action() {
    # Declare an array to define the options of this helper.
    declare -Ar args_array=( [n]=service_name= [a]=action= [l]=line_match= [p]=log_path= [t]=timeout= [e]=length= )
    local service_name
    local action
    local line_match
    local length
    local log_path
    local timeout

    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"

    local service_name="${service_name:-$app}"
    local action=${action:-start}
    local log_path="${log_path:-/var/log/$service_name/$service_name.log}"
    local length=${length:-20}
    local timeout=${timeout:-300}

    # Start to read the log
    if [[ -n "${line_match:-}" ]]
    then
        local templog="$(mktemp)"
	# Following the starting of the app in its log
	if [ "$log_path" == "systemd" ] ; then
            # Read the systemd journal
            journalctl -u $service_name -f --since=-45 > "$templog" &
	else
            # Read the specified log file
            tail -F -n0 "$log_path" > "$templog" &
	fi
        # Get the PID of the tail command
        local pid_tail=$!
    fi

    echo "${action^} the service $service_name" >&2
    systemctl $action $service_name \
        || ( journalctl --lines=$length -u $service_name >&2 \
        ; test -n "$log_path" && echo "--" && tail --lines=$length "$log_path" >&2 \
        ; false )

    # Start the timeout and try to find line_match
    if [[ -n "${line_match:-}" ]]
    then
        local i=0
        for i in `seq 1 $timeout`
        do
            # Read the log until the sentence is found, that means the app finished to start. Or run until the timeout
            if grep --quiet "$line_match" "$templog"
            then
                echo "The service $service_name has correctly started." >&2
                break
            fi
            echo -n "." >&2
            sleep 1
        done
        if [ $i -eq $timeout ]
        then
            echo "The service $service_name didn't fully started before the timeout." >&2
            journalctl --lines=$length -u $service_name >&2
            test -n "$log_path" && echo "--" && tail --lines=$length "$log_path" >&2
        fi

        echo ""
        ynh_clean_check_starting
    fi
}

# Clean temporary process and file used by ynh_check_starting
# (usually used in ynh_clean_setup scripts)
#
# usage: ynh_clean_check_starting
ynh_clean_check_starting () {
	# Stop the execution of tail.
	kill -s 15 $pid_tail 2>&1
	ynh_secure_remove "$templog" 2>&1
}
