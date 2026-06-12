FROM iamdevopstrainer/tomcat:base
COPY /var/jenkins_home/workspace/first/target/ABCtechnologies-1.0.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]
