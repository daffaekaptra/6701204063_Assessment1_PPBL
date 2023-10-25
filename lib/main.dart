import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockPricePage(),
    );
  }
}

class StockPricePage extends StatefulWidget {
  @override
  _StockPricePageState createState() => _StockPricePageState();
}

class _StockPricePageState extends State<StockPricePage> {
  String stockSymbol = "DG";
  List<double> stockPrices = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://api.polygon.io/v2/aggs/ticker/DG/range/1/day/2023-09-25/2023-10-25?apiKey=Z7njPwky8BWLLK76ol89MDyaxbsaRTme'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];
      for (var result in results) {
        stockPrices.add(result['o'].toDouble());
      }
      setState(() {});
    } else {
      throw Exception('Failed to load stock prices');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Price Monitoring'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kode Saham: $stockSymbol',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: fetchData,
              child: Text('Refresh Data'),
            ),
            Container(
              height: 200,
              child: StockPriceChart(stockPrices),
            ),
          ],
        ),
      ),
    );
  }
}

class StockPriceChart extends StatelessWidget {
  final List<double> data;

  StockPriceChart(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: Colors.yellow,
              isStrokeCapRound: false,
              belowBarData: BarAreaData(show: false),
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 6, showTitles: true)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: const Color(0xff37434d),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
