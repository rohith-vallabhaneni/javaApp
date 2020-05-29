#!/bin/sh

mkdir -p ${HOME}/dist || exit $?

mvn clean install

find -name *.war | xargs -I {} cp {} ${HOME}/dist/webapp.war

echo ${HOME}

sleep 30
