# Crypto Trading Simulator

A simple crypto trading simulator built with Flutter, Node.js, and Python. This project allows users to simulate trading 50 cryptocurrencies with live price feeds, execute trades, and receive basic trading strategy suggestions.

## Features
- **Live Crypto Prices**: Fetches real-time prices for 50 cryptocurrencies using the CoinGecko API.
- **Simulated Trading**: Buy and sell cryptocurrencies with a virtual balance.
- **Trading Strategy Suggestions**: Analyzes trade history and suggests actions (Buy, Sell, Hold) using a Python-based analytics server.
- **Modern UI**: A sleek, dark-themed Flutter UI with a scrollable list of cryptocurrencies.

## Tech Stack
- **Frontend**: Flutter (Dart) for the mobile UI.
- **Backend**: Node.js for fetching live crypto prices and handling trade execution.
- **Analytics**: Python for analyzing trade patterns and suggesting strategies.
- **API**: CoinGecko API (free tier) for live crypto prices.

## Prerequisites
- **Flutter**: Install Flutter and Dart (https://flutter.dev/docs/get-started/install).
- **Node.js**: Install Node.js and npm (https://nodejs.org/).
- **Python**: Install Python 3 (https://www.python.org/downloads/).
- **VS Code**: Recommended editor with Flutter, Dart, Node.js, and Python extensions.

## Project Structure
crypto_trading_simulator/
├── backend/          # Node.js backend for price fetching and trade execution
│   ├── server.js
│   └── package.json
├── analytics/        # Python server for trade analysis and strategy suggestions
│   └── analyze.py
├── frontend/         # Flutter app for the UI
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
└── README.md
