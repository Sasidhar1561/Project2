FROM maven:3.9.5-eclipse-temurin-17 AS build_image
RUN apt-get update && apt-get install -y git unzip vim && rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN git clone https://github.com/Sasidhar1561/Project2.git
WORKDIR /opt/Project2
RUN mvn clean package -DskipTests

FROM tomcat:10.1-jdk17-temurin
WORKDIR /usr/local/tomcat
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build_image /opt/jenkins/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]

