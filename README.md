# Getting Started

Add the .xyncompress folder to the docs/ folder.  
To install: 
```
bash install_xyn_compress.sh
```
	
Must be run from `docs/.xyncompress`


Creates a cron job for that looks every 2 hours and compresses any new images found.
Based on file structure, it determines the CMS, and thus determines where to look for 
new files:
	EE: 		`/uploads/images/`
	Magento: 	`/media/`
	WordPress: 	`/wp-content/uploads/`
	
Alternately, takes a single directory as an argument, and sets the crontab to execute
the script every 2 hours in that directory.  May be run multiple times to target 
multiple locations.
```
bash install_xyn_compress.sh /home/domains/example.com/docs/imageDirectory/
```
	
Note, it will not overwrite the existing crontab, but will append to it instead.

Runs compression before installing the crontab.  
Use `crontab -l` to verify if the crontab has been successfully updated.  
Use `crontab -e` to edit the crontab file (in your shell's default editor)

Creates an error log and a record of files compressed in .xynsystem (two log files)
	log file: `.xyncompress/imageCompression.log`
	error file: `.xyncompressimageCompression.log.err`

To run the compression on a different folder: 
```
bash xyncompress.sh /path/to/image/directory
```

To run the compression and create backups of the files (file compression is lossy and 
will overwrite the full sized image files).
```
bash xyncompress.sh /path/to/image/directory --backups
```

