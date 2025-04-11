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
