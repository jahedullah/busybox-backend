FROM openjdk:17
EXPOSE 8080
ADD target/busybox-backend-0.0.1-SNAPSHOT.jar busybox-backend.jar
ENTRYPOINT ["java", "-jar","/busybox-backend.jar"]