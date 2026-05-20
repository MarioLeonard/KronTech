import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_photo_picker_card_state.dart';

class ProfilePhotoPickerCard extends StatefulWidget {
  const ProfilePhotoPickerCard({
    super.key,
    required this.value,
    required this.onChanged,
    this.fallbackPhotoUrl,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? fallbackPhotoUrl;
  final String? errorText;

  @override
  State<ProfilePhotoPickerCard> createState() => _ProfilePhotoPickerCardState();
}
