import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/bloc/profile/user_bloc.dart';
import 'package:pizza_boys/core/bloc/profile/user_event.dart';
import 'package:pizza_boys/core/bloc/profile/user_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/session/session_manager.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/profile/user_repo.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Profile extends StatelessWidget {
  final ScrollController scrollController;
  const Profile({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeleteAccountBloc(UserRepo()),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          title: Text.rich(
            TextSpan(
              text: 'User',
              style: _textStyle(16.sp, FontWeight.w600),
              children: [
                TextSpan(
                  text: ' Profile',
                  style: TextStyle(color: AppColors.redAccent),
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.powerOff,
                color: AppColors.redPrimary,
                size: 18.sp,
              ),
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
            SizedBox(width: 6.w),

            Builder(
              builder: (innerContext) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: AppColors.redPrimary,
                  ),
                  onPressed: () => _showDeleteAccountSheet(innerContext),
                );
              },
            ),

            SizedBox(width: 16.w),
          ],
        ),
        body: ListView(
          controller: scrollController,
          padding: EdgeInsets.all(16.w),
          children: [
            _buildUserCard(context),
            SizedBox(height: 20.h),
            ..._buildProfileOptions(context),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 16 * height / 800,
            horizontal: 20 * width / 360,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8 * width / 360),
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: AppColors.blackColor,
                  size: 24 * width / 360,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14 * width / 360,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16 * height / 800),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.redPrimary.withOpacity(0.8),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await SessionManager.clearSession(context);

                        // Clear logged-in user's favorites in Bloc
                        context.read<FavoriteBloc>().clearFavorites();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context) {
    Future<Map<String, String?>> _loadUserNameEmail() async {
      final name = await TokenStorage.getName();
      final email = await TokenStorage.getEmail();
      return {'name': name, 'email': email};
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.redPrimary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          FutureBuilder<String?>(
            future: TokenStorage.getProfile(),
            builder: (context, snapshot) {
              final profileUrl =
                  snapshot.data ??
                  "https://i.pravatar.cc/300"; // fallback image
              return CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(profileUrl),
              );
            },
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FutureBuilder<Map<String, String?>>(
              future: _loadUserNameEmail(),
              builder: (context, snapshot) {
                final name = snapshot.data?['name'] ?? "Guest";
                final email = snapshot.data?['email'] ?? "guest@gmail.com";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: _textStyle(14.sp, FontWeight.w800, Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: _textStyle(
                        12.sp,
                        FontWeight.normal,
                        Colors.white60,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // InkWell(
          //   onTap: () => Navigator.pushNamed(context, AppRoutes.profileEdit),
          //   child: Icon(
          //     FontAwesomeIcons.edit,
          //     color: Colors.white,
          //     size: 16.sp,
          //   ),
          // ),
        ],
      ),
    );
  }

  List<Widget> _buildProfileOptions(BuildContext context) {
    final options = [
      _ProfileOption(
        FontAwesomeIcons.solidClock, // Filled (solid) variant
        "Order History",
        "View past orders and reorder quickly",
        ontap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.orderHistory,
            arguments: false,
          );
        },
      ),
      _ProfileOption(
        FontAwesomeIcons.solidHeart, // Filled heart for favorites
        "Wishlist",
        "View and manage your saved items",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.favorites);
        },
      ),

      // _ProfileOption(
      //   FontAwesomeIcons.locationDot, // Filled (solid)
      //   "Saved Addresses",
      //   "Manage your delivery locations",
      //   ontap: () {
      //     Navigator.pushNamed(context, AppRoutes.saveAddress);
      //   },
      // ),
      // _ProfileOption(
      //   FontAwesomeIcons.solidBell, // Filled
      //   "Notifications",
      //   "Order updates and exclusive offers",
      //   ontap: () {
      //     Navigator.pushNamed(context, AppRoutes.notifications);
      //   },
      // ),
      // _ProfileOption(
      //   FontAwesomeIcons.solidCreditCard, // Filled
      //   "Payment Methods",
      //   "Manage your saved cards",
      //   ontap: () {
      //     Navigator.pushNamed(context, AppRoutes.paymentMethods);
      //   },
      // ),
      // _ProfileOption(
      //   FontAwesomeIcons.solidCircleQuestion, // Filled support/help icon
      //   "Support",
      //   "Get help with orders or payments",
      //   ontap: () {
      //     Navigator.pushNamed(context, AppRoutes.support);
      //   },
      // ),
      // _ProfileOption(
      //   FontAwesomeIcons.shieldHalved, // Filled (solid) shield
      //   "Security Settings",
      //   "Manage password & login methods",
      //   ontap: () {
      //     Navigator.pushNamed(context, AppRoutes.securityAndSetting);
      //   },
      // ),
    ];

    return options.map((e) => _buildListTile(e)).toList();
  }

  void _showDeleteAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<DeleteAccountBloc>(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
              listener: (blocContext, state) async {
                // Capture messenger BEFORE pop
                final messenger = ScaffoldMessenger.of(context);

                if (state is DeleteAccountSuccess) {
                  Navigator.pop(ctx); // close bottom sheet

                  await SessionManager.clearSession(context);

                  messenger.showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }

                if (state is DeleteAccountFailure) {
                  messenger.showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Delete Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.redPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Are you sure you want to delete your account? This action cannot be undone.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    if (state is DeleteAccountLoading)
                      const CircularProgressIndicator()
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("NO"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.redPrimary,
                              ),
                              onPressed: () async {
                                final isGuest = await TokenStorage.isGuest();

                                if (isGuest) {
                                  // 👤 Guest → frontend-only delete
                                  Navigator.pop(ctx);
                                  await SessionManager.clearSession(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Guest account cleared"),
                                    ),
                                  );
                                } else {
                                  // 🔐 Logged-in → API delete via Bloc
                                  context.read<DeleteAccountBloc>().add(
                                    DeleteAccountRequested(),
                                  );
                                }
                              },
                              child: const Text("YES"),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(_ProfileOption option) {
    return InkWell(
      onTap: option.ontap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: option.title == 'Favorites'
                  ? AppColors.redAccent
                  : AppColors.blackColor,
              size: 20.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: _textStyle(14.sp, FontWeight.w500)),
                  SizedBox(height: 2.h),
                  Text(
                    option.subtitle,
                    style: _textStyle(
                      12.sp,
                      FontWeight.normal,
                      Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  TextStyle _textStyle(double size, FontWeight weight, [Color? color]) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color ?? Colors.black,
      fontFamily: 'Poppins',
    );
  }
}

class _ProfileOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback ontap;

  _ProfileOption(this.icon, this.title, this.subtitle, {required this.ontap});
}
