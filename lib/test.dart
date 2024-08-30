import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerPrintAuth extends StatefulWidget {
  const FingerPrintAuth({super.key});

  @override
  State<FingerPrintAuth> createState() => _FingerPrintAuthState();
}

class _FingerPrintAuthState extends State<FingerPrintAuth> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _authorized = 'Not Authorized';

  Future<void> _authenticateWithFingerprint() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });

      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the secure locker',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });
    } catch (e) {
      print('Error authenticating: $e');
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error: $e';
      });
    }

    if (!mounted) return;

    if (authenticated) {
      _showAuthorizedDialog();
    } else {
      _showRetryDialog();
    }
  }

  void _showAuthorizedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Access Granted'),
        content: const Text('You have successfully authenticated.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('Authentication failed. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authenticateWithFingerprint();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<String> test() async{
    final authenticated = await auth.authenticate(
      localizedReason: 'Please authenticate to access the secure locker',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
    return authenticated.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: ElevatedButton(
          // onPressed: _isAuthenticating ? null : _authenticateWithFingerprint,
          onPressed: () async{
            final data = await test();
            print(data);
          },
          // child: Text(_isAuthenticating ? 'Authenticating...' : 'Open Locker'),
          child: Text('Open Locker'),
        ),
      ),
    );
  }
}
