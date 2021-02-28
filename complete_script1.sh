#!/bin/bash

#SSH to the EC2 instance and check if the http server is running
count=$(ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "ps -ef | grep -c httpd")
status1="HTTP Service is Running"
status2="HTTP Service is not Running"
dt=$(date '+%F %T')

#Returns 2 if the server is down
if [ "$count" -gt 2 ]
then
	echo $status1
	globalstatus="HTTP Service is Running"
# Returns a non 0 value if an error occured		
		if [ $? -ne 0 ]
		then
# Send an email to Application Support Team with the error
			echo -e "to: gedarawatta.j@gmail.com\nsubject:Log Upload failed\nLog files upload failed to DynamoDB" | ssmtp gedarawatta.j@gmail.com
		fi
else
	echo $status2
	globalstatus="HTTP Service is not Running"
	echo "HTTP Service is starting..."
#Start the web server if it is not running already
	ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "sudo systemctl start httpd"
	echo "HTTP Service has now started"
		
		if [ $? -ne 0 ]
		then
			echo -e "to: gedarawatta.j@gmail.com\nsubject:Log Upload failed\nLog files upload failed to DynamoDB" | ssmtp gedarawatta.j@gmail.com
		fi
fi


#Check the return code of the http server
STATUS=$(ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "curl -I http://localhost 2>/dev/null | head -n 1 | grep 200 | wc -l")

#Returns 1 as the word count if the server returns 200 code
if [ "$STATUS" -eq 1 ]
then
	cod1=$(ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "curl -I http://localhost 2>/dev/null | head -n 1")
	echo $cod1
	
# Insert log into dynamodb
	aws dynamodb put-item \
	--table-name script_log  \
	--item \
		'{"time_stamp": {"S": "'"$dt"'"}, "result": {"S": "'"$globalstatus"'"}, "200_result": {"S": "HTTP/1.1 200 OK"}}' 
		
#Send email to application support team if data insert is not successful
		if [ $? -ne 0 ]
		then
			echo -e "to: gedarawatta.j@gmail.com\nsubject:Log Upload failed\nLog files upload failed to DynamoDB" | ssmtp gedarawatta.j@gmail.com
		fi

	
else 
	cod2="HTTP Error ! " $(ssh ec2-user@ec2-18-141-187-175.ap-southeast-1.compute.amazonaws.com "curl -I http://localhost 2>/dev/null | head -n 1")
	echo $cod2

# Insert log into dynamodb
	aws dynamodb put-item \
	--table-name script_log  \
	--item \
		'{"time_stamp": {"S": "'"$dt"'"}, "result": {"S": "'"$globalstatus"'"}, "200_result": {"S": "HTTP Error"}}' 
		
#Send email to application support team if data insert is not successful
		if [ $? -ne 0 ]
		then
			echo -e "to: gedarawatta.j@gmail.com\nsubject:Log Upload failed\nLog files upload failed to DynamoDB" | ssmtp gedarawatta.j@gmail.com
		fi
fi















