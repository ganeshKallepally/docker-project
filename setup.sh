#!/bin/bash

echo "Setting up Flask + MySQL app using Docker Compose..."

# Create project folders
mkdir -p app db

# Create app.py
cat <<EOF > app/app.py
from flask import Flask
import pymysql

app = Flask(__name__)

@app.route('/')
def hello():
    try:
        connection = pymysql.connect(
            host='db',
            user='root',
            password='example',
            database='testdb'
        )
        cursor = connection.cursor()
        cursor.execute("SELECT message FROM greetings LIMIT 1;")
        message = cursor.fetchone()[0]
        return f"<h1>{message}</h1>"
    except Exception as e:
        return f"Error: {e}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Create init.sql
cat <<EOF > db/init.sql
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

CREATE TABLE IF NOT EXISTS greetings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255) NOT NULL
);

INSERT INTO greetings (message) VALUES ('Hello from Flask and MySQL!');
EOF

# Create requirements.txt
cat <<EOF > requirements.txt
flask
pymysql
EOF

# Create Dockerfile
cat <<EOF > Dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

CMD ["python", "app.py"]
EOF

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - db

  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: example
    volumes:
      - db_data:/var/lib/mysql
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql

volumes:
  db_data:
EOF

# Run the app
docker-compose up --build

