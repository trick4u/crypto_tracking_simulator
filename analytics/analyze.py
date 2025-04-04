import json
from http.server import BaseHTTPRequestHandler, HTTPServer

class RequestHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        # Handle CORS preflight request
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        # Handle CORS for POST request
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

        # Process the trade log
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        trades = json.loads(post_data)  # List of trades: [{crypto, price, amount, action}]

        # Analyze trades for the first crypto in the list
        if not trades:
            suggestion = "No trades yet."
        else:
            prices = [trade['price'] for trade in trades if trade['price'] > 0]
            if len(prices) < 2:
                suggestion = "Need more trades for analysis."
            else:
                avg_price = sum(prices) / len(prices)
                latest_price = prices[-1]
                suggestion = "Buy" if latest_price < avg_price * 0.98 else "Sell" if latest_price > avg_price * 1.02 else "Hold"

        response = json.dumps({'suggestion': suggestion})
        self.wfile.write(response.encode())

# Bind to 127.0.0.1 explicitly
server = HTTPServer(('127.0.0.1', 5000), RequestHandler)
print("Analytics server running at http://127.0.0.1:5000")
server.serve_forever()