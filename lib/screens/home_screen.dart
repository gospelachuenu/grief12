import 'package:flutter/material.dart';
import 'package:grief12/theme/app_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grief12/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grief12/screens/profile_setup_screen.dart';
import 'package:grief12/screens/login_screen.dart';
import 'package:grief12/screens/watch_live_screen.dart';
import 'package:grief12/screens/contact_us_screen.dart';
import 'package:grief12/screens/prayer_requests_screen.dart';
import 'package:grief12/screens/testimony_screen.dart';
import 'package:grief12/screens/tithe_offering_screen.dart';
import 'package:grief12/screens/terms_conditions_screen.dart';
import 'package:grief12/screens/privacy_policy_screen.dart';
import 'package:grief12/screens/events_screen.dart';
import 'package:grief12/screens/daily_word_screen.dart';
import 'package:grief12/screens/sermons_screen.dart';
import 'package:grief12/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  final List<String> _imageList = [
    'assets/images/poster1.jpg',
    'assets/images/poster2.jpg',
    'assets/images/poster3.jpg',
    'assets/images/poster4.jpg',
  ];
  
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _autoScroll();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (profile.exists) {
          setState(() {
            _userProfile = profile.data();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      
      if (_currentImageIndex == _imageList.length - 1) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      _autoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: onTap ?? () {},
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        // TODO: Implement social media link
      },
      color: Colors.black87,
    );
  }

  Widget _buildUserProfileSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = FirebaseAuth.instance.currentUser;
    final name = _userProfile?['name'] ?? '';
    final surname = _userProfile?['surname'] ?? '';
    final displayName = name.isNotEmpty && surname.isNotEmpty 
        ? '$name $surname'
        : 'User';
    final userId = _userProfile?['userId'] ?? 'No ID';
    final profilePictureUrl = _userProfile?['profilePictureUrl'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey[200],
              backgroundImage: profilePictureUrl != null
                  ? NetworkImage(profilePictureUrl)
                  : null,
              child: profilePictureUrl == null
                  ? const Icon(Icons.person, size: 35, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $userId',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              if (user != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSetupScreen(
                      userId: user.uid,
                      email: user.email ?? '',
                      isEditing: true,
                      existingProfile: _userProfile,
                    ),
                  ),
                );
                _loadUserProfile(); // Reload profile after editing
              }
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Profile'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryRed,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TitheOfferingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Image.asset(
          'assets/images/HOC3.png',
          height: 40,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildUserProfileSection(),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileSetupScreen(
                              userId: user.uid,
                              email: user.email ?? '',
                              isEditing: true,
                              existingProfile: _userProfile,
                            ),
                          ),
                        );
                        _loadUserProfile();
                      }
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.church,
                    title: 'Tithe & Offering',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToPayment();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.video_library,
                    title: 'Watch Live',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WatchLiveScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.book,
                    title: 'Daily Word',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DailyWordScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.record_voice_over,
                    title: 'Sermons',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SermonsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.event,
                    title: 'Events',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EventsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.contact_mail,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.front_hand,
                    title: 'Prayer Requests',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrayerRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.volunteer_activism,
                    title: 'Testimonies',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TestimonyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.card_giftcard,
                    title: 'Donations',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TitheOfferingScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () async {
                      await _authService.signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel
            AspectRatio(
              aspectRatio: 16 / 9,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemCount: _imageList.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _imageList[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Page Indicator
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _imageList.length,
                effect: WormEffect(
                  dotColor: Colors.grey.shade300,
                  activeDotColor: AppTheme.primaryRed,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Welcome Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                children: [
                  const Text(
                    'Welcome to House Of Christ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your spiritual journey begins here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Feature Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureItem(
                    icon: Icons.play_circle_fill,
                    label: 'Watch Live',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WatchLiveScreen()),
                    ),
                  ),
                  _buildFeatureItem(
                    icon: Icons.menu_book,
                    label: 'Daily Word',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DailyWordScreen()),
                    ),
                  ),
                  _buildFeatureItem(
                    icon: Icons.mic,
                    label: 'Sermons',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SermonsScreen()),
                    ),
                  ),
                  _buildFeatureItem(
                    icon: Icons.church,
                    label: 'Offering',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TitheOfferingScreen()),
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
} 