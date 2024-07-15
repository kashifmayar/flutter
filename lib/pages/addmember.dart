import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMemberApp extends StatelessWidget {
  const AddMemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AddMember(),
    );
  }
}

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedRelation;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cnicController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> saveMemberData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save member data to Firestore
        await FirebaseFirestore.instance.collection('members').add({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'cnic': _cnicController.text,
          'date_of_birth': _dateController.text,
          'relation': _selectedRelation,
          'created_at': Timestamp.now(),
        });

        snackbar(context, "Member added successfully");
      } catch (e) {
        snackbar(context, "Failed to add member: $e");
      }
    }
  }

  void snackbar(BuildContext context, String message) {
    final snack = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snack).closed.then((value) {
      Navigator.pop(context, '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, '/dashboard');
          },
        ),
        title: const Text(
          "Add Member",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Add Member',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter First Name" : null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter Last Name" : null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _cnicController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CNIC',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please Enter CNIC";
                        } else if (value.length != 13) {
                          return "CNIC must be 13 digits";
                        } else if (!RegExp(r'^\d{13}$').hasMatch(value)) {
                          return "Please Enter a valid CNIC";
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _dateController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {
                        selectDate(context);
                      },
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter Date of Birth" : null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Relation',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite_rounded),
                      ),
                      items: ['Mother', 'Father', 'Son', 'Daughter']
                          .map((relation) => DropdownMenuItem(
                        value: relation,
                        child: Text(relation),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRelation = value;
                        });
                      },
                      validator: (value) {
                        return value == null ? "Please Select Relation" : null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: saveMemberData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
