FROM maven:3.9.5-eclipse-temurin-17 AS build_image
RUN apt update && apt install git unzip vim -y
WORKDIR /opt
RUN git clone https://github.com/Sasidhar1561/Project2.git
RUN cd jenkins && mvn clean package

FROM tomcat:10.1-jdk17-temurin
WORKDIR /usr/local/tomcat
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build_image /opt/jenkins/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]

