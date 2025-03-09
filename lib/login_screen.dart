import 'package:flutter/material.dart';

class BrainifyLoginScreen extends StatelessWidget {
  const BrainifyLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1280,
        height: 832,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: const Color(0xFF15162B)),
        child: Stack(
          children: [
            // Left side imagery
            Positioned(
              left: 44,
              top: 40,
              child: Container(
                width: 420,
                height: 420,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/brain_image_1.png"),
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
              top: 366,
              child: Container(
                width: 420,
                height: 420,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/brain_image_2.png"),
                    fit: BoxFit.fill,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                  ),
                ),
              ),
            ),
            
            // App title and tagline
            Positioned(
              left: 724,
              top: 98,
              child: SizedBox(
                width: 518,
                height: 79,
                child: Text(
                  'Brainify',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 830,
              top: 188,
              child: Text(
                'Your Own Customised Brain Health App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
            
            // Login form container
            Positioned(
              left: 716,
              top: 302,
              child: Container(
                width: 534,
                height: 343,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title and subtitle
                    Container(
                      width: 446,
                      margin: EdgeInsets.only(bottom: 33),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 284,
                            height: 47,
                            child: Text(
                              'Create an account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFE6E6E6),
                                fontSize: 32,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enter your email to sign up for this app',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFE6E6E6),
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Email input and continue button
                    Container(
                      width: 421,
                      margin: EdgeInsets.only(bottom: 33),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 419.88,
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 1, color: Color(0xFFDFDFDF)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 387.88,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'email@domain.com',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF828282),
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: ShapeDecoration(
                              color: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 1.40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Or divider
                    Container(
                      width: 327,
                      margin: EdgeInsets.only(bottom: 33),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(color: Color(0xFFE6E6E6)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'or',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF828282),
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(color: Color(0xFFE6E6E6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Google sign-in button
                    Container(
                      width: 446,
                      height: 50,
                      margin: EdgeInsets.only(bottom: 33),
                      decoration: ShapeDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Terms of service text
                    SizedBox(
                      width: 486,
                      child: Text(
                        'By clicking continue, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}