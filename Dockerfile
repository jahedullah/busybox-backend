FROM openjdk:22
EXPOSE 8080
ADD target/busybox-frontend.jar busybox-backend.jar
ENTRYPOINT ["java", "-jar","/busybox-backend.jar"]