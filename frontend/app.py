from flask import Flask, render_template
import requests

app = Flask(__name__)

# Backend API URL (this name 'backend' works because of Docker's internal DNS)
BACKEND_URL = "http://backend:5000/api/data"

@app.route("/")
def index():
    try:
        response = requests.get(BACKEND_URL, timeout=5)
        response.raise_for_status() # Raise an exception for bad status codes
        data = response.json()
    except Exception as e:
        data = {"error": str(e)}
    return render_template("index.html", data=data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=True)