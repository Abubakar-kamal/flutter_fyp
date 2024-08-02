import 'package:drapp/auth/resetscreen.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

TextEditingController email = TextEditingController();

class MyOtpScreen extends StatefulWidget {
  const MyOtpScreen({super.key});

  @override
  State<MyOtpScreen> createState() => _MyOtpScreenState();
}

class _MyOtpScreenState extends State<MyOtpScreen> {
  TextEditingController otp = TextEditingController();
  EmailOTP myauth = EmailOTP();
  void _showOrderAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text('Enter OTP from your Email'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: otp,
                    decoration: const InputDecoration(hintText: "Enter OTP")),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (await myauth.verifyOTP(otp: otp.text) == true) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("OTP is verified"),
                      ));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PasswordScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Invalid OTP"),
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Verify")),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Enter account Email To Get New Password ',
                  style: TextStyle(
                      fontSize: 25,
                      color: const Color(0xFF01A7AA),
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 190.0),
                  child: TextFormField(
                    controller: email,
                    onChanged: (value) {
                      setState(() {});
                    },
                    //controller: name,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        prefixIcon: Icon(
                          Icons.email,
                          color: const Color(0xFF01A7AA),
                        )),
                  ),
                ),
                Container(
                    //  color: Colors.purple,
                    width: 150,
                    margin: EdgeInsets.only(top: 54, left: 80),
                    child: ElevatedButton(
                      onPressed: () async {
                        myauth.setConfig(
                            appEmail: "me@rohitchouhan.com",
                            appName: "Email OTP",
                            userEmail: email.text,
                            otpLength: 6,
                            otpType: OTPType.digitsOnly);
                        if (await myauth.sendOTP() == true) {
                          _showOrderAlert(context);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("OTP has been sent"),
                          ));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Oops, OTP send failed"),
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF01A7AA),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.all(0),
                      ),
                      child: Text('Get OTP'),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
