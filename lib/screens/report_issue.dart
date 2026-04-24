import 'package:flutter/material.dart';
import 'location_screen.dart';
import '../complaint_store.dart';
//import 'dart:io';
//import 'package:image_picker/image_picker.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String? selectedIssue;
  String? selectedPriority;
  String locationText = "Not Selected";

  TextEditingController descriptionController = TextEditingController();
  void showError(String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
    ),
  );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Report An Issue",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(child: Icon(Icons.notifications)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ISSUE TYPE
              const Text("Issue Type"),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedIssue,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "Road Damage", child: Text("Road Damage")),
                  DropdownMenuItem(value: "Garbage", child: Text("Garbage")),
                  DropdownMenuItem(value: "Street Light", child: Text("Street Light")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedIssue = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // DESCRIPTION
              const Text("Description"),
              const SizedBox(height: 8),

              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Describe the issue...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LOCATION
              const Text("Select Location"),
              const SizedBox(height: 10),

              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(locationText),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationScreen(),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        locationText = result;
                      });
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text("Open Map"),
                ),
              ),

              const SizedBox(height: 20),

              // PRIORITY
              const Text("Priority"),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  choiceButton("Low", Colors.green),
                  choiceButton("Medium", Colors.orange),
                  choiceButton("High", Colors.red),
                ],
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
             SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
              onPressed: () {
                if (selectedIssue == null) {
                  showError("Please select issue type");
                  return;
                }
                if (locationText == "Not Selected") {
                 showError("Please select location");
                 return;
                }
                if (locationText == "Not Selected") {
                  showError("Please select location");
                   return;
                  }

                if (selectedPriority == null) {
                showError("Please select priority");
                return;
              }

            ComplaintStore.complaints.add(
            Complaint(
            issueType: selectedIssue!,
            description: descriptionController.text.isEmpty
            ? "No description added"
           : descriptionController.text,
            priority: selectedPriority!,
           location: locationText,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Complaint Submitted Successfully")),
  );

  Navigator.pop(context);
},
    child: const Text(
      "Submit Complaint",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  Widget choiceButton(String text, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedPriority == text ? color : Colors.grey.shade300,
        foregroundColor:
            selectedPriority == text ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedPriority = text;
        });
      },
      child: Text(text),
    );
  }
}