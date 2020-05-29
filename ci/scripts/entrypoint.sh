#!/bin/sh

cd /usr/local/tomcat/ || exit 1

#start tomcat
export JAVA_OPTS=""
/usr/local/tomcat/bin/catalina.sh run
