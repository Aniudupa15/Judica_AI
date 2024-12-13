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
  bool _isLoading = false;

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
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ChatBotBackground.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                        _buildYesNoDropdown('Served Half Term', (value) => servedHalfTerm = value),
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
      setState(() => _isLoading = true);
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
        'risk_score': riskScore,
        'penalty_severity': penaltySeverity,
      };

      const apiUrl = 'https://bail.onrender.com/predict-bail';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _showResponseDialog(responseData);
        } else {
          _showResponseDialog({'Error': 'Failed to get response.'});
        }
      } catch (e) {
        _showResponseDialog({'Error': e.toString()});
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showResponseDialog(Map<String, dynamic> response) {
    final isBailGranted = response['Eligible for Bail'] == 1;
    final lottieAsset = isBailGranted ? 'assets/bail.json' : 'assets/no_bail.json';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isBailGranted ? 'Bail Granted' : 'Bail Denied'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(lottieAsset, height: 150),
              const SizedBox(height: 20),
              ...response.entries.map((entry) {
                return Text('${entry.key}: ${entry.value}');
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
