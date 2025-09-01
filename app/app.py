from flask import Flask, request, jsonify

app = Flask(__name__)

# Dummy knowledge base
DATA = {
    "terraform": "Infrastructure as Code tool to provision and manage cloud resources.",
    "docker": "Platform for containerizing applications with all dependencies.",
    "gcp": "Google Cloud Platform, a suite of cloud computing services.",
    "vpc": "Virtual Private Cloud - logically isolated network for cloud resources."
}

@app.route("/")
def home():
    return jsonify({"message": "Welcome to Sid's Search App on GCP!"})

@app.route("/search")
def search():
    query = request.args.get("q", "").lower()
    result = DATA.get(query, "No result found")
    return jsonify({query: result})

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    # Bind to 0.0.0.0 so Docker/GCP can access it
    app.run(host="0.0.0.0", port=8080, debug=True)
