part of 'profile_photo_picker_card.dart';

class _ProfilePhotoPickerCardState extends State<ProfilePhotoPickerCard> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImage() async {
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 72,
      );
      if (image == null) {
        return;
      }

      final bytes = await image.readAsBytes();
      final mimeType = image.mimeType ?? _mimeTypeFromName(image.name);
      widget.onChanged('data:$mimeType;base64,${base64Encode(bytes)}');
    } catch (error) {
      debugPrint('Failed to pick profile photo: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = widget.value.trim().isNotEmpty;
    final fallbackPhotoUrl = widget.fallbackPhotoUrl?.trim() ?? '';
    final hasFallbackPhoto = fallbackPhotoUrl.isNotEmpty;
    final photoBytes = hasPhoto ? _bytesFromDataUrl(widget.value) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.errorText == null
                  ? Colors.white
                  : theme.colorScheme.error,
              width: widget.errorText == null ? 1 : 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                SizedBox.square(
                  dimension: 140,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.28,
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: photoBytes != null
                          ? Image.memory(photoBytes, fit: BoxFit.cover)
                          : hasFallbackPhoto
                          ? Image.network(
                              fallbackPhotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const Icon(
                                  Icons.person_outline_rounded,
                                  size: 58,
                                  color: Colors.white,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person_outline_rounded,
                              size: 58,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isPicking ? null : _pickImage,
                    icon: _isPicking
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            hasPhoto
                                ? Icons.edit_outlined
                                : Icons.photo_camera_outlined,
                          ),
                    label: Text(hasPhoto ? 'Change photo' : 'Select photo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                if (hasPhoto) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _isPicking ? null : () => widget.onChanged(''),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove selected photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Uint8List? _bytesFromDataUrl(String value) {
    final commaIndex = value.indexOf(',');
    if (!value.startsWith('data:image/') || commaIndex == -1) {
      return null;
    }

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  String _mimeTypeFromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
