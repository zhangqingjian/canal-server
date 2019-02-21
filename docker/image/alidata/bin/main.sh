#!/bin/bash

[ -n "${DOCKER_DEPLOY_TYPE}" ] || DOCKER_DEPLOY_TYPE="VM"
echo "DOCKER_DEPLOY_TYPE=${DOCKER_DEPLOY_TYPE}"

#set -e
#used for HA model,canal.id should be different in  each instance
if [ -n "$CANAL_ID" ] ; then  
sed -i "s|CANAL_ID=.*$|canal.id=${CANAL_ID}|g"  home/admin/canal-server/conf/canal.properties
fi
# set zkServers when docker run commond execute
if [ -n "$ZOOKEEPER_SERVER" ] ; then  
sed -i "s|ZOOKEEPER_SERVER=.*$|canal.zkServers=${ZOOKEEPER_SERVER}|g"  home/admin/canal-server/conf/canal.properties
fi

# run init scripts
for e in $(ls /alidata/init/*) ; do
	[ -x "${e}" ] || continue
	echo "==> INIT $e"
	$e
	echo "==> EXIT CODE: $?"
done

echo "==> INIT DEFAULT"
service sshd start
service crond start

#echo "check hostname -i: `hostname -i`"
#hti_num=`hostname -i|awk '{print NF}'`
#if [ $hti_num -gt 1 ];then
#    echo "hostname -i result error:`hostname -i`"
#    exit 120
#fi

echo "==> INIT DONE"
echo "==> RUN ${*}"
exec "${@}"