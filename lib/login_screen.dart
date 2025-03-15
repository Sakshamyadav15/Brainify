import 'package:flutter/material.dart';
import 'eeg_screen_dart.dart';

class BrainifyLoginScreen extends StatelessWidget {
  const BrainifyLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: double.infinity,
                height: constraints.maxHeight, // Add explicit height constraint
                color: const Color(0xFF15162B),
                child: Stack(
                  // Ensure stack has size constraints from parent
                  fit: StackFit.expand,
                  children: [
                    // Left side imagery - only show on wider screens
                    if (constraints.maxWidth > 1000) ...[
                      Positioned(
                        left: 44,
                        top: 40,
                        child: Container(
                          width: 420,
                          height: 420,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/brain_image_1.png",
                              ),
                              fit: BoxFit.fill,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 260,
                        top: 300, // Changed from 366 to 300
                        child: Container(
                          width: 420,
                          height: 420,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/brain_image_2.jpg",
                              ),
                              fit: BoxFit.fill,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Main content - aligned to the right
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: constraints.maxWidth > 1000 ? 
                            constraints.maxWidth * 0.5 : 
                            constraints.maxWidth * 0.9,
                        padding: EdgeInsets.only(right: 50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // App title
                            Text(
                              'Brainify',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // App tagline
                            Text(
                              'Your Own Customised Brain Health App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFEEEEEE),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                            const SizedBox(height: 60),

                            // Login form container
                            Container(
                              width: 534,
                              constraints: BoxConstraints(
                                maxWidth:
                                    constraints.maxWidth > 600
                                        ? 534
                                        : constraints.maxWidth * 0.9,
                              ),
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Title and subtitle
                                  Text(
                                    'Create an account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE6E6E6),
                                      fontSize: 32,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Enter your email to sign up for this app',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE6E6E6),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                  const SizedBox(height: 33),

                                  // Email input
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: Color(0xFFDFDFDF),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'email@domain.com',
                                        hintStyle: TextStyle(
                                          color: Color(0xFF828282),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.40,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Continue button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => EEGGraphScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Continue',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          height: 1.40,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Or divider
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE6E6E6),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'or',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF828282),
                                              fontSize: 20,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.40,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE6E6E6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Google sign-in button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFEEEEEE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/google_logo.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              height: 1.40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 33),

                                  // Terms of service text
                                  Text(
                                    'By clicking continue, you agree to our Terms of Service and Privacy Policy',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}