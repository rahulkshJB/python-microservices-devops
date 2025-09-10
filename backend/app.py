import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(
        host="db",  # This is the service name in docker-compose.yml
        database=os.environ.get("POSTGRES_DB"),
        user=os.environ.get("POSTGRES_USER"),
        password=os.environ.get("POSTGRES_PASSWORD")
    )
    return conn

@app.route('/api/data')
def get_data():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Simple logging call to the logger service
        # In a real app, this would be more robust
        try:
            import requests
            requests.post("http://logger:5002/log", json={"service": "backend", "message": "API request received for /api/data"})
        except Exception as e:
            print(f"Could not log to logger service: {e}")

        # Create table and insert data if it doesn't exist
        cur.execute("CREATE TABLE IF NOT EXISTS users (id serial PRIMARY KEY, name varchar);")
        cur.execute("INSERT INTO users (name) VALUES (%s) ON CONFLICT DO NOTHING;", ('test_user_from_backend',))
        conn.commit()
        
        # Fetch data
        cur.execute('SELECT * FROM users;')
        users = cur.fetchall()
        cur.close()
        conn.close()
        
        return jsonify([{'id': row[0], 'name': row[1]} for row in users])

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)