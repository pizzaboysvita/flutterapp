import 'dart:io';

abstract class UserEvent {}

class UpdateUserEvent extends UserEvent {
  final Map<String, dynamic>? fields;
  final File? image;

  UpdateUserEvent({this.fields, this.image});
}
