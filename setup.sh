#!/bin/bash

##  +-----------------------------------+-----------------------------------+
##  |                                                                       |
##  | Copyright (c) 2019, Andres Gongora <mail@andresgongora.com>.          |
##  |                                                                       |
##  | This program is free software: you can redistribute it and/or modify  |
##  | it under the terms of the GNU General Public License as published by  |
##  | the Free Software Foundation, either version 3 of the License, or     |
##  | (at your option) any later version.                                   |
##  |                                                                       |
##  | This program is distributed in the hope that it will be useful,       |
##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##  | GNU General Public License for more details.                          |
##  |                                                                       |
##  | You should have received a copy of the GNU General Public License     |
##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##  |                                                                       |
##  +-----------------------------------------------------------------------+

##
##	QUICK INSTALLER
##
##	This script will install these scripts to /usr/bin/locale and will
##	apply status.sh and fancy-bash-prompt.sh systemwide.
##	THIS IS WORK IN PROGRESS
##




##==============================================================================
##	FUNCTIONS
##==============================================================================


##------------------------------------------------------------------------------
##
##	INSTALL SCRIPT
##	This function installs a generic script to the system. It copies the
##	script to INSTALL_DIR, and also adds to it all the dependencies from
##	common to make the script completely self contained. Also, this
##	function copies all configuration files to CONFIG_DIR
##
##	ARGUMENTS
##	1. Name of script. (e.g. "status" or "fancy-bash-prompt")
##
installScript()
{
	## ARGUMENTS
	local operation=$1
	local script_name=$2	



	## EXTERNAL VARIABLES
	if [ -z $INSTALL_DIR ]; then echo "INSTALL_DIR not set"; exit 1; fi
	if [ -z $BASHRC ];      then echo "BASHRC not set";      exit 1; fi
	if [ -z $CONFIG_DIR ];  then echo "CONFIG_DIR not set";  exit 1; fi



	## LOCAL VARIABLES
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	local script="${INSTALL_DIR}/${script_name}.sh"
	local source_script="${dir}/synth-shell/${script_name}.sh"
	local config_template_dir="${dir}/config_templates"
	local uninstaller="${INSTALL_DIR}/uninstall.sh"
	local edit_text_file_script="$dir/bash-tools/bash-tools/edit_text_file.sh"
	source "$edit_text_file_script"



	## TEXT FRAGMENTS
	local hook=$(printf '%s'\
	"\n"\
	"##-----------------------------------------------------\n"\
	"## ${script_name}\n"\
	"## Added by synth-shell\n"\
	"## https://github.com/andresgongora/synth-shell/\n"\
	"if [ -f ${script} ]; then\n"\
	"\tsource ${script}\n"\
	"fi")

	local script_header=$(printf '%s'\
	"##!/bin/bash\n"\
	"\n"\
	"##  +-----------------------------------+-----------------------------------+\n"\
	"##  |                                                                       |\n"\
	"##  | Copyright (c) 2014-2019, https://github.com/andresgongora/synth-shell |\n"\
	"##  | Visit the above URL for details opn license and authorship            |\n"\
	"##  |                                                                       |\n"\
	"##  | This program is free software: you can redistribute it and/or modify  |\n"\
	"##  | it under the terms of the GNU General Public License as published by  |\n"\
	"##  | the Free Software Foundation, either version 3 of the License, or     |\n"\
	"##  | (at your option) any later version.                                   |\n"\
	"##  |                                                                       |\n"\
	"##  | This program is distributed in the hope that it will be useful,       |\n"\
	"##  | but WITHOUT ANY WARRANTY; without even the implied warranty of        |\n"\
	"##  | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |\n"\
	"##  | GNU General Public License for more details.                          |\n"\
	"##  |                                                                       |\n"\
	"##  | You should have received a copy of the GNU General Public License     |\n"\
	"##  | along with this program. If not, see <http://www.gnu.org/licenses/>.  |\n"\
	"##  |                                                                       |\n"\
	"##  +-----------------------------------------------------------------------+\n"\
	"##\n"\
	"##\n"\
	"##  =======================\n"\
	"##  WARNING!!\n"\
	"##  DO NOT EDIT THIS FILE!!\n"\
	"##  =======================\n"\
	"##\n"\
	"##  This file was generated by an installation script.\n"\
	"##  If you edit this file, it might be overwritten without warning\n"\
	"##  and you will lose all your changes.\n"\
	"##\n"\
	"##  Visit for instructions and more information:\n"\
	"##  https://github.com/andresgongora/synth-shell/ for instructions\n"\
	"##\n\n\n")


	
	## INSTALL/UNINSTALL
	case "$operation" in

	uninstall)
		## REMOVE HOOK AND SCRIPT
		printInfo "Removed $script_name hook from $BASHRC"
		editTextFile "$BASHRC" delete "$hook"
		if [ -f $script ]; then rm $script; fi
		;;


	install)

		## CHECK THAT INSTALL DIR EXISTS
		if [ ! -d $INSTALL_DIR ]; then
			printInfo "Creating directory $INSTALL_DIR"
			mkdir -p $INSTALL_DIR
		fi



		## CREATE EMPTY SCRIPT FILE	
		printInfo "Creating file $script"
		if [ -f $script ]; then
			rm $script
		fi
		touch "$script" || exit 1
		chmod 755 "$script"
		echo -e "${script_header}" >> ${script}



		## ADD CONTENT TO SCRIPT FILE
		## - Add common scripts TODO: Make this configurable	
		## - Add actual script
		## - Remove common functions from environment
		cat "${dir}/bash-tools/bash-tools/load_config.sh" |\
			sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
		cat "${dir}/bash-tools/bash-tools/color.sh" |\
			sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
		cat "${dir}/bash-tools/bash-tools/shorten_path.sh" |\
			sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
		cat "${dir}/bash-tools/bash-tools/print_utils.sh" |\
			sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
		cat "$source_script" |\
			sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$script"
		#echo "unset loadConfigFile" >> "$script"
		#echo "unset getFormatCode" >> "$script"



		## ADD HOOK TO /etc/bash.bashrc
		printInfo "Adding $script_name hook to $BASHRC"
		editTextFile "$BASHRC" append "$hook"



		## COPY CONFIGURATION FILES
		## - Create system config folder if there is none
		## - Check if there is already some configuration in place
		##   - If none, copy current configuration
		##   - If there is, but different, copy with .new extension
		## - Copy all examples files (overwrite old examples)
		printInfo "Adding config files to $CONFIG_DIR"
		local sys_conf_file="${CONFIG_DIR}/${script_name}.config"
		local conf_example_dir="${config_template_dir}/${script_name}.config.examples"
		local conf_template="${config_template_dir}/${script_name}.config"

		if [ ! -d $CONFIG_DIR ]; then
			mkdir -p $CONFIG_DIR
		fi
	
		if [ ! -f "$sys_conf_file" ]; then
			cp -u "${conf_template}" "${sys_conf_file}"
		elif ( ! cmp -s "$conf_template" "$sys_conf_file" ); then
			cp -u "${conf_template}" "${sys_conf_file}.new"
			printf "Old configuration file detected. New configuration file written to ${sys_conf_file}.new\n"
		fi

		cp -ur "$conf_example_dir" "${CONFIG_DIR}/"



		## ADD QUICK-UNINSTALLER
		printInfo "Adding quick uninstaller as $uninstaller"
		editTextFile "$uninstaller" append "$script_header"
		cat "$edit_text_file_script" |\
			sed 's/^#.*$//g;s/[ \t][ \t]*#.*$//g;/^[ \t]*$/d' >> "$uninstaller"
		editTextFile "$uninstaller" append "rm -rf ${CONFIG_DIR}"
		echo "hook=\"$hook\"" >> "$uninstaller"
		echo "editTextFile \"$BASHRC\" delete \"\$hook\"" >> "$uninstaller"
		echo "unset hook" >> "$uninstaller"
		chmod +x "$uninstaller"


		printSuccess "Script $script_name succesfully installed"
		;;



	*)
		echo $"Usage: $0 {install|uninstall}"
            	exit 1
		;;

	esac
}



##------------------------------------------------------------------------------
##
installAll()
{
	local action=$(promptUser "Install status? (Y/n)" "" "yYnN" "y")
	case "$action" in
		""|y|Y )	installScript install "status" 
				;;
		*)		echo ""
	esac


	local action=$(promptUser "Install fancy-bash-prompt? (Y/n)" "" "yYnN" "y")
	case "$action" in
		""|y|Y )	installScript install "fancy-bash-prompt" 
				;;
		*)		echo ""
	esac
}



##------------------------------------------------------------------------------
##
uninstallAll()
{
	## CHECK IF QUICK-UNINSTALL FILE EXISTS
	local uninstaller="${INSTALL_DIR}/uninstall.sh"
	if [ -f "$uninstaller" ]; then
		## RUN QUICK-UNINSTALLER
		"$uninstaller"	
	else
		installScript uninstall "status"
		installScript uninstall "fancy-bash-prompt"
	fi
}



##==============================================================================
##	MAIN
##==============================================================================

##------------------------------------------------------------------------------
##
installerSystem()
{
	local option=$1
	local INSTALL_DIR="/usr/local/bin" 
	local CONFIG_DIR="/etc/synth-shell"
	local BASHRC="/etc/bash.bashrc"

	if [ $(id -u) -ne 0 ]; then 
		printError "Please run as root"
		exit
	fi

	printInfo "Running systemwide"

	case "$option" in
		uninstall)	printInfo "Uninstalling synth-shell"
				uninstallAll
				printSuccess "synth-shell was uninstalled"
				;;
		""|install)	printInfo "Installing synth-shell"
				installAll
				printSuccess "synth-shell was installed"
				;;
		*)		echo "Usage: $0 {install|uninstall}" & exit 1
	esac
}




