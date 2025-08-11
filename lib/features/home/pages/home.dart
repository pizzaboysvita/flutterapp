import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/reusable_widgets/dialogs/offers_popup.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/home/widgets/accordian.dart';
import 'package:pizza_boys/features/home/widgets/dashboard_hero.dart';
import 'package:pizza_boys/features/home/widgets/popular_picks.dart';
import 'package:pizza_boys/features/home/widgets/promotional_banner.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Home extends StatefulWidget {
  final ScrollController scrollController;

  const Home({super.key, required this.scrollController});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  bool _hasShownPopup = false;
  bool _isFabVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Show popups only once after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownPopup) {
        _hasShownPopup = true;
        showSequentialPopups(context);
      }
    });

    widget.scrollController.addListener(() {
      final direction = widget.scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      } else if (direction == ScrollDirection.forward && !_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "PIZZA ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: "BOYZ",
                    style: TextStyle(
                      color: AppColors.redAccent,
                      fontSize: 18.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconAccordion(),
          SizedBox(width: 6.0.w),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              controller: widget.scrollController,
              children: [
                Column(
                  children: [
                    const DashboardHeroSection(),
                    SizedBox(height: 20.h),
                    const PizzaCategoriesRow(),
                    SizedBox(height: 20.h),
                    const PromotionalBanner(),
                    SizedBox(height: 20.h),
                    const PopularPicks(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ],
            ),

            // Floating Search Button
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isFabVisible ? 1 : 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.searchView);
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.black, Color(0xFFB71C1C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(FontAwesomeIcons.search, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
