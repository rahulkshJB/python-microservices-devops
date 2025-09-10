from flask import Flask, request
import logging

# Configure basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

app = Flask(__name__)

@app.route('/log', methods=['POST'])
def log_message():
    log_data = request.get_json()
    if not log_data:
        return "Invalid log format", 400
    
    # In a real app, you'd write to a file or a logging service.
    # Here we just print to stdout to see it in Docker logs.
    logging.info(f"LOG: {log_data}")
    return "Logged", 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5002)