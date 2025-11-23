import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MLPredictionApp());

class MLPredictionApp extends StatelessWidget {
  const MLPredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = [];
  String _result = '';
  bool _isLoading = false;
  bool _hasError = false;

  // Configure these based on your API
  // For local testing: 'http://127.0.0.1:8000'
  // For deployed API: 'https://your-app-name.onrender.com'
  final String apiUrl = 'http://127.0.0.1:8001';
  final List<String> inputLabels = [
    'Hours Studied (1-44)',
    'Attendance % (60-100)',
    'Previous Scores (50-100)',
    'Tutoring Sessions (0-8)',
    'Parental Involvement Low (0/1)',
    'Parental Involvement Medium (0/1)',
    'Access to Resources Low (0/1)',
    'Access to Resources Medium (0/1)',
    'Extracurricular Activities (0/1)',
    'Motivation Level Low (0/1)',
    'Internet Access (0/1)',
    'Family Income Low (0/1)',
    'Family Income Medium (0/1)',
    'Teacher Quality Low (0/1)',
    'Teacher Quality Medium (0/1)',
    'Peer Influence Positive (0/1)',
    'Learning Disabilities (0/1)',
    'Parent Education High School (0/1)',
    'Parent Education Postgraduate (0/1)',
    'Distance from Home Moderate (0/1)',
    'Distance from Home Near (0/1)'
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < inputLabels.length; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _makePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
      _hasError = false;
    });

    try {
      List<double> inputData = [];
      for (var controller in _controllers) {
        inputData.add(double.parse(controller.text));
      }

      // Prepare API request body with proper field names
      final requestBody = {
        'hours_studied': inputData[0].round(),
        'attendance': inputData[1].round(),
        'previous_scores': inputData[2].round(),
        'tutoring_sessions': inputData[3].round(),
        'parental_involvement_low': inputData[4].round(),
        'parental_involvement_medium': inputData[5].round(),
        'access_to_resources_low': inputData[6].round(),
        'access_to_resources_medium': inputData[7].round(),
        'extracurricular_activities_yes': inputData[8].round(),
        'motivation_level_low': inputData[9].round(),
        'internet_access_yes': inputData[10].round(),
        'family_income_low': inputData[11].round(),
        'family_income_medium': inputData[12].round(),
        'teacher_quality_low': inputData[13].round(),
        'teacher_quality_medium': inputData[14].round(),
        'peer_influence_positive': inputData[15].round(),
        'learning_disabilities_yes': inputData[16].round(),
        'parental_education_level_high_school': inputData[17].round(),
        'parental_education_level_postgraduate': inputData[18].round(),
        'distance_from_home_moderate': inputData[19].round(),
        'distance_from_home_near': inputData[20].round(),
      };

      final response = await http.post(
        Uri.parse('$apiUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = 'Predicted Exam Score: ${data['predicted_exam_score']}';
          _hasError = false;
        });
      } else {
        setState(() {
          _result = 'Server Error: ${response.statusCode}';
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}\n\nMake sure API is running at: $apiUrl';
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _result = '';
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Exam Score Prediction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Student Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter student details to predict exam score',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Input Fields
              ...List.generate(
                inputLabels.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _controllers[index],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: inputLabels[index],
                      hintText: 'Enter ${inputLabels[index].toLowerCase()}',
                      prefixIcon: Icon(
                        Icons.input,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      final number = double.tryParse(value);
                      if (number == null) {
                        return 'Please enter a valid number';
                      }
                      
                      // Range validation based on feature index
                      switch (index) {
                        case 0: // Hours Studied
                          if (number < 1 || number > 44) return 'Must be between 1-44';
                          break;
                        case 1: // Attendance
                          if (number < 60 || number > 100) return 'Must be between 60-100';
                          break;
                        case 2: // Previous Scores
                          if (number < 50 || number > 100) return 'Must be between 50-100';
                          break;
                        case 3: // Tutoring Sessions
                          if (number < 0 || number > 8) return 'Must be between 0-8';
                          break;
                        default: // Binary fields (0 or 1)
                          if (number != 0 && number != 1) return 'Must be 0 or 1';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFields,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _makePrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Predicting...',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : const Text(
                              'Predict',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Result Display
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _hasError 
                        ? Colors.red[50] 
                        : _result.isNotEmpty 
                            ? Colors.green[50] 
                            : Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _hasError 
                            ? Icons.error_outline 
                            : _result.isNotEmpty 
                                ? Icons.check_circle_outline 
                                : Icons.analytics_outlined,
                        size: 48,
                        color: _hasError 
                            ? Colors.red[600] 
                            : _result.isNotEmpty 
                                ? Colors.green[600] 
                                : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Prediction Result',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _hasError 
                              ? Colors.red[800] 
                              : _result.isNotEmpty 
                                  ? Colors.green[800] 
                                  : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasError 
                                ? Colors.red[200]! 
                                : _result.isNotEmpty 
                                    ? Colors.green[200]! 
                                    : Colors.grey[200]!,
                          ),
                        ),
                        child: Text(
                          _result.isEmpty 
                              ? 'Enter student information and click Predict to see exam score' 
                              : _result,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: _result.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                            color: _hasError 
                                ? Colors.red[700] 
                                : _result.isNotEmpty 
                                    ? Colors.green[700] 
                                    : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
