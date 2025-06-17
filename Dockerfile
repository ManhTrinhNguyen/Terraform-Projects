FROM amazoncorretto:8-alpine3.19-jre 

EXPOSE 8080

COPY ./target/java-maven-app-*.jar /usr/app/app.jar

WORKDIR /usr/app

CMD [ "java", "-jar", "app.jar"]
