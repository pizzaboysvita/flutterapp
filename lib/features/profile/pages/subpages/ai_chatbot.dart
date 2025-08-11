import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class AIChatBot extends StatefulWidget {
  const AIChatBot({super.key});

  @override
  State<AIChatBot> createState() => _AIChatBotState();
}

class _AIChatBotState extends State<AIChatBot> {
  final List<Map<String, String>> messages = [
    {'from': 'bot', 'text': 'Hello! 👋 How can I assist you today?'},
    {
      'from': 'bot',
      'text': 'You can ask about orders, payments, or general help.',
    },
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isBotTyping = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'from': 'user', 'text': text});
      isBotTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      String reply = "I'm not sure I understand. Could you please elaborate?";
      final lowerText = text.toLowerCase();

      if (lowerText.contains('pizza') || lowerText.contains('order')) {
        reply =
            "It looks like you're having an issue with your pizza order.\n\n"
            "Call: +91-99999XXXXX\n"
            "Email: support@pizzaboys.com";
      } else if (lowerText.contains('payment')) {
        reply =
            "Payment issues can be frustrating!\n"
            "Please try refreshing the payment page or contact:\n"
            "Email: billing@pizzaboys.com";
      } else if (lowerText.contains('delivery')) {
        reply =
            "Delivery delays happen sometimes.\nYou can track your order in the 'My Orders' section.";
      } else if (lowerText.contains('cancel')) {
        reply =
            "To cancel an order, go to your order history and click 'Cancel'.\n\n"
            "Cal: +91-88888XXXXX";
      } else if (lowerText.contains('refund')) {
        reply =
            "We’ll process your refund within 3–5 days.\nEmai: refund@pizzaboys.com";
      }

      setState(() {
        messages.add({'from': 'bot', 'text': reply});
        isBotTyping = false;
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            text: 'AI',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppColors.blackColor,
            ),
            children: [
              TextSpan(
                text: ' ChatBot',
                style: TextStyle(
                  color: AppColors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: messages.length + (isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isBotTyping && index == messages.length) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.w, top: 6.h),
                        child: CircleAvatar(
                          radius: 16.r,
                          backgroundColor: AppColors.blackColor.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            FontAwesomeIcons.robot,
                            color: AppColors.redAccent,
                            size: 14.sp,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        constraints: BoxConstraints(maxWidth: 280.w),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14.r),
                            topRight: Radius.circular(14.r),
                            bottomRight: Radius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Typing...',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final msg = messages[index];
                final isUser = msg['from'] == 'user';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w, top: 6.h),
                        child: CircleAvatar(
                          radius: 16.r,
                          backgroundColor: AppColors.redAccent.withOpacity(0.1),
                          child: Icon(
                            FontAwesomeIcons.robot,
                            color: AppColors.redAccent,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      constraints: BoxConstraints(maxWidth: 280.w),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.white : AppColors.whiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(14.r),
                          topRight: Radius.circular(14.r),
                          bottomLeft: Radius.circular(isUser ? 14.r : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 14.r),
                        ),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: isUser ? Colors.black87 : Colors.black,
                        ),
                      ),
                    ),
                    if (isUser)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w, top: 6.h),
                        child: CircleAvatar(
                          radius: 16.r,
                          backgroundColor: AppColors.blackColor.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            FontAwesomeIcons.solidUser,
                            size: 14.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: AppColors.blackColor,
                    radius: 22.r,
                    child: Icon(
                      FontAwesomeIcons.paperPlane,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
