// widgets/crypto_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class CryptoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showGradient;
  final double elevation;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onTitleTap;
  
  const CryptoAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showGradient = true,
    this.elevation = 0,
    this.leading,
    this.centerTitle = false,
    this.bottom,
    this.onTitleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create gradient colors
    const primaryGradient = LinearGradient(
      colors: [
        Color(0xFF1A2036),  // Dark blue base
        Color(0xFF252D4A),  // Slightly lighter blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      backgroundColor: showGradient ? Colors.transparent : const Color(0xFF252D4A),
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      flexibleSpace: showGradient ? Container(
        decoration: const BoxDecoration(gradient: primaryGradient),
      ) : null,
      title: InkWell(
        onTap: onTitleTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crypto icon with glow effect
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.currency_bitcoin,
                size: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            
            // Title with crypto-style text
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black38,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: actions != null ? [
        ...actions!,
        const SizedBox(width: 8), // Add some padding to the last action
      ] : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null 
      ? kToolbarHeight + bottom!.preferredSize.height 
      : kToolbarHeight);
}

// Optional: Create a crypto notification badge for the AppBar
class CryptoNotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  
  const CryptoNotificationBadge({
    Key? key,
    required this.count,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.notifications_outlined),
          ),
          if (count > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Usage example:
// Add this to any screen's build method to use the crypto-themed AppBar

/*
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CryptoAppBar(
      title: 'Trading Dashboard',
      centerTitle: false,
      showGradient: true,
      actions: [
        CryptoNotificationBadge(
          count: 3, // Number of notifications
          onTap: () {
            // Handle notification tap
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {
            // Handle profile tap
          },
        ),
      ],
    ),
    body: ...
  );
}
*/

// Advanced Usage:
// For a screen with tabs, use it with TabBar

/*
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CryptoAppBar(
      title: 'Market Analysis',
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Charts'),
          Tab(text: 'Signals'),
        ],
        indicatorColor: Colors.blue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Handle search
          },
        ),
      ],
    ),
    body: ...
  );
}
*/