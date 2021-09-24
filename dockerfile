FROM openjdk:latest
RUN mkdir /opt/tests/
WORKDIR /opt/tests/
COPY /target/spring-petclinic-2.5.0-SNAPSHOT.jar .
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.5.0-SNAPSHOT.jar"]
EXPOSE 8080