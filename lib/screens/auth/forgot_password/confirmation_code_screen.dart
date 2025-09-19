import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'new_password_screen.dart';
import '../../../widgets/gradient_scaffold.dart';

class ConfirmationCodeScreen extends StatefulWidget {
  final String verificationId;
  const ConfirmationCodeScreen({super.key, required this.verificationId});

  @override
  State<ConfirmationCodeScreen> createState() => _ConfirmationCodeScreenState();
}

class _ConfirmationCodeScreenState extends State<ConfirmationCodeScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Le but ici n'est pas de se connecter, mais de prouver l'identité.
      // On va donc juste vérifier que la credential est valide en tentant de lier
      // au compte existant (ou de se connecter).
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NewPasswordScreen()),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code incorrect.")));
    }

    if (mounted) setState(() => _isLoading = false);
  }
  
  @override
  void dispose(){
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Confirmation',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ... UI inchangée ...
            TextField(
              controller: _otpController,
              // ... autres propriétés ...
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Continuer'),
                // ... style inchangé ...
              ),
            ),
          ],
        ),
      ),
    );
  }
}