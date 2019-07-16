# Getting Started
The original master repo may be found at [https://github.com/paulwrightxyn/.xyncompress.git](https://github.com/paulwrightxyn/.xyncompress.git).


Add the .xyncompress folder to the docs or public folder.  
To install for jpg and png compression: 
```
bash install_xyn_compress.sh --jpg --png
```

To create webp files as well as jpg and png files:
```
bash install_xyn_compress.sh --jpg --png --webp
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

Flags are required to denote what kind of compression you wish to use. 
```
bash install_xyn_compress.sh /home/domains/example.com/public/imageDirectory/ --jpg --png --webp
```
This script will run recursively in /home/domains/example.com/public/imageDirectory/ and its 
subdirectories. It will run WebP compression, creating a .webp duplicate file. It will then 
run jpg compression and png compression, overwriting the original files with the compressed 
versions. It will then remove any WebP images that are not smaller than their PNG or JPG 
counterparts.
	
Note, it will not overwrite the existing crontab, but will append to it instead.

Runs compression before installing the crontab.  
Use `crontab -l` to verify if the crontab has been successfully updated.  
Use `crontab -e` to edit the crontab file (in your shell's default editor)

Creates an error log and a record of files compressed in .xynsystem (two log files)
	log file: `.xyncompress/imageCompression.log`
	error file: `.xyncompressimageCompression.log.err`

## Running the compression script manually

To run the compression on a different folder: 
```
bash xyncompress.sh /path/to/image/directory --options
```

Options: 
 
 --backups makes backups of each file before destructive, lossy compression overwrites the file
 
 --webp creates WebP images in the same directory, and then checks if the WebP image is larger than the same JPG (after compression, if any). If the WebP is larger, the --webp option will remove the webp image so that all webp files are smaller than the corresponding JPG.
 
 --jpg compress jpgs (which is a lossy, destructive action).
 
 --png compress pngs (which is a lossy, destructive action).

 --force forces the script to create versions of every file found, even if the file has not been updated since the last time this script ran.

 
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
  RewriteCond %{DOCUMENT_ROOT}/$1.webp -f
  RewriteRule (?i)(.*)(\.jpe?g|\.png)$ $1\.webp [L,T=image/webp,R]
</IfModule>

<IfModule mod_headers.c>
  Header append Vary Accept env=REDIRECT_accept
</IfModule>

AddType image/webp .webp
```

## Troubleshooting

If you are getting errors that files cannot be created or edited, make sure that the 
permissions on the filesystem are such that the script may edit files.

Also, check the error logs, which are in the .xyncompress folder. If you have any issues, 
please contact paul.wright@xynergy.com or submit an issue on the git repo:
[https://github.com/paulwrightxyn/.xyncompress.git](https://github.com/paulwrightxyn/.xyncompress.git)


