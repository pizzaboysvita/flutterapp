import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/features/search/bloc/search_bloc.dart';
import 'package:pizza_boys/features/search/bloc/search_event.dart';
import 'package:pizza_boys/features/search/bloc/search_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class SearchView extends StatefulWidget {
  final bool showBackBtn;
  const SearchView({super.key, this.showBackBtn = true});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  int storeId = -1;
  String query = "";

  @override
  void initState() {
    super.initState();
    _loadStoreId();
  }

  Future<void> _loadStoreId() async {
    final storeIdStr = await TokenStorage.getChosenStoreId();
    setState(() {
      storeId = int.tryParse(storeIdStr ?? "-1") ?? -1;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      query = value.trim();
    });
    if (query.isNotEmpty && storeId != -1) {
      context.read<SearchBloc>().add(SearchQueryChanged(query, storeId));
    }
  }

  Widget _buildRecentSearches(List<String> recent) {
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Searches",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: recent.map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () {
                _searchController.text = term;
                _onSearchChanged(term);
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSuggestions() {
    final suggestions = ["Pizza", "Chicken Pizza", "Cheesy Pizza", "Tandoori Pizza"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Popular Searches",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: suggestions.map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () {
                _searchController.text = term;
                _onSearchChanged(term);
              },
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          "No results found",
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final dish = results[index];
        return InkWell(
          onTap: () {
           Navigator.pushNamed(
      context,
      AppRoutes.pizzaDetails,
      arguments: dish["dish_id"], // pass the selected dish's ID
    );
    print("🔹 Navigating to details of dish ID: ${dish["dish_id"]}");
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    dish["dish_image"] ?? ImageUrls.catergoryPizza,
                    height: 70.h,
                    width: 70.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish["dish_name"] ?? "Unknown Dish",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "₹${dish["dish_price"] ?? "--"}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBody(SearchState state) {
    if (query.isNotEmpty) {
      if (state.isLoading)
        return const Center(child: CircularProgressIndicator());
      if (state.error != null) return Center(child: Text("❌ ${state.error}"));
      return _buildSearchResults(state.results);
    }

    // Show recent or suggestions
    if (state.recentSearches.isNotEmpty) {
      return SingleChildScrollView(
        child: _buildRecentSearches(state.recentSearches),
      );
    }

    return SingleChildScrollView(child: _buildSuggestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.read<SearchBloc>().add(AddRecentSearchEvent(value));
                  _onSearchChanged(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search for pizzas, combos...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // BlocBuilder for dynamic results / recent searches / suggestions
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) => _buildSearchBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
