import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: RegistrationForm()));
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String? _fullName;
  String? _email;
  String? _gender;
  String? _province;
  bool _acceptedTerms = false;

  final List<String> _provinces = ['Bangkok', 'Chiang Mai', 'Phuket', 'Khon Kaen'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration Form")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => _fullName = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                onSaved: (value) => _email = value,
              ),
              SizedBox(height: 16),
              Text("Gender"),
              Row(
                children: [
                  Radio<String>(
                    value: "Male",
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  Text("Male"),
                  SizedBox(width: 20),
                  Radio<String>(
                    value: "Female",
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  Text("Female"),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Province'),
                items: _provinces.map((String province) {
                  return DropdownMenuItem(value: province, child: Text(province));
                }).toList(),
                validator: (value) => value == null ? 'Please select a province' : null,
                onChanged: (value) => setState(() => _province = value),
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text("Accept Terms & Conditions"),
                value: _acceptedTerms,
                onChanged: (value) => setState(() => _acceptedTerms = value!),
              ),
              SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _acceptedTerms) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Registration Successful!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (!_acceptedTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You must accept the terms"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text("Submit"),
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
