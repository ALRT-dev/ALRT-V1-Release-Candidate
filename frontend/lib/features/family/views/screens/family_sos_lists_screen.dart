import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';

/// Who your SOS reaches: the saved lists, set up calmly in advance.
///
/// The entire point of this screen is stated in its subtitle — you decide
/// here so you never have to choose in an emergency. "Everyone" is not a
/// stored list but the built-in default: an SOS with no list picked goes to
/// the whole selected group, so it is pinned first and wears the DEFAULT
/// badge whenever no saved list has claimed it.
class FamilySosListsScreen extends ConsumerStatefulWidget {
  const FamilySosListsScreen({super.key});

  static const route = '/family-sos-lists';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilySosListsScreenState();
}

class _FamilySosListsScreenState extends ConsumerState<FamilySosListsScreen> {
  static const _page = Color(0xFFF5F2F7);
  static const _red = Color(0xFFE03A2F);
  static const _redBadgeBackground = Color(0xFFFDEAE8);
  static const _defaultRowBackground = Color(0xFFFFF6F5);
  static const _dashedBorder = Color(0xFFF5C4BE);
  static const _noteBackground = Color(0xFFF6ECFA);
  static const _noteBorder = Color(0xFFECD9F4);
  static const _noteInk = Color(0xFF8E4AA6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(providerOfFamily.notifier).loadSosLists(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(providerOfFamily.select((s) => s.sosLists));
    final circleName = ref.watch(
      providerOfFamily.select((s) => s.circle?.name ?? 'your group'),
    );
    final hasDefaultList = lists.any((l) => l.isDefault);

    return Scaffold(
      backgroundColor: _page,
      appBar: const FamilyAppBar(
        title: 'Who your SOS reaches',
        subtitle: 'Set your lists here so you never choose in an emergency',
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 40.spMin),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 15.spMin, 16.spMin, 7.spMin),
            child: Text(
              'YOUR LISTS',
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: _red,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.spMin),
              boxShadow: [
                BoxShadow(
                  color: FamilyColors.v31CardShadow,
                  blurRadius: 10.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _everyoneRowBuilder(
                  circleName: circleName,
                  isDefault: !hasDefaultList,
                ),
                for (final list in lists) ...[
                  const Divider(height: 1, color: FamilyColors.v31Divider),
                  _listRowBuilder(list),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.spMin, 9.spMin, 16.spMin, 0),
            child: _addListButtonBuilder(),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16.spMin, 12.spMin, 16.spMin, 0),
            padding: EdgeInsets.symmetric(
              horizontal: 14.spMin,
              vertical: 11.spMin,
            ),
            decoration: BoxDecoration(
              color: _noteBackground,
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(color: _noteBorder),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Lists never auto-switch. ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        'Recipients change only by explicit action, and '
                        'anyone who leaves a group drops off every list '
                        'automatically.',
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.65,
                color: _noteInk,
              ),
            ),
          ),
          ],
        ),
    );
  }

  /// The built-in default: no list means the whole selected group.
  Widget _everyoneRowBuilder({
    required final String circleName,
    required final bool isDefault,
  }) {
    return InkWell(
      onTap: isDefault ? null : _makeEveryoneDefault,
      child: Container(
        color: isDefault ? _defaultRowBackground : null,
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 13.spMin,
        ),
        child: Row(
          children: [
            _radioBuilder(isSelected: isDefault),
            SizedBox(width: 11.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Everyone',
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Your whole group at the time you send',
                    style: TextStyle(
                      fontSize: 10.5.spMin,
                      color: FamilyColors.v31Ink,
                    ),
                  ),
                ],
              ),
            ),
            if (isDefault) _defaultBadgeBuilder(),
          ],
        ),
      ),
    );
  }

  Widget _listRowBuilder(final FamilySosList list) {
    return InkWell(
      onTap: () => context.push(
        FamilySosListEditScreen.route,
        extra: FamilySosListEditScreenArgs(list: list),
      ),
      child: Container(
        color: list.isDefault ? _defaultRowBackground : null,
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 13.spMin,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: list.isDefault ? null : () => _makeDefault(list),
              child: _radioBuilder(isSelected: list.isDefault),
            ),
            SizedBox(width: 11.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${list.memberIds.length} '
                    '${list.memberIds.length == 1 ? 'person' : 'people'}',
                    style: TextStyle(
                      fontSize: 10.5.spMin,
                      color: FamilyColors.v31Ink,
                    ),
                  ),
                ],
              ),
            ),
            if (list.isDefault)
              _defaultBadgeBuilder()
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18.spMin,
                color: const Color(0xFFC6C3CC),
              ),
          ],
        ),
      ),
    );
  }

  Widget _radioBuilder({required final bool isSelected}) {
    return Container(
      width: 19.spMin,
      height: 19.spMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _red : const Color(0xFFDDD9E2),
          width: 2,
        ),
      ),
      child: isSelected
          ? Container(
              width: 9.spMin,
              height: 9.spMin,
              decoration: const BoxDecoration(
                color: _red,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  Widget _defaultBadgeBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 4.spMin),
      decoration: BoxDecoration(
        color: _redBadgeBackground,
        borderRadius: BorderRadius.circular(12.spMin),
      ),
      child: Text(
        'DEFAULT',
        style: TextStyle(
          fontSize: 10.spMin,
          fontWeight: FontWeight.w800,
          color: _red,
        ),
      ),
    );
  }

  Widget _addListButtonBuilder() {
    return GestureDetector(
      onTap: () => context.push(
        FamilySosListEditScreen.route,
        extra: const FamilySosListEditScreenArgs(),
      ),
      child: Container(
        height: 42.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(color: _dashedBorder, width: 1.5),
        ),
        child: Text(
          '+ Add a list',
          style: TextStyle(
            fontSize: 12.5.spMin,
            fontWeight: FontWeight.w800,
            color: _red,
          ),
        ),
      ),
    );
  }

  void _makeDefault(final FamilySosList list) {
    ref
        .read(providerOfFamily.notifier)
        .saveSosList(
          sosListId: list.id,
          name: list.name,
          memberIds: list.memberIds,
          isDefault: true,
        );
  }

  /// Everyone is the default exactly when no saved list is; un-defaulting
  /// the current one restores it.
  void _makeEveryoneDefault() {
    final current = ref
        .read(providerOfFamily)
        .sosLists
        .where((l) => l.isDefault)
        .firstOrNull;
    if (current == null) return;
    ref
        .read(providerOfFamily.notifier)
        .saveSosList(
          sosListId: current.id,
          name: current.name,
          memberIds: current.memberIds,
          isDefault: false,
        );
  }
}
