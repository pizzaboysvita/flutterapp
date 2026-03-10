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
import 'package:pizza_boys/data/models/user/profile_model.dart';
import 'package:pizza_boys/data/repositories/profile/user_repo.dart';
import 'package:pizza_boys/data/services/profile/user_service.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/profile/bloc/user_info_cubit.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Profile extends StatelessWidget {
  final ScrollController scrollController;
  const Profile({super.key, required this.scrollController});

  @override 
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<UserCubit>().loadUser();
  });
    return BlocProvider(
      create: (_) => DeleteAccountBloc(UserRepo(UserService())),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          title: Text.rich(
            TextSpan(
              text: 'User',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
              onPressed: () => _showLogoutConfirmationDialog(context),
            ),
            SizedBox(width: 6.w),
            BlocBuilder<UserCubit, UserModel>(
              builder: (context, user) {
                bool isGuest = user.firstName.isEmpty || user.email.isEmpty;

                if (isGuest) return const SizedBox.shrink();

                return Builder(
                  builder: (innerContext) => IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: AppColors.redPrimary,
                    ),
                    onPressed: () => _showDeleteAccountSheet(innerContext),
                  ),
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
            _UserCard(),
            SizedBox(height: 20.h),
            ..._ProfileOptions(context),
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
                final messenger = ScaffoldMessenger.of(context);

                if (state is DeleteAccountSuccess) {
                  Navigator.pop(ctx);
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
                                  Navigator.pop(ctx);
                                  await SessionManager.clearSession(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Guest account cleared"),
                                    ),
                                  );
                                } else {
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

  List<Widget> _ProfileOptions(BuildContext context) {
    final options = [
      _ProfileOption(
        FontAwesomeIcons.solidClock,
        "Order History",
        "View past orders and reorder quickly",
        ontap: () => Navigator.pushNamed(
          context,
          AppRoutes.orderHistory,
          arguments: false,
        ),
      ),
      _ProfileOption(
        FontAwesomeIcons.solidHeart,
        "Wishlist",
        "View and manage your saved items",
        ontap: () => Navigator.pushNamed(context, AppRoutes.favorites),
      ),
    ];

    return options.map((e) => _ProfileListTile(e)).toList();
  }
}

// ------------------- USER CARD -------------------
class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserModel>(
      builder: (context, user) {
        print('user.profile: ${user.profile}');
        bool isGuest = user.firstName.isEmpty || user.email.isEmpty;
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.redPrimary,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(
                  user.profile.isNotEmpty
                      ? user.profile
                      : "https://i.pravatar.cc/300",
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.firstName.isNotEmpty && user.lastName.isNotEmpty
                          ? "${user.firstName} ${user.lastName}"
                          : "Guest User",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.email.isNotEmpty ? user.email : "guest@gmail.com",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isGuest)
                InkWell(
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.profileEdit);
                    context.read<UserCubit>().loadUser();
                  },
                  child: Icon(
                    FontAwesomeIcons.edit,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ------------------- PROFILE LIST TILE -------------------
class _ProfileListTile extends StatelessWidget {
  final _ProfileOption option;
  const _ProfileListTile(this.option);

  @override
  Widget build(BuildContext context) {
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
            Icon(option.icon, color: AppColors.blackColor, size: 20.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    option.subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
}

class _ProfileOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback ontap;
  _ProfileOption(this.icon, this.title, this.subtitle, {required this.ontap});
}
