import 'dart:io';

String getFriendlyErrorMessage(Object error) {
  if (error is SocketException) {
    return "No internet connection. Please check your network.";
  } else if (error is HttpException) {
    return "Server error occurred. Please try again later.";
  } else if (error is FormatException) {
    return "Data format error. Please contact support.";
  } else if (error.toString().contains("ClientException")) {
    return "Server is unreachable. Please try again later.";
  } else {
    return "Something went wrong. Please try again.";
  }
}
