import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  final bool isGoogleSignIn;

  const EmailVerificationScreen({
    Key? key,
    required this.email,
    required this.password,
    this.isGoogleSignIn = false,
  }) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool canResendEmail = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isGoogleSignIn) {
      sendVerificationEmail();
    }
  }

  Future<void> checkVerificationAndNavigate() async {
    setState(() => isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: No user found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found. Please try signing up again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('DEBUG: Initial email verification status: ${user.emailVerified}');
      
      // Force reload user to get latest verification status
      await user.reload();
      print('DEBUG: After reload - email verification status: ${user.emailVerified}');
      
      // For Google SSO, we need to check if this is a new user
      if (widget.isGoogleSignIn) {
        // Check if user has a profile
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        print('DEBUG: User profile exists: ${userDoc.exists}');

        if (!mounted) return;

        if (userDoc.exists) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ProfileSetupScreen(
                userId: user.uid,
                email: widget.email,
              ),
            ),
          );
        }
        return;
      }

      // For email/password signup, check verification
      if (!user.emailVerified) {
        print('DEBUG: Email not verified, showing warning');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your email is not verified yet. Please check your inbox and click the verification link.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      // Add a small delay to ensure Firebase has updated the status
      await Future.delayed(const Duration(seconds: 1));
      
      // Reload one more time to be absolutely sure
      await user.reload();
      print('DEBUG: After delay and reload - email verification status: ${user.emailVerified}');
      
      if (!user.emailVerified) {
        print('DEBUG: Email still not verified after delay');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verification failed. Please try verifying again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        setState(() => isLoading = false);
        return;
      }

      if (!mounted) return;

      // After verification is confirmed, check if user has a profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      print('DEBUG: User profile exists: ${userDoc.exists}');

      if (!mounted) return;

      if (userDoc.exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              userId: user.uid,
              email: widget.email,
            ),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error in checkVerificationAndNavigate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    if (!canResendEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait 2 minutes before requesting another verification email.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => canResendEmail = false);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found. Please try signing up again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => canResendEmail = true);
        return;
      }

      await user.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent successfully! Please check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      print('Error sending verification email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send verification email. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(minutes: 2));
      if (mounted) {
        setState(() => canResendEmail = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'A verification email has been sent to:\n${widget.email}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isGoogleSignIn
                  ? 'Please check your email and click the verification link to continue.\n\nIf you don\'t see the email, check your spam folder.'
                  : 'Please check your email and click the verification link to continue.\n\nIf you don\'t see the email, check your spam folder.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Icon(
              Icons.mail_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 32),
            if (!widget.isGoogleSignIn) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                icon: const Icon(Icons.email),
                label: Text(
                  canResendEmail ? 'Resend Verification Email' : 'Wait 2 Minutes',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: canResendEmail ? sendVerificationEmail : null,
              ),
              if (!canResendEmail)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'You can request another email in 2 minutes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
              ),
              icon: isLoading ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ) : const Icon(Icons.check_circle),
              label: Text(
                isLoading ? 'Checking...' : 'Continue',
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: isLoading ? null : checkVerificationAndNavigate,
            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Cancel Signup',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.delete();
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
} 