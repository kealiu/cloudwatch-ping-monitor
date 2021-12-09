#!/bin/bash -x

# SSM Parameter Store config smaple
#TARGETIPS=172.31.36.54,52.83.24.131,172.31.36.110
#NAMESPACE=DXPingMonitor
#METRICNAME=OK
#TIMEOUTSEC=0.005
#INTERVAL=1

# for use watch, export all these values as envvar
SSHPMSTORE=PingMintorConfig

for values in $(aws ssm get-parameter --name ${SSHPMSTORE} | jq -r ".Parameter.Value")
do
    export $values
done

function cloudwatchPutMetric() {
    aws cloudwatch put-metric-data --metric-name ${METRICNAME} --namespace ${NAMESPACE} --unit None --value $2 --dimensions TargetIP=$1,InstanceIP=${INSTANCEIP} --storage-resolution 1
}

function cloudwatchOneIPping() {
    timeout ${TIMEOUTSEC} ping -n -c 1 $1 2>&1 > /dev/null
    if [ $? -eq 0 ] ; then
        cloudwatchPutMetric $1 1
    else
	cloudwatchPutMetric $1 0
    fi
}

export -f cloudwatchPutMetric
export -f cloudwatchOneIPping

for targetip in $(echo $TARGETIPS | sed 's/,/ /g')
do
    nohup watch -n ${INTERVAL} -x bash -c "cloudwatchOneIPping ${targetip}" 2>&1 > /dev/null & 
done
