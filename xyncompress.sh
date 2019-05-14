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

doBackups=0;
if [ "$2" = "--backups" ]; then
  echo "Backups enabled. ";
  doBackups=1;
fi

# Iterate through files 
for f in $(find ${1} -not -path '*.opt*' \( -iname '*.jpg' -or -iname '*.jpeg' -or -iname '*.png' \) ); do 
	# Get the last mod date of the file 
    fileMod=$(date -r ${f} +%s); 
     
    # Get the directory 
    dir=$(dirname "${f}")"/";
    # echo "directory of file is ${dir}";
    # echo "opt directory is ${dir}.opt";
    mkdir -p "$dir.opt";
    mkdir -p "$dir.opt/backup";
    
    # get base filename without extension
    baseFileName=$(basename "${f}"); 
     
    # Get opt filename 
    optFileName=$(basename "${f}")".opt";
    
    # Get webp filename 
    webpFileName=$(sed 's/\.[^.]*$/.webp/' <<< "${f}"); 
         
    # Get the full optFileName path 
    optFullPath="${dir}.opt/${optFileName}"; 
    
    # Get backup file path
    backupFilePath_JPG="${dir}.opt/backup/"$(sed 's/\.[^.]*$/.bak.jpg/' <<< "${f}");
    backupFilePath_PNG="${dir}.opt/backup/"$(sed 's/\.[^.]*$/.bak.png/' <<< "${f}");
     
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
	        
	        if [ $doBackups = 1 ]; then
  	        echo "Making backup of ${backupFilePath_JPG}";
  	        cp ${f} $backupFilePath_JPG;
	        fi
	        
	        # Create webP file
	        echo "create ${webpFileName}"
	        /usr/bin/convert ${f} -quality 50 -strip -define webp:lossless=false -define webp:method=6 ${webpFileName}
	         
	        # Run optimization 
	        /usr/bin/convert ${f} -sampling-factor 4:2:0 -strip -quality 70 -interlace JPEG ${f}; 
	         
	        # Create the last opt time file 
	        touch ${optFullPath}; 
        fi
        if [[ ${f} =~ .*\.[pP][nN][gG]$ ]]; then
	        # Mention optimization 
	        echo "Optimizing PNG: ${f}"; 
	        
	        if [ $doBackups = 1 ]; then
  	        echo "Making backup of ${backupFilePath_PNG}";
  	        cp ${f} $backupFilePath_PNG;
          fi
	         
	        # Create webP file
	        echo "create ${webpFileName}"
	        /usr/bin/convert ${f} -quality 95  -strip -define webp:lossless=true -define webp:alpha-compression=1 -define webp:emulate-jpeg-size=true -define webp:method=6 -define webp:auto-filtering=true ${webpFileName}    
	         
	        # Run PNG optimization 
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
