import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestContainerApiScreen extends StatefulWidget {
  const TestContainerApiScreen({super.key});

  @override
  _TestContainerApiScreenState createState() => _TestContainerApiScreenState();
}

class _TestContainerApiScreenState extends State<TestContainerApiScreen> {
  final TextEditingController _controller = TextEditingController();
  String _responseMessage = '';
  bool _isLoading = false;

  Future<void> postContainerId(String containerId) async {
    final url = Uri.parse(
      'https://rnvto-41-33-191-114.a.free.pinggy.link/containers?Content-Type=application/json',
    );

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'containerId': containerId,
    });

    setState(() => _isLoading = true);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          _responseMessage = '''
✅ Container Posted
🆔 ID: ${responseData['ID']}
📦 Status: ${responseData['Status']}
🕒 Timestamp: ${responseData['Timestamp']}
📜 History: ${responseData['History']?.join('\n')}
''';
        });
      } else {
        setState(() {
          _responseMessage =
              '❌ Error: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = '❗ Exception: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Container API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Container ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => postContainerId(_controller.text.trim()),
              child: const Text(
                'Post to API',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SelectableText(
                    _responseMessage,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
          ],
        ),
      ),
    );
  }
}
