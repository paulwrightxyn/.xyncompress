#!/bin/env bash

# Define some names:

# compression script
compressscript=xyncompress.sh

# log file name
logfile=imageCompression.log

# function for writing errors
echoerr() { printf "%s\n" "$*" >&2; }

# get parent directory: the path to the folder in which to run compression 
parent_dir="$(dirname -- "$(readlink -f -- "$PWD")")"

# check if the filesystem is set up like Expression Engine, with images in /uploads/images,
# or like Magento, with images in /media, or like Wordpress, with images in /wp-content/uploads
#
# default expects expression engine file system:

if [ -d "${parent_dir}/uploads/images/" ]; then
	echo "Expression Engine file system structure detected"
	thedir="${parent_dir}/uploads/images/"
elif [ -d "${parent_dir}/media/" ]; then
	echo "Magento file system structure detected"
	thedir="${parent_dir}/media/"
elif [ -d "${parent_dir}/wp-content/uploads/" ]; then
	echo "Wordpress file system structure detected"
	thedir="${parent_dir}/wp-content/uploads/"
else
	echoerr ""
	echoerr "***  ERROR ***"
	echoerr "CMS file system not detected.  Make sure this script is being run from docs/.xyncompress/, or docs.dev/.xyncompress/"
	echoerr ""
	exit 1
fi



# write out current crontab - random number used to avoid collisions
tempfile=mycron$RANDOM;
echo "Checking for existing crontab";
crontab -l > ${tempfile};


# make sure our script exists and is executable
if [[ -x "${compressscript}" ]]; then
	echo "${compressscript} already exists and is executable"
else
	echo "${compressscript} does not exist, or is not executable. Making it executable. "
	chmod +x ${compressscript}
fi


# run the script to compress the files
echo "Running script to compress files before adding to crontab.  This may take a while. "
echo "${PWD}/${compressscript}  ${thedir} 2>> ${PWD}/${logfile}.err 1>> ${PWD}/${logfile}"
${PWD}/${compressscript}  ${thedir} 2>> ${PWD}/${logfile}.err 1>> ${PWD}/${logfile}

# echo new cron into cron file
echo "Adding new cron job for ${compressscript} - run every 2 hours in ${thedir}"
echo "0 */2 * * * ${PWD}/${compressscript}  ${thedir} 2>> ${PWD}/${logfile}.err 1>> ${PWD}/${logfile} " >> ${tempfile}


# install new cron file
crontab ${tempfile}
echo "crontab now contains: "
crontab -l
rm ${tempfile}
