from flask import Flask
import psycopg2
import redis
import os

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello Day 34 Docker Compose!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
