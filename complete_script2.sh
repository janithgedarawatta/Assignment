#!/bin/bash

# Check /var/log/httpd for log files and copy them into tar file

ssh -tt ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "sudo tar -czf /tmp/http_logs_`date '+%F'`.tar.gz /var/log/httpd/"; 

if [ $? -eq 0 ]
then
        echo "Successfuly connected to remote host and created the compressed log folder"
else
        echo "Connection to remote host failed or compressing log folder failed"
fi

# Download the tar file to the location of the script

scp ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com:/tmp/http_logs_`date '+%F'`.tar.gz .

if [ $? -eq 0 ]
then
        echo "Successfuly copied the log folder to current working directory"
else
        echo "Copying log folder to the current working directory failed"
fi

# Upload tar file to the s3 bucket

aws s3 cp http_logs_`date '+%F'`.tar.gz s3://zip-upload-storage/ --acl public-read

if [ "$?" -eq "0" ];
then
# Delete the tar file from the script location if the upload is successful 
        echo "Successfuly uploaded to S3 Bucket"
        rm -rf http_logs_`date '+%F'`.tar.gz
else
# Send email to application support tema if upload failed
        echo "Upload failed to S3 Bucket"
		echo -e "to: gedarawatta.j@gmail.com\nsubject:Zip File Upload Failed\nhttp_logs_`date '+%F'`.tar.gz - file upload failed" | ssmtp gedarawatta.j@gmail.com
fi