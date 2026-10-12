import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/providers/profile_provider.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Opens the "Edit profile" sheet from the Me tab (the avatar and the Edit
/// link both land here). Photo, display name, the read-only sign-in email
/// and a link to the home region for alerts.
Future<void> showEditProfileSheet(final BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) => const EditProfileSheet(),
  );
}

/// The display name a Save will send, or null when nothing should be
/// sent: blank input, or the same name the account already has. Pure, so
/// the rule is testable without a widget.
String? displayNameToSave({
  required final String input,
  required final String? current,
}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed == (current ?? '').trim()) return null;
  return trimmed;
}

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  static const _muted = Color(0xFF5C5C66);
  static const _hairline = Color(0xFFE3E6EA);
  static const _field = Color(0xFFF5F5F7);
  static const _danger = Color(0xFFDA1F2D);

  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(providerOfLoggedInUser)?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(providerOfLoggedInUser);
    final photo = ref.watch(
      providerOfProfile.select((s) => s.profilePicture),
    );
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.spMin, 12.spMin, 20.spMin, 16.spMin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: 16.spMin),
                Center(child: _buildAvatar(user: user, photo: photo)),
                SizedBox(height: 20.spMin),
                _buildLabel('Display name'),
                SizedBox(height: 6.spMin),
                TextField(
                  key: const Key('edit-profile-name'),
                  controller: _nameController,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: 60,
                  onSubmitted: (_) => _save(),
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Your name',
                    filled: true,
                    fillColor: _field,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.spMin,
                      vertical: 14.spMin,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                      borderSide: const BorderSide(color: _hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                      borderSide: const BorderSide(color: _hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                      borderSide: const BorderSide(
                        color: AppColors.orange,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.spMin),
                _buildLabel('Email'),
                SizedBox(height: 6.spMin),
                _buildInfoRow(
                  icon: LucideIcons.mail,
                  text: '${user?.email ?? 'No email'} · from your sign-in',
                ),
                SizedBox(height: 14.spMin),
                _buildLabel('Home region for alerts'),
                SizedBox(height: 6.spMin),
                _buildInfoRow(
                  icon: LucideIcons.mapPin,
                  text: user?.locationName ?? 'Saved places',
                  trailing: Icon(
                    LucideIcons.chevronRight,
                    size: 18.spMin,
                    color: _muted,
                  ),
                  onTap: _openSavedPlaces,
                ),
                SizedBox(height: 22.spMin),
                SizedBox(
                  height: 52.spMin,
                  child: FilledButton(
                    key: const Key('edit-profile-save'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      disabledBackgroundColor: AppColors.orange.withValues(
                        alpha: 0.5,
                      ),
                      foregroundColor: AppColors.white,
                      disabledForegroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.spMin),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? SizedBox(
                            width: 22.spMin,
                            height: 22.spMin,
                            child: const CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 15.spMin,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 4.spMin),
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: _muted),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Edit profile',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          icon: Icon(LucideIcons.x, size: 22.spMin, color: AppColors.black),
        ),
      ],
    );
  }

  /// 64 px avatar: the photo when there is one, else initials on the brand
  /// gradient, with a small orange pencil badge that opens the photo
  /// picker.
  Widget _buildAvatar({
    required final AppUser? user,
    required final AlrtMedia? photo,
  }) {
    final size = 64.spMin;
    final media = photo ?? user?.processedProfilePicture;
    return SizedBox(
      width: size + 8.spMin,
      height: size + 8.spMin,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.orange300, AppColors.red200],
              ),
            ),
            child: _buildAvatarContent(media: media, user: user),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 26.spMin,
              height: 26.spMin,
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: Icon(
                LucideIcons.pencil,
                size: 13.spMin,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    ).onPressed(_saving ? null : _showPhotoPicker);
  }

  Widget _buildAvatarContent({
    required final AlrtMedia? media,
    required final AppUser? user,
  }) {
    if (media != null) {
      switch (media.source) {
        case AlrtMediaSource.file:
          return Image.file(File(media.value), fit: BoxFit.cover);
        case AlrtMediaSource.networkUrl:
          return Image.network(
            media.value,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitials(user),
          );
        case AlrtMediaSource.asset:
          return Image.asset(media.value, fit: BoxFit.cover);
      }
    }
    return _buildInitials(user);
  }

  Widget _buildInitials(final AppUser? user) {
    return Center(
      child: Text(
        user?.initials ?? 'U',
        style: TextStyle(
          fontSize: 26.spMin,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildLabel(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w700,
        color: _muted,
      ),
    );
  }

  Widget _buildInfoRow({
    required final IconData icon,
    required final String text,
    final Widget? trailing,
    final VoidCallback? onTap,
  }) {
    final row = Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 13.spMin),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: _hairline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.spMin, color: _muted),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.spMin,
                color: AppColors.black,
              ),
            ),
          ),
          if (trailing != null) ...[SizedBox(width: 8.spMin), trailing],
        ],
      ),
    );
    return onTap == null ? row : row.onPressed(onTap);
  }

  /// The photo picker that used to be the whole "Edit" action: Take photo,
  /// Choose from library, Remove photo. Each one goes through the profile
  /// provider's existing PUT / DELETE profile-picture calls.
  void _showPhotoPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.spMin),
              child: Text(
                'Edit photo',
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.black),
              title: Text(
                'Take photo',
                style:
                    TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: AppColors.black),
              title: Text(
                'Choose from library',
                style:
                    TextStyle(fontSize: 15.spMin, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref
                    .read(providerOfProfile.notifier)
                    .updateProfilePicture(source: ImageSource.gallery);
              },
            ),
            if (ref.read(providerOfLoggedInUser)?.processedProfilePicture !=
                null)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: _danger),
                title: Text(
                  'Remove photo',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ref.read(providerOfProfile.notifier).deleteProfilePicture();
                },
              ),
            SizedBox(height: 8.spMin),
          ],
        ),
      ),
    );
  }

  /// The home region is the own-location follow in Saved places, so the
  /// row goes there (the Notifications screen scrolls to its Saved places
  /// card for initialTab 1).
  void _openSavedPlaces() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(
      ManageNotificationsScreen.route,
      extra: const ManageNotificationsScreenArgs(initialTab: 1),
    );
  }

  /// PUT /api/user with the current user plus the new name, through the
  /// existing user service; the logged-in-user provider is then refreshed
  /// from the server's answer (keeping the locally picked photo).
  Future<void> _save() async {
    if (_saving) return;
    final current = ref.read(providerOfLoggedInUser);
    final name = displayNameToSave(
      input: _nameController.text,
      current: current?.name,
    );
    if (name == null) {
      if (_nameController.text.trim().isEmpty) {
        context.showErrorToast(message: 'Enter a display name.');
        return;
      }
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    final result = await ref
        .read(providerOfUserService)
        .updateCurrentUser(user: (current ?? const AppUser()).copyWith(name: name));
    if (!mounted) return;
    setState(() => _saving = false);

    result.when(
      (updated) {
        ref.read(providerOfLoggedInUser.notifier).update(
              (user) => updated.copyWith(
                name: updated.name ?? name,
                processedProfilePicture: user?.processedProfilePicture ??
                    updated.processedProfilePicture,
              ),
            );
        context.showSuccessToast(message: 'Profile saved.');
        Navigator.of(context).pop();
      },
      (error) {
        context.showErrorToast(
          message: error.message.isEmpty
              ? 'Could not save your profile. Please try again.'
              : error.message,
        );
      },
    );
  }
}
