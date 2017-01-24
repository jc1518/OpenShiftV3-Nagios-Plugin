#!/bin/bash
# Monitor Openshift V3 persisent storage usage

project=$1
your_token=thisisyourtokenpleasekeepitsecure

if [ -z $1 ]; then
        echo "Project name is required"
        exit 3
fi

export KUBECONFIG=/usr/local/nagios/libexec/kubeconfig
message_text="Disk Usage:"
message_exit=0

date > /tmp/ospv.log
/usr/bin/oc login https://api.newscorpau01.openshift.com --token=$your_token >> /tmp/ospv.log 2>&1
/usr/bin/oc project $project >> /tmp/ospv.log 2>&1
pods=$(/usr/bin/oc get pods | grep -v -e build -e NAME | awk '{print $1}')
for pod in $pods
do
                volumes=$(/usr/bin/oc volume pod/$pod | grep 'mounted at' | grep -v 'kubernetes.io' | awk '{print $3}')
                for volume in $volumes
                do
                        usage=$(/usr/bin/oc exec $pod -- df -h $volume | awk '{print $5}' | tail -1 | cut -d'%' -f1)
                        if [ $usage -gt 80 ] && [ $usage -lt 90 ]; then
                                message_temp_exit=1
                                message_temp_text="Warning - $volume is $usage% full!"
                        elif [ $usage -ge 90 ]; then
                                message_temp_exit=100
                                message_temp_text="Critical - $volume is $usage% full!"
                        else
                                message_temp_exit=0
                                message_temp_text="OK - $volume is $usage% full."
                        fi
                        let message_exit=${message_exit}+${message_temp_exit}
                        message_text=${message_text}' '${message_temp_text}
                done
done

echo "$message_text"
if [ $message_exit -ge 100 ]; then
        exit 2
elif [ $message_exit -ge 1 ]; then
        exit 1
elif [[ $(echo $message_text | grep -c full) -lt 1 ]]; then
        exit 3
else
        exit 0
fi
