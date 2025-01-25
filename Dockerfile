FROM tomcat:latest
COPY target/*.war /usr/local/tomcat/webapps/rbc-webapp.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
