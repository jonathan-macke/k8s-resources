FROM openjdk:17-jdk-slim

RUN apt-get update && apt-get install -y curl

WORKDIR /app

RUN curl -o postgresql.jar -k https://jdbc.postgresql.org/download/postgresql-42.7.3.jar

COPY Main.java /app

RUN javac -cp postgresql.jar:./* Main.java

CMD ["java", "-cp", ".:postgresql.jar", "Main"]
