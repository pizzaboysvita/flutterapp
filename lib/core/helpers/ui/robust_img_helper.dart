import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class RobustImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const RobustImage({
    required this.imageUrl,
    this.width,
    this.height,
    super.key,
  });

  @override
  State<RobustImage> createState() => _RobustImageState();
}

class _RobustImageState extends State<RobustImage> {
  int retryCount = 0;
  final int maxRetry = 3;

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl.isNotEmpty
          ? widget.imageUrl
          : "https://via.placeholder.com/150",
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) {
        if (retryCount < maxRetry) {
          retryCount++;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() {}); // retry
          });
          return _buildShimmer(); // show shimmer while retrying
        } else {
          return Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        }
      },
    );
  }
}
