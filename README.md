# Getting Started
The original master repo may be found at [https://github.com/paulwrightxyn/.xyncompress.git](https://github.com/paulwrightxyn/.xyncompress.git).


Add the .xyncompress folder to the docs/ folder.  
To install: 
```
bash install_xyn_compress.sh
```
	
Must be run from `docs/.xyncompress`


Creates a cron job for that looks every 2 hours and compresses any new images found.
Note that this is lossy compression. See instructions below to create backups of 
the uncompressed imgages.

Based on file structure, it determines the CMS, and thus determines where to look for 
new files:
Expression Engine: 		`root-of-site/uploads/images/`
Magento: 	`root-of-site/media/`
WordPress: 	`root-of-site/wp-content/uploads/`
	
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

## Running the script manually

To run the compression on a different folder: 
```
bash xyncompress.sh /path/to/image/directory
```

### Creating backups
To run the compression and create backups of the files (file compression is lossy and 
will overwrite the full sized image files).
```
bash xyncompress.sh /path/to/image/directory --backups
```

## Serving WebP images 
The compression script will create WebP versions of all images by default. In order 
to serve these images to browsers that support them without having to change 
front-end code, we can add a few lines to the .htaccess file:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On 
  RewriteCond %{HTTP_ACCEPT} image/webp
  RewriteCond %{REQUEST_URI}  (?i)(.*)(\.jpe?g|\.png)$ 
  RewriteCond %{DOCUMENT_ROOT}%1.webp -f
  RewriteRule (?i)(.*)(\.jpe?g|\.png)$ %1\.webp [L,T=image/webp,R] 
</IfModule>

<IfModule mod_headers.c>
  Header append Vary Accept env=REDIRECT_accept
</IfModule>

AddType image/webp .webp
```

