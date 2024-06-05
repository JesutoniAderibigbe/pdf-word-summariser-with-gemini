import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as path;

const apiKey = 'AIzaSyAdJpXPVujcabfqRpZlN0f3wwLZxH0CgUQ';

class PickFileToSummarise extends StatefulWidget {
  const PickFileToSummarise({super.key});

  @override
  State<PickFileToSummarise> createState() => _PickFileToSummariseState();
}

class _PickFileToSummariseState extends State<PickFileToSummarise> {
  final TextEditingController _textController = TextEditingController();
  String _summary = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _summarizeText() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous errors
    });

    try {
      String textToSummarize = _textController.text;
      _summary = await summarizeText(textToSummarize);
      if (kDebugMode) {
        print(_summary);
      }

    } catch (e) {
      setState(() => _errorMessage = 'Error summarizing: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
           String fileName = path.basename(file.path); 
        String fileExtension = result.files.single.extension!;
          _textController.text = fileName; //

        if (fileExtension == 'txt') {
          _textController.text = await file.readAsString();
          _summarizeText();
        } else if (fileExtension == 'pdf') {
          // Extract text from PDF
          PdfDocument document =
              PdfDocument(inputBytes: file.readAsBytesSync());
          PdfTextExtractor extractor = PdfTextExtractor(document);
          String text = extractor.extractText();
          _textController.text = text;
          if (kDebugMode) {
            print("Extracted PDF text:");
          }
          if (kDebugMode) {
            print(_textController.text);
          }
          await _summarizeText();

          
        } else if (fileExtension == 'docx') {
          // Extract text from DOCX
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error picking file: $e');
    }
  }

  Future<String> summarizeText(String text) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    final prompt = 'Summarize the following text:\n\n$text';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    if (kDebugMode) {
      print(
        "The summary of this file goes as follows ${response.candidates.first.text!}");
    }

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter text or upload file to summarize',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Arrange buttons evenly
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Upload File'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading || _textController.text.isEmpty
                        ? null
                        : _summarizeText,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Summarize'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (_summary.isNotEmpty)
                const Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 10),
              if (_summary.isNotEmpty)
             Text(
                        _summary), // Expanded to make the summary scrollable
            ],
          ),
        ),
      ),
    );
  }
}
