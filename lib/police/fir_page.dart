import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class FirComponent extends StatefulWidget {
  const FirComponent({super.key});

  @override
  _FirComponentState createState() => _FirComponentState();
}

class _FirComponentState extends State<FirComponent> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool isLoading = false;

  // FIR details form fields
  final TextEditingController _bookNoController = TextEditingController();
  final TextEditingController _formNoController = TextEditingController();
  final TextEditingController _policeStationController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _dateHourOccurrenceController = TextEditingController();
  final TextEditingController _dateHourReportedController = TextEditingController();
  final TextEditingController _informerNameController = TextEditingController();
  final TextEditingController _descriptionOffenseController = TextEditingController();
  final TextEditingController _placeOccurrenceController = TextEditingController();
  final TextEditingController _criminalNameController = TextEditingController();
  final TextEditingController _investigationStepsController = TextEditingController();
  final TextEditingController _dispatchTimeController = TextEditingController();

  // List to hold FIR documents from Firebase
  List<DocumentSnapshot> firList = [];

  // Function to handle FIR generation request
  Future<void> generateFIR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final firDetails = {
      "book_no": _bookNoController.text,
      "form_no": _formNoController.text,
      "police_station": _policeStationController.text,
      "district": _districtController.text,
      "date_hour_occurrence": _dateHourOccurrenceController.text,
      "date_hour_reported": _dateHourReportedController.text,
      "informer_name": _informerNameController.text,
      "description_offense": _descriptionOffenseController.text,
      "place_occurrence": _placeOccurrenceController.text,
      "criminal_name": _criminalNameController.text,
      "investigation_steps": _investigationStepsController.text,
      "dispatch_time": _dispatchTimeController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://fir-generator.onrender.com/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(firDetails),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final downloadUrl = responseData['view_url'];

        if (downloadUrl != null && Uri.parse(downloadUrl).isAbsolute) {
          // Save FIR metadata to Firestore
          await _saveFIRToFirestore(downloadUrl);
        } else {
          _showErrorDialog('Invalid download URL received. Please contact support.');
        }
      } else {
        throw Exception('Failed to generate FIR: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorDialog('Error occurred: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to save the FIR data to Firestore
  Future<void> _saveFIRToFirestore(String downloadUrl) async {
    try {
      final firCollection = FirebaseFirestore.instance.collection('fir');
      final newFIR = {
        "url": downloadUrl,
        "generated_at": Timestamp.now(),
      };

      await firCollection.add(newFIR);

      // Refresh the FIR list
      _fetchFIRList();
    } catch (e) {
      _showErrorDialog('Failed to save FIR: ${e.toString()}');
    }
  }

  // Function to fetch FIRs from Firestore
  Future<void> _fetchFIRList() async {
    try {
      final firCollection = FirebaseFirestore.instance.collection('fir');
      final querySnapshot = await firCollection.orderBy('generated_at', descending: true).get();

      setState(() {
        firList = querySnapshot.docs;
      });
    } catch (e) {
      _showErrorDialog('Error fetching FIR list: ${e.toString()}');
    }
  }

  // Error Dialog Helper Function
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Function to delete FIR
  Future<void> _deleteFIR(String firId) async {
    try {
      await FirebaseFirestore.instance.collection('fir').doc(firId).delete();
      _fetchFIRList();
    } catch (e) {
      _showErrorDialog('Failed to delete FIR: ${e.toString()}');
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13 (API level 33) and above
      if (await Permission.storage.isGranted) return true;

      // Request multiple permissions for Android
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();

      // Check if any required permissions are granted
      return statuses[Permission.storage] == PermissionStatus.granted ||
          statuses[Permission.manageExternalStorage] == PermissionStatus.granted;
    }

    // For iOS, storage permissions are handled differently
    if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }

    return false;
  }

  // Updated download function
  Future<String?> _downloadPDFToExternal(String url) async {
    try {
      // Request storage permission
      bool permissionGranted = await requestStoragePermission();

      if (!permissionGranted) {
        _showErrorDialog('Storage permission is required to download files.');
        return null;
      }

      // Determine appropriate download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        _showErrorDialog('Could not access download directory');
        return null;
      }

      // Generate unique filename
      final String fileName = 'FIR_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${downloadDir.path}/$fileName';

      // Download file
      Dio dio = Dio();
      await dio.download(url, filePath);

      // Show success message with open option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FIR downloaded to: $filePath'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              // Open the downloaded file
              final result = await OpenFile.open(filePath);

              // Check the result of opening the file
              switch (result.type) {
                case ResultType.done:
                  print('File opened successfully');
                  break;
                case ResultType.error:
                  _showErrorDialog('Failed to open file: ${result.message}');
                  break;
                default:
                  print('File open result: ${result.type}');
              }
            },
          ),
        ),
      );

      // Return the file path for sharing
      return filePath;
    } catch (e) {
      _showErrorDialog('Download failed: ${e.toString()}');
      return null;
    }
  }

  // Function to share the FIR PDF
  Future<void> _sharePDF(String url) async {
    try {
      // Download the file first
      final filePath = await _downloadPDFToExternal(url);

      if (filePath != null) {
        // Share the downloaded file
        await Share.shareXFiles([XFile(filePath)], text: 'FIR Document');
      }
    } catch (e) {
      _showErrorDialog('Share failed: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFIRList(); // Load FIRs on initialization
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookNoController.dispose();
    _formNoController.dispose();
    _policeStationController.dispose();
    _districtController.dispose();
    _dateHourOccurrenceController.dispose();
    _dateHourReportedController.dispose();
    _informerNameController.dispose();
    _descriptionOffenseController.dispose();
    _placeOccurrenceController.dispose();
    _criminalNameController.dispose();
    _investigationStepsController.dispose();
    _dispatchTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/ChatBotBackground.jpg"), // Add your image path here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content with TabBar
          Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Generate FIR'),
                  Tab(text: 'View FIRs'),
                ],
                labelColor: Colors.orange, // Active tab label color
                unselectedLabelColor: Colors.black, // Inactive tab label color
                indicatorColor: Colors.blue, // Indicator color
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGenerateFIRForm(),
                    _buildFIRListView(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget to display the FIR form
  Widget _buildGenerateFIRForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_bookNoController, 'Book Number'),
            _buildTextField(_formNoController, 'Form Number'),
            _buildTextField(_policeStationController, 'Police Station'),
            _buildTextField(_districtController, 'District'),
            _buildTextField(_dateHourOccurrenceController, 'Date/Hour of Occurrence'),
            _buildTextField(_dateHourReportedController, 'Date/Hour Reported'),
            _buildTextField(_informerNameController, 'Informer Name'),
            _buildTextField(_descriptionOffenseController, 'Description of Offense'),
            _buildTextField(_placeOccurrenceController, 'Place of Occurrence'),
            _buildTextField(_criminalNameController, 'Criminal Name'),
            _buildTextField(_investigationStepsController, 'Investigation Steps'),
            _buildTextField(_dispatchTimeController, 'Dispatch Time'),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: generateFIR,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Generate FIR', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create text fields with transparency
  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  // Widget to display FIRs
  Widget _buildFIRListView() {
    if (firList.isEmpty) {
      return const Center(child: Text('No FIRs available'));
    }
    return ListView.builder(
      itemCount: firList.length,
      itemBuilder: (context, index) {
        final firData = firList[index].data() as Map<String, dynamic>;
        final firId = firList[index].id;
        final downloadUrl = firData['url'];

        return ListTile(
          title: Text('FIR #$firId'),
          subtitle: Text('Generated at: ${firData['generated_at']}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadPDFToExternal(downloadUrl),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _sharePDF(downloadUrl),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteFIR(firId),
              ),
            ],
          ),
        );
      },
    );
  }
}
// KeepAliveWidget to maintain state across tabs
class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget({super.key, required this.child});

  @override
  _KeepAliveWidgetState createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class PDFViewPage extends StatelessWidget {
  final String filePath;

  const PDFViewPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View FIR PDF')),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
