import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(CryptoSimulatorApp());

class CryptoSimulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      home: CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  @override
  _CryptoHomePageState createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  Map<String, double> prices = {};
  double balance = 10000.0;
  Map<String, double> holdings = {};
  String suggestion = "Loading...";
  List<Map<String, dynamic>> tradeLog = [];

  @override
  void initState() {
    super.initState();
    fetchPrices();
    fetchSuggestion();
  }

  Future<void> fetchPrices() async {
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:3000/prices'))
          .timeout(Duration(seconds: 5)); // Add timeout
      if (response.statusCode == 200) {
        setState(() {
          prices = Map<String, double>.from(
            json
                .decode(response.body)
                .map((k, v) => MapEntry(k, v['usd'].toDouble())),
          );
          if (holdings.isEmpty) {
            holdings = Map<String, double>.from(
              prices.map((k, v) => MapEntry(k, 0.0)),
            );
          }
        });
      } else {
        print('Failed to fetch prices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching prices: $e');
    }
  }

  Future<void> executeTrade(String crypto, double amount, String action) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:3000/trade'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'crypto': crypto,
              'amount': amount,
              'action': action,
            }),
          )
          .timeout(Duration(seconds: 5)); // Add timeout
      if (response.statusCode == 200) {
        setState(() {
          var data = json.decode(response.body);
          balance = data['balance'];
          holdings = Map<String, double>.from(
            data['holdings'].map((k, v) => MapEntry(k, v.toDouble())),
          );
          tradeLog.add({
            'crypto': crypto,
            'price': prices[crypto] ?? 0,
            'amount': amount,
            'action': action,
          });
        });
        fetchSuggestion();
      } else {
        print('Trade failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error executing trade: $e');
    }
  }

  Future<void> fetchSuggestion() async {
    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:5000'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(tradeLog),
          )
          .timeout(Duration(seconds: 5)); // Add timeout
      if (response.statusCode == 200) {
        setState(() {
          suggestion = json.decode(response.body)['suggestion'];
        });
      } else {
        setState(() {
          suggestion = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        suggestion = "Failed to fetch suggestion: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto Trading Simulator"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.teal[800],
            child: Column(
              children: [
                Text(
                  "Balance: \$${balance.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Strategy: $suggestion",
                  style: TextStyle(fontSize: 18, color: Colors.tealAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: prices.length,
              itemBuilder: (context, index) {
                String crypto = prices.keys.elementAt(index);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(
                      crypto.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Price: \$${prices[crypto]?.toStringAsFixed(2) ?? 'N/A'} | Holding: ${holdings[crypto]?.toStringAsFixed(4) ?? '0.0000'}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => executeTrade(crypto, 0.01, 'buy'),
                          child: Text("Buy"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => executeTrade(crypto, 0.01, 'sell'),
                          child: Text("Sell"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
