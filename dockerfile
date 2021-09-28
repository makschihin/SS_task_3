FROM openjdk:latest
RUN mkdir /opt/tests/
WORKDIR /opt/tests/
COPY target/spring-petclinic-*.jar sp-petclinic.jar
ENTRYPOINT ["java", "-jar", "sp-petclinic.jar.jar"]
EXPOSE 8080