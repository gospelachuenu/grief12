import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TitheOfferingScreen extends StatefulWidget {
  const TitheOfferingScreen({Key? key}) : super(key: key);

  @override
  State<TitheOfferingScreen> createState() => _TitheOfferingScreenState();
}

class _TitheOfferingScreenState extends State<TitheOfferingScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  final String _backendUrl = 'https://grief12-backend-production-b926.up.railway.app';
  String _selectedType = 'Tithe';

  Future<void> _processPayment() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('$_backendUrl/create-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': _amountController.text,
          'type': _selectedType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final approvalUrl = data['approvalUrl'];
        
        if (approvalUrl != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebView(
                initialUrl: approvalUrl,
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.contains('success')) {
                    Navigator.pop(context, 'success');
                    return NavigationDecision.prevent;
                  }
                  if (request.url.contains('cancel')) {
                    Navigator.pop(context, 'cancel');
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            ),
          );

          if (result == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment successful!')),
            );
            Navigator.pop(context);
          } else if (result == 'cancel') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment cancelled')),
            );
          }
        }
      } else {
        throw Exception('Failed to create payment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAmountDialog(String type) async {
    _amountController.clear();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter $type Amount'),
        content: TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '\$',
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _processPayment();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tithe & Offering'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPaymentCard(
                    'Tithe',
                    'Give your tithe securely',
                    Icons.monetization_on,
                    () => _showAmountDialog('Tithe'),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentCard(
                    'Offering',
                    'Give your offering',
                    Icons.card_giftcard,
                    () => _showAmountDialog('Offering'),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentCard(
                    'Donation',
                    'Make a donation',
                    Icons.favorite,
                    () => _showAmountDialog('Donation'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
} 