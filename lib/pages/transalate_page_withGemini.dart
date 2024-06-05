



// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io' show Platform;



//build a translate page that uses gemini api
  
class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final TextEditingController _textController = TextEditingController();
  final apiKey = Platform.environment['GEMINI_API_KEY']!;
  String _summary = '';
  bool _isLoading = false;

  Future<void> _summarizeText() async {
    setState(() {
      _isLoading = true;
    });

    _summary = await summarizeText(_textController.text); // Call the summarization function from previous example

    setState(() {
      _isLoading = false;
    });
  }

 
Future<String> summarizeText(String text) async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final prompt = 'Summarize the following text:\n\n$text';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  return response.candidates.first.text!;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Summarizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Enter text to summarize',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _summarizeText, 
              child: _isLoading ? const CircularProgressIndicator() : const Text('Summarize'),
            ),
            const SizedBox(height: 20),
            if (_summary.isNotEmpty)
              const Text(
                'Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            if (_summary.isNotEmpty)
              Text(
                _summary,
              ),
          ],
        ),
      ),
    );
  }
}
