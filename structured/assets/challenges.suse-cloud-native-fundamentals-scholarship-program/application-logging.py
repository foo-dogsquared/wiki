import logging
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    logging.info("/ endpoint was reached")
    return "Hello World!"

@app.route("/status")
def health_check():
    logging.info("/status endpoint was reached")
    return { "result": "OK - healthy" }

@app.route("/metrics")
def metrics():
    logging.info("/metrics endpoint was reached")
    return { "data": { "UserCount": 140, "UserCountActive": 23} }

if __name__ == "__main__":
    logging.basicConfig(format="%(asctime)s, %(message)s", level=logging.DEBUG, filename="app.log")
    app.run(host='0.0.0.0')
