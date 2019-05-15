#!/bin/env bash

# USAGE 
###########
#
## make sure script is executable:
# chmod +x xyncompress.sh 
#
# Requres a path, or it will exit.  Example:
# bash xyncompress.sh /path/to/image/directory
# --backups creates copies before lossy reduction
# --webp generates webp files in the same directory with the same filename
#
###########

# $1 = /path/to/images

# Fail if path is not defined

if [[ -z "$1" ]]; then
    echo "Must provide path to optimize" 1>&2
    exit 1
fi

doBackups=0;
doWebP=0;
doJpg=1;
doPng=1;
filepath=0;
doForce=0;
while test $# -gt 0
do
    case "$1" in
        --backups) echo "Backups enabled. ";
          doBackups=1;
            ;;
        --webp) echo "WebP enabled. ";
          doWebP=1;
            ;;
        --no-jpg) echo "JPG disabled";
          doJpg=0;
            ;;
        --no-png) echo "PNG disabled";
          doPng=0;
            ;;
        --force) echo "Force even if optimized record exists";
          doForce=1;
            ;;
        --*) echo "bad option $1";
          echo "Available options:";
          echo "--backups make backups in .opt/backup folder";
          echo "--webp make WebP images";
          echo "--no-jpg do not compress jpg files (default is to compress). Compression is lossy and will overwrite original files!";
          echo "--no-png do not compress png files (default is to compress). Compression is lossy and will overwrite original files!";
          echo "--force force compression of all files even if they have not been updated."
          exit 1;
            ;;
        *) filepath="$1";
          echo "Compressing all uncompressed images found in $filepath based on the settings provided.";
            ;;
    esac
    shift
done


# Iterate through files 
for f in $(find ${filepath} -not -path '*.opt*' \( -iname '*.jpg' -or -iname '*.jpeg' -or -iname '*.png' \) ); do 
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
    webpFileName="$(sed 's/\.[^.]*$/.webp/' <<< "${f}")"; 
         
    # Get the full optFileName path 
    optFullPath="${dir}.opt/${optFileName}"; 
    
    # Get backup file path
    backupFilePath_JPG="${dir}.opt/backup/"$(sed 's/\.[^.]*$/.bak.jpg/' <<< $(basename "${f}"));
    backupFilePath_PNG="${dir}.opt/backup/"$(sed 's/\.[^.]*$/.bak.png/' <<< $(basename "${f}"));
     
    # Set last opt time 
    lastOptTime=0; 
     
    # Check if a file for optimization time exists 
    if [ -f "${optFullPath}" ]; then 
         lastOptTime="$(date -r ${optFullPath} +%s)"; 
    fi; 
     
    # Check if last opt time is less than last mod time 
    if (( lastOptTime < fileMod )) || [ $doForce = 1 ]; then 
    
    	if [[ ${f} =~ .*\.[jJ][pP][eE]?[gG]$ ]]; then
	        # Mention optimization 
	        echo "Optimizing file. Source image: JPG ${f}";  
	        
	        # If backups flag was set, then make a backup
	        if [ $doBackups = 1 ]; then
  	        echo "Making backup: ${backupFilePath_JPG}";
  	        cp ${f} $backupFilePath_JPG;
	        fi
	        
	        # Create webP file
	        if [ $doWebP = 1 ]; then
  	        echo "  Create ${webpFileName}";
            /usr/bin/convert ${f} ${webpFileName}
          fi
	         
	        # Run jpg optimization 
	        if [ $doJpg = 1 ]; then
	          echo "  Compressing jpg";
  	        /usr/bin/convert ${f} -sampling-factor 4:2:0 -strip -quality 80 -interlace JPEG ${f}; 
	        fi
	        
	        # Compare file sizes, and remove WebP if it's not smaller
	        webpSize=`wc -c ${webpFileName} | cut -d' ' -f1`;
	        jpgSize=`wc -c ${f} | cut -d' ' -f1`;
	        if [ "$webpSize" -gt "$jpgSize" ]; then
	          echo "  Removing WebP file because it is larger: ${webpSize} > ${jpgSize}";
	          rm "${webpFileName}";
	        fi
	        
	        # Create the last opt time file 
	        touch ${optFullPath}; 
        fi
        if [[ ${f} =~ .*\.[pP][nN][gG]$ ]]; then
	        # Mention optimization 
	        echo "Optimizing file. Source image: PNG ${f}"; 
	        
	        if [ $doBackups = 1 ]; then
  	        echo "Making backup: ${backupFilePath_PNG}";
  	        cp ${f} $backupFilePath_PNG;
          fi
	         
	        # Create webP file
	        if [ $doWebP = 1 ]; then
            echo "  Create ${webpFileName}"
  	        /usr/bin/convert ${f} -quality 100 -strip -define webp:lossless=true -define webp:method=6 ${webpFileName}    
          fi
	         
	        # Run PNG optimization 
	        if [ $doPng = 1 ]; then
  	        echo "  Compressing png"
  	        /usr/bin/convert ${f} -quality 82 -strip -define png:compression-level=9 -define png:compression-filter=5 -define png:compression-strategy=1 -define png:exclude-chunk=all -interlace none ${f};
	        fi
	        # optipng might work better, but it is not installed on older servers
	        
	        # Compare file sizes, and remove WebP if it's not smaller
	        webpSize=`wc -c ${webpFileName} | cut -d' ' -f1`;
	        pngSize=`wc -c ${f} | cut -d' ' -f1`;
	        if [ "$webpSize" -gt "$pngSize" ]; then
	          echo "  Removing WebP file because it is larger: ${webpSize} > ${pngSize}";
	          rm "${webpFileName}";
	        fi

	        
	        # Create the last opt time file 
	        touch ${optFullPath}; 
        fi
    fi 
done;

compresstime="$(date '+%Y-%m-%d %H:%M:%S')"
echo
echo "###################################################"
echo "Finished compressing ${filepath} at ${compresstime}" 
echo "###################################################"
echo
