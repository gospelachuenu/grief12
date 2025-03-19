import 'package:flutter/material.dart';
import 'package:grief12/theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing and using the House of Christ mobile application, you accept and agree to be bound by the terms and conditions of this agreement.',
            ),
            _buildSection(
              title: '2. Use License',
              content: 'Permission is granted to temporarily download one copy of the materials (information or software) on House of Christ\'s mobile application for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              title: '3. Disclaimer',
              content: 'The materials on House of Christ\'s mobile application are provided on an \'as is\' basis. House of Christ makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),
            _buildSection(
              title: '4. Limitations',
              content: 'In no event shall House of Christ or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on House of Christ\'s mobile application.',
            ),
            _buildSection(
              title: '5. Accuracy of Materials',
              content: 'The materials appearing on House of Christ\'s mobile application could include technical, typographical, or photographic errors. House of Christ does not warrant that any of the materials on its mobile application are accurate, complete or current.',
            ),
            _buildSection(
              title: '6. Links',
              content: 'House of Christ has not reviewed all of the sites linked to its mobile application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by House of Christ of the site.',
            ),
            _buildSection(
              title: '7. Modifications',
              content: 'House of Christ may revise these terms of service for its mobile application at any time without notice. By using this mobile application you are agreeing to be bound by the then current version of these terms of service.',
            ),
            _buildSection(
              title: '8. Governing Law',
              content: 'These terms and conditions are governed by and construed in accordance with the laws and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last updated: ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
} 