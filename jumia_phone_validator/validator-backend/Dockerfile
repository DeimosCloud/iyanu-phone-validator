FROM openjdk:8-jdk-alpine
WORKDIR /usr/src/app

COPY target/validator-0.0.1.jar backend-validator-0.0.1.jar
ENTRYPOINT ["java","-jar","/backend-validator-0.0.1.jar"]