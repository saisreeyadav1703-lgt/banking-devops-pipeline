import os
from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)

APP_ENV = os.environ.get("APP_ENV", "dev")
VERSION = os.environ.get("APP_VERSION", "1.0.0")

transactions = []

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "env": APP_ENV,
        "version": VERSION,
        "timestamp": datetime.utcnow().isoformat()
    }), 200

@app.route("/api/transactions", methods=["GET"])
def get_transactions():
    return jsonify({"transactions": transactions, "count": len(transactions)}), 200

@app.route("/api/transactions", methods=["POST"])
def create_transaction():
    data = request.get_json()
    if not data or "amount" not in data or "type" not in data:
        return jsonify({"error": "amount and type are required"}), 400
    txn = {
        "id": len(transactions) + 1,
        "type": data["type"],
        "amount": data["amount"],
        "account": data.get("account", "ACC-DEFAULT"),
        "timestamp": datetime.utcnow().isoformat()
    }
    transactions.append(txn)
    return jsonify({"message": "Transaction created", "transaction": txn}), 201

@app.route("/api/transactions/<int:txn_id>", methods=["GET"])
def get_transaction(txn_id):
    txn = next((t for t in transactions if t["id"] == txn_id), None)
    if not txn:
        return jsonify({"error": "Transaction not found"}), 404
    return jsonify(txn), 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=(APP_ENV == "dev"))
