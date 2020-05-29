FROM tomcat:9

LABEL maintainer="rohith.vallabhaneni"

# Clean out tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

COPY ./webapp.war /usr/local/tomcat/webapps/ROOT.war

# Copy Tomcat config
COPY ci/tomcat/conf/ /usr/local/tomcat/conf/
COPY ci/tomcat/lib/ /usr/local/tomcat/lib/

# Set permissions for the unprivileged user
RUN chown -R nobody:nogroup /usr/local/tomcat

# copy the entrypoint script
COPY ci/scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9090

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD curl --fail http://localhost:9090/ || exit 1
