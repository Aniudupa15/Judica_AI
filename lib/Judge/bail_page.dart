import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class Bailpage extends StatefulWidget {
  const Bailpage({super.key});

  @override
  State<Bailpage> createState() => _BailpageState();
}

class _BailpageState extends State<Bailpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Loading state

  // Form fields
  String? statute;
  String? offenseCategory;
  String? penalty;
  int? imprisonmentDurationServed;
  int? riskOfEscape;
  int? riskOfInfluence;
  int? suretyBondRequired;
  int? personalBondRequired;
  int? finesApplicable;
  int? servedHalfTerm;
  int? bailEligibility;
  double? riskScore;
  double? penaltySeverity;

  // Dropdown options
  final List<String> statutes = ['NDPS', 'SCST Act', 'PMLA', 'CrPC', 'IPC'];
  final List<String> offenseCategories = [
    'Crimes Against Children',
    'Offenses Against the State',
    'Crimes Against Foreigners',
    'Crimes Against SCs and STs',
    'Cyber Crime',
    'Economic Offense',
    'Crimes Against Women'
  ];
  final List<String> penalties = ['Fine', 'Both', 'Imprisonment'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ChatBotBackground.jpg'), // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Form Title
                        const Center(),
                        const SizedBox(height: 20),
                        _buildDropdown('Statute', statutes, statute, (value) {
                          setState(() => statute = value);
                        }),
                        const SizedBox(height: 16),
                        _buildDropdown('Offense Category', offenseCategories, offenseCategory, (value) {
                          setState(() => offenseCategory = value);
                        }),
                        const SizedBox(height: 16),
                        _buildDropdown('Penalty', penalties, penalty, (value) {
                          setState(() => penalty = value);
                        }),
                        const SizedBox(height: 16),
                        _buildNumericInput(
                          'Imprisonment Duration Served (in years)',
                              (value) => imprisonmentDurationServed = int.tryParse(value),
                        ),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Risk of Escape', (value) => riskOfEscape = value),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Risk of Influence', (value) => riskOfInfluence = value),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Surety Bond Required', (value) => suretyBondRequired = value),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Personal Bond Required', (value) => personalBondRequired = value),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Fines Applicable', (value) => finesApplicable = value),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Served Half Term (0 or 1)', (value) => servedHalfTerm = value),
                        const SizedBox(height: 16),
                        _buildYesNoDropdown('Bail Eligibility (0 or 1)', (value) => bailEligibility = value),
                        const SizedBox(height: 16),
                        _buildNumericInput(
                          'Risk Score',
                              (value) => riskScore = double.tryParse(value),
                        ),
                        const SizedBox(height: 16),
                        _buildNumericInput(
                          'Penalty Severity',
                              (value) => penaltySeverity = double.tryParse(value),
                        ),
                        const SizedBox(height: 16),
                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Loading Indicator
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildYesNoDropdown(String label, ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: [0, 1]
          .map((value) => DropdownMenuItem(value: value, child: Text(value == 1 ? 'Yes' : 'No')))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildNumericInput(String label, ValueChanged<String> onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      onSaved: (value) => onSaved(value!),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Show loading
      _formKey.currentState!.save();

      final payload = {
        'statute': statute,
        'offense_category': offenseCategory,
        'penalty': penalty,
        'imprisonment_duration_served': imprisonmentDurationServed,
        'risk_of_escape': riskOfEscape,
        'risk_of_influence': riskOfInfluence,
        'surety_bond_required': suretyBondRequired,
        'personal_bond_required': personalBondRequired,
        'fines_applicable': finesApplicable,
        'served_half_term': servedHalfTerm,
        'bail_eligibility': bailEligibility,
        'risk_score': riskScore,
        'penalty_severity': penaltySeverity,
      };

      const apiUrl = 'https://bail.onrender.com/predict-bail';
      try {
        final postResponse = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );

        if (postResponse.statusCode == 200) {
          final postResponseData = json.decode(postResponse.body);
          _showResponseDialog({...postResponseData});
        } else {
          _showResponseDialog({'Error': 'POST request failed'});
        }
      } catch (e) {
        _showResponseDialog({'Error': 'An error occurred: $e'});
      } finally {
        setState(() => _isLoading = false); // Hide loading
      }
    }
  }

  void _showResponseDialog(Map<String, dynamic> response) {
    // Check the response for bail-related data
    bool isBailGranted = response['Eligible for Bail'] == 1;

    String lottieAsset = isBailGranted
        ? 'assets/no_bail.json' // Lottie file for bail
        : 'assets/bail.json'; // Lottie file for no bail

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bail Prediction', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lottie Animation based on Bail Eligibility
              Lottie.asset(
                lottieAsset,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // Display the response data
              ...response.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Prediction: ${entry.value}',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
