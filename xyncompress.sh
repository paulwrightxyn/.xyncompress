#!/bin/env bash

# USAGE 
###########
#
## make sure script is executable:
# chmod +x xyncompress.sh 
#
# Requres a path, or it will exit.  Example:
# bash xyncompress.sh /path/to/image/directory
#
###########

# $1 = /path/to/images

# Fail if path is not defined

if [[ -z "$1" ]]; then
    echo "Must provide path to optimize" 1>&2
    exit 1
fi

# Iterate through files 
for f in $(find ${1} -name '*.jpg' -o -name '*.jpeg' -o -name '*.JPG' -o -name '*.JPEG' -o -name '*.png' -o -name '*.PNG' -o -name '*.Png'); do 
	# Get the last mod date of the file 
    fileMod=$(date -r ${f} +%s); 
     
    # Get the directory 
    dir=$(dirname "${f}")"/";
    # echo "directory of file is ${dir}";
    # echo "opt directory is ${dir}.opt";
    mkdir -p "$dir.opt";
     
    # Get opt filename 
    optFileName=$(basename "${f}")".opt"; 
     
    # Get the full optFileName path 
    optFullPath="${dir}.opt/${optFileName}"; 
     
    # Set last opt time 
    lastOptTime=0; 
     
    # Check if a file for optimization time exists 
    if [ -f "${optFullPath}" ]; then 
         lastOptTime=$(date -r ${optFullPath} +%s); 
    fi; 
     
    # Check if last opt time is less than last mod time 
    if (( lastOptTime < fileMod )); then 
    
    	if [[ ${f} =~ .*\.[jJ][pP][eE]?[gG]$ ]]; then
	        # Mention optimization 
	        echo "Optimizing JPG: ${f}"; 
	         
	        # Run optimization 
	        /usr/bin/convert ${f} -sampling-factor 4:2:0 -strip -quality 70 -interlace JPEG ${f}; 
	         
	        # Create the last opt time file 
	        touch ${optFullPath}; 
        fi
        if [[ ${f} =~ .*\.[pP][nN][gG]$ ]]; then
	        # Mention optimization 
	        echo "Optimizing PNG: ${f}"; 
	         
	        # Run optimization 
	        /usr/bin/convert ${f} -quality 82 -strip -define png:compression-level=9 -define png:compression-filter=5 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none ${f};
	        # optipng might work better, but it is not installed on older servers
	        
	         
	        # Create the last opt time file 
	        touch ${optFullPath}; 
        fi
    fi 
done;

compresstime="$(date '+%Y-%m-%d %H:%M:%S')"
echo
echo "###################################################"
echo "Finished compressing $1 at ${compresstime}" 
echo "###################################################"
echo