##------------------------------------------------------------------------------
##
installerUser()
{
	local option=$1
	local INSTALL_DIR="${HOME}/.config/synth-shell" 
	local CONFIG_DIR="${HOME}/.config/synth-shell" 
	local BASHRC="${HOME}/.bashrc" 

	printInfo "Running for user $USER"

	case "$option" in
		uninstall)	printInfo "Uninstalling synth-shell"
				uninstallAll
				printSuccess "synth-shell was uninstalled"
				;;
		""|install)	printInfo "Installing synth-shell"
				installAll
				printSuccess "synth-shell was installed"
				;;
		*)		echo "Usage: $0 {install|uninstall}" & exit 1
	esac
}





##------------------------------------------------------------------------------
##
##	PROMPT USER FOR INSTALLATION OPTIONS
##
##	USER INSTALL ONLY:	Will all code to user's home dir
##	                  	and add hooks to its own bashrc file.
##	SYSTEM WIDE INSTALL:	Will add code to system and hooks to
##	                    	/etc/bash.bashrc file.
##
promptUser()
{
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	source "$dir/bash-tools/bash-tools/user_io.sh"
	printHeader "Installation wizard for synth-shell"

	
	
	local action=$(promptUser "Would you like to install or uninstall synth-shell?" "[i] install / [u] uninstall. Default i" "iIuU" "i")
	case "$action" in
		""|i|I )	local install_option="install" ;;
		u|U )		local install_option="uninstall" ;;
		*)		printError "Invalid option"; exit 1
	esac



	local action=$(promptUser "Would you like to install it for your current user only (recommended),\n\tor system wide (requires elevated privileges)?" "[u] current user only / [s] system wide install. Default u" "uUsS" "u")
	case "$action" in
		""|u|U )	installerUser   $install_option ;;
		s|S )		sudo bash -c "bash $0 $install_option" ;;
		*)		printError "Invalid option"; exit 1
	esac
}




##------------------------------------------------------------------------------
##
installer()
{
	case "$1" in
		install|uninstall)	installerSystem "$1";;
		*)			promptUser ;;
	esac
}


installer $1



