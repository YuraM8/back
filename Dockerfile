# Stage 1: Build the project with Maven

FROM maven:3.6.3-openjdk-17 AS build

# work dir

WORKDIR /app

# copy the Maven settings file and the project files to start the build

COPY pom.xml .

# cache dependencies so that we don't have to load them every time

RUN mvn dependency:go-offline

# copi all progect

COPY . .

# buld progect with Maven

RUN mvn clean package -DskipTests

# Stage 2: Run the built application with a lighter JDK image

FROM openjdk:17-jdk-slim

# work dir

WORKDIR /app

# copy the collected file from the previous stage

COPY --from=build /app/target/*.war /app/dev.war

ENV JDBC_DRIVER=${JDBC_DRIVER:-org.mariadb.jdbc.Driver} \
    DATASOURCE_URL=${DATASOURCE_URL:-jdbc:mariadb://127.0.0.1:3306/teachua} \
    DATASOURCE_USER=${DATASOURCE_USER:-your_db_user} \
    DATASOURCE_PASSWORD=${DATASOURCE_PASSWORD:-your_db_password}

# Expose 8080

EXPOSE 8080

# launch the Java application

CMD ["java", "-jar", "/app/dev.war"]
