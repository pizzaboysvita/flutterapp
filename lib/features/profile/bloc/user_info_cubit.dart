import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/models/user/profile_model.dart';
import 'package:pizza_boys/data/repositories/profile/user_repo.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class UserCubit extends Cubit<UserModel> {
  final UserRepo repo;
  UserCubit(this.repo) : super(UserModel.empty());

  /// Load user data from TokenStorage
  Future<void> loadUser() async {
    final name = await TokenStorage.getName();
    final email = await TokenStorage.getEmail();
    final profile = await TokenStorage.getProfile();

    final split = (name ?? "").split(" ");
    emit(
      UserModel(
        firstName: split.isNotEmpty ? split.first : "",
        lastName: split.length > 1 ? split.sublist(1).join(" ") : "",
        email: email ?? "",
        profile: profile ?? "",
        userId: '',
        roleId: '',
        phoneNumber: '',
        refreshToken: '',
        permissions: {},
      ),
    );
  }

  /// Update user data safely
  Future<void> updateUser({Map<String, dynamic>? fields, File? image}) async {
    debugPrint(
      "🔹 Cubit: updateUser called with fields: $fields, image: ${image?.path}",
    );

    final response = await repo.updateUser(
      updatedFields: fields,
      imageFile: image,
    );

    debugPrint("🔹 Cubit: API response received: ${response.data}");

    // Decode JSON safely
    final data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    final code = int.tryParse("${data["code"]}") ?? 0; // Convert to int safely
    final message = data["message"] ?? "Unknown error";

    if (code == 1) {
      debugPrint("✅ Cubit: User update successful");

      // Extract updated user from server response
      final updatedUser = data['user'] ?? {};

      // Save updated fields locally
      await TokenStorage.saveUpdatedUserDetails(
        firstName: updatedUser['first_name'] ?? fields?['first_name'],
        lastName: updatedUser['last_name'] ?? fields?['last_name'],
        email: updatedUser['email'] ?? fields?['email'],
        profile: updatedUser['profiles'] ?? state.profile,
      );

      // Emit updated UserModel directly for instant UI refresh
      final nameSplit =
          (updatedUser['first_name'] ??
                  fields?['first_name'] ??
                  state.firstName)
              .split(" ");
      final lastName =
          updatedUser['last_name'] ?? fields?['last_name'] ?? state.lastName;

      emit(
        UserModel(
          firstName: nameSplit.isNotEmpty ? nameSplit.first : state.firstName,
          lastName: lastName.isNotEmpty ? lastName : state.lastName,
          email: updatedUser['email'] ?? fields?['email'] ?? state.email,
          profile: updatedUser['profiles'] ?? state.profile,
          userId: state.userId,
          roleId: state.roleId,
          phoneNumber: state.phoneNumber,
          refreshToken: state.refreshToken,
          permissions: state.permissions,
        ),
      );
    } else {
      debugPrint("❌ Cubit: User update failed: $message");
      throw Exception(message);
    }
  }


}
