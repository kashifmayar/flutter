import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/registeration_db.dart'; // Import the user.dart file

class Reg extends StatefulWidget {
  const Reg({super.key});

  @override
  State<Reg> createState() => _RegState();
}

class _RegState extends State<Reg> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  DateTime currentDate = DateTime.now();

  String? _firstName;
  String? _lastName;
  String? _cnic;
  String? _dateOfBirth;
  String? _gender;
  String? _email;
  String? _password;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2500),
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        _dateOfBirth = _dateController.text;
      });
    }
  }

  void snackbar(BuildContext context) {
    final snack = const SnackBar(content: Text("Registration Successful"));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User newUser = User(
        firstName: _firstName!,
        lastName: _lastName!,
        cnic: _cnic!,
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        email: _email!,
        password: _password!,
      );

      // Store user data in Firestore
      FirebaseFirestore.instance
          .collection('Users')
          .add(newUser.toMap())
          .then((value) => print("User Registered"))
          .catchError((error) => print("Failed to register user: $error"));

      Navigator.pop(context, '/');
      snackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, '/');
          },
        ),
        title: const Text(
          "Registration Page",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Registration",
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter First Name" : null;
                      },
                      onSaved: (value) {
                        _firstName = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter Last Name" : null;
                      },
                      onSaved: (value) {
                        _lastName = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'CNIC',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                        filled: true,
                        fillColor: Colors.white70,
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
                      onSaved: (value) {
                        _cnic = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _dateController,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      readOnly: true,
                      onTap: () {
                        selectDate();
                      },
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter Date of Birth" : null;
                      },
                      onSaved: (value) {
                        _dateOfBirth = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_pin),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        _gender = value;
                      },
                      validator: (value) {
                        return value == null ? "Please Select Gender" : null;
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'xyz@gmail.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter Email" : null;
                      },
                      onSaved: (value) {
                        _email = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      validator: (value) {
                        return value!.isEmpty ? "Please Enter Password" : null;
                      },
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),

                        ),
                      ),
                      child: const Text('Register',),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}