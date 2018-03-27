# Getting Started

Add the .xyncompress folder to the docs/ folder.  
To install: 
	bash install_xyn_compress.sh
	
Must be run from docs/.xyncompress


Creates a cron job for that looks every 2 hours and compresses any new images found.
Based on file structure, it determines the CMS, and thus determines where to look for 
new files:
	EE: 		/uploads/images/
	Magento: 	/media/
	WordPress: 	/wp-content/uploads/
	
Note, it will not overwrite the existing crontab, but will append to it instead.

Runs compression before installing the crontab.  use crontab -l to verify if the crontab has been successfully updated.

Creates an error log and a record of files compressed in .xynsystem (two log files)

To run the compression on a different folder: 
	bash xyncompress.sh /path/to/image/directory

