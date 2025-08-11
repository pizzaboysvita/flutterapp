import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/search/bloc/search_bloc.dart';
import 'package:pizza_boys/features/search/bloc/search_event.dart';
import 'package:pizza_boys/features/search/bloc/search_state.dart';

class SearchView extends StatefulWidget {
  final bool showBackBtn;
  const SearchView({super.key, this.showBackBtn = true});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _suggestedItems = [
    {
      'name': 'M and M Pizza',
      'price': 11.99,
      'image': ImageUrls.catergoryPizza,
      'rating': 4.4,
    },
    {
      'name': 'Chipotle Chicken Pizza',
      'price': 10.49,
      'image': ImageUrls.catergoryPizza,
      'rating': 4.6,
    },
    {
      'name': 'Melting Hot Pizza',
      'price': 12.99,
      'image': ImageUrls.catergoryPizza,
      'rating': 4.3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: widget.showBackBtn,
        title: Text.rich(
          TextSpan(
            text: 'Search',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: ' Pizzas',
                style: TextStyle(color: AppColors.redAccent),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar inside body
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      context.read<SearchBloc>().add(
                        AddRecentSearchEvent(value.trim()),
                      );
                    }
                  },
                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: 'Search for pizzas, combos...',
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Recent Searches via BLoC
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.recentSearches.isEmpty) return SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Searches',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        children: state.recentSearches
                            .map(
                              (item) => Chip(
                                label: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                onDeleted: () {
                                  context.read<SearchBloc>().add(
                                    RemoveRecentSearchEvent(item),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  );
                },
              ),

              // Suggested Section
              Text(
                'Suggested For You',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 12.h),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _suggestedItems.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final item = _suggestedItems[index];
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            item['image'],
                            height: 70.h,
                            width: 70.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${item['rating']}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    '\$${item['price']}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.favorite_border, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
