import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:renty/core/constant/app_colors.dart';

class HelpSupportUtils {
  // Configuration - Update these with your actual URLs and email
  static const String FAQ_URL = 'https://appforyou.store/backendrenty/web/faq.html';
  static const String BUG_REPORT_URL = 'https://appforyou.store/backendrenty/web/bug-report.html';
  static const String SUPPORT_EMAIL = 'support@renty.com';
  static const String WHATSAPP_NUMBER = '201003640081'; // Include country code without +
  static const String APP_NAME = 'Renty';
  static const String APP_VERSION = '1.0.0';

  /// Open Help & FAQ
  static Future<void> openHelpFAQ(BuildContext context) async {

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColor.cardBackground,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColor.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, color: AppColor.primaryColor, size: 28),
                SizedBox(width: 12),
                Text(
                  "Help FAQ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Get Help Answers",
              style: TextStyle(
                fontSize: 14,
                color: AppColor.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Option 1: Visit FAQ Website
            _buildOptionCard(
              context: context,
              icon: Icons.language,
              title: 'Visit FAQ Page',
              subtitle: 'Browse our comprehensive FAQ',
              color: AppColor.primaryColor,
              onTap: () {
                Navigator.pop(context);
                _launchURL(context, FAQ_URL);
              },
            ),

            SizedBox(height: 12),

            // Option 2: Contact via Email
            _buildOptionCard(
              context: context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'Get help via email',
              color:   Color(0xFF1A1A1A),
              onTap: () {
                Navigator.pop(context);
                _sendSupportEmail(context);
              },
            ),

            SizedBox(height: 12),

            // Option 3: WhatsApp Support
            _buildOptionCard(
              context: context,
              icon: Icons.chat_outlined,
              title: 'WhatsApp Support',
              subtitle: 'Chat with our support team',
              color: AppColor.secondColor,
              onTap: () {
                Navigator.pop(context);
                _openWhatsAppSupport(context);
              },
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Report a Bug
  static Future<void> reportBug(BuildContext context) async {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColor.cardBackground,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColor.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bug_report, color: AppColor.warningColor, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "Report Bug",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Help Improve App",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Option 1: Email Bug Report
              _buildOptionCard(
                context: context,
                icon: Icons.email_outlined,
                title: 'Email Bug Report',
                subtitle: 'Send detailed bug report via email',
                color: AppColor.primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  _sendBugReportEmail(context);
                },
              ),

              SizedBox(height: 12),

              // Option 2: Submit via Form
              _buildOptionCard(
                context: context,
                icon: Icons.description_outlined,
                title: 'Submit Bug Report Form',
                subtitle: 'Fill out our online form',
                color: Color(0xFF1A1A1A),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL(context, BUG_REPORT_URL);
                },
              ),

              SizedBox(height: 12),

              // Option 3: WhatsApp Bug Report
              _buildOptionCard(
                context: context,
                icon: Icons.chat_outlined,
                title: 'Report via WhatsApp',
                subtitle: 'Quick report through WhatsApp',
                color: AppColor.secondColor,
                onTap: () {
                  Navigator.pop(context);
                  _reportBugViaWhatsApp(context);
                },
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build option cards
  static Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? color.withOpacity(0.15)
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  // Launch URL helper
  static Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showErrorSnackBar(context, 'Could not open the page. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening page: ${e.toString()}');
    }
  }

  // Send support email using share_plus
  static Future<void> _sendSupportEmail(BuildContext context) async {
    try {
      final String emailBody = '''
Hello Support Team,

I need help with:

[Please describe your issue here]

---
App Information:
- App Name: $APP_NAME
- Version: $APP_VERSION
- Platform: ${Theme.of(context).platform}
      ''';

      final String subject = '$APP_NAME - Support Request';
      final String shareText = '''
To: $SUPPORT_EMAIL
Subject: $subject

$emailBody
      ''';

      // Try to open email client directly
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: SUPPORT_EMAIL,
        query: _encodeQueryParameters(<String, String>{
          'subject': subject,
          'body': emailBody,
        }),
      );

      final bool launched = await launchUrl(emailUri);

      if (!launched) {
        // Fallback to share
        await Share.share(
          shareText,
          subject: subject,
        );
      }
    } catch (e) {
      // Fallback to share if mailto fails
      try {
        await Share.share(
          'Contact support at: $SUPPORT_EMAIL\n\nSubject: $APP_NAME - Support Request',
          subject: '$APP_NAME - Support Request',
        );
      } catch (shareError) {
        _showErrorSnackBar(context, 'Could not open email. Please contact: $SUPPORT_EMAIL');
      }
    }
  }

  // Send bug report email using share_plus
  static Future<void> _sendBugReportEmail(BuildContext context) async {
    try {
      final String emailBody = '''
Bug Report for $APP_NAME

What happened:
[Describe the bug in detail]

Expected behavior:
[What should have happened instead]

Steps to reproduce:
1. 
2. 
3. 

Additional information:
[Any other relevant details]

---
App Information:
- App Name: $APP_NAME
- Version: $APP_VERSION
- Platform: ${Theme.of(context).platform}
      ''';

      final String subject = '$APP_NAME - Bug Report';
      final String shareText = '''
To: $SUPPORT_EMAIL
Subject: $subject

$emailBody
      ''';

      // Try to open email client directly
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: SUPPORT_EMAIL,
        query: _encodeQueryParameters(<String, String>{
          'subject': subject,
          'body': emailBody,
        }),
      );

      final bool launched = await launchUrl(emailUri);

      if (!launched) {
        // Fallback to share
        await Share.share(
          shareText,
          subject: subject,
        );
      }
    } catch (e) {
      // Fallback to share if mailto fails
      try {
        await Share.share(
          'Report bug at: $SUPPORT_EMAIL\n\nSubject: $APP_NAME - Bug Report',
          subject: '$APP_NAME - Bug Report',
        );
      } catch (shareError) {
        _showErrorSnackBar(context, 'Could not open email. Please contact: $SUPPORT_EMAIL');
      }
    }
  }

  // WhatsApp support
  static Future<void> _openWhatsAppSupport(BuildContext context) async {
    try {
      const String message = 'Hello, I need help with Renty app';

      // Try WhatsApp with phone number
      final String whatsappUrl = 'https://wa.me/$WHATSAPP_NUMBER?text=${Uri.encodeComponent(message)}';
      final Uri uri = Uri.parse(whatsappUrl);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showErrorSnackBar(context, 'Could not open WhatsApp. Please ensure it\'s installed.');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening WhatsApp: ${e.toString()}');
    }
  }

  // WhatsApp bug report
  static Future<void> _reportBugViaWhatsApp(BuildContext context) async {
    try {
      final String message = '''
🐛 Bug Report for $APP_NAME

What happened:
[Describe the bug]

Expected behavior:
[What should have happened]

App Version: $APP_VERSION
Platform: ${Theme.of(context).platform}
      ''';

      final String whatsappUrl = 'https://wa.me/$WHATSAPP_NUMBER?text=${Uri.encodeComponent(message)}';
      final Uri uri = Uri.parse(whatsappUrl);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showErrorSnackBar(context, 'Could not open WhatsApp. Please ensure it\'s installed.');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Error opening WhatsApp: ${e.toString()}');
    }
  }

  // Helper to encode query parameters for mailto
  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Success snackbar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}