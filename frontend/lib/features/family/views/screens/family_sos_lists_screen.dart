import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_sos_list_edit_screen.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_kit.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Who your SOS reaches" (SOSLists board): the note, one card per saved
/// list (name, Default pill, how many people, "needs repair" when a list
/// must be fixed) and the indigo "New list".
///
/// With no default list an SOS goes to the whole group it is sent from;
/// a list becomes the default from its editor ("Use as my default").
class FamilySosListsScreen extends ConsumerStatefulWidget {
  const FamilySosListsScreen({super.key});

  static const route = '/family-sos-lists';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamilySosListsScreenState();
}

class _FamilySosListsScreenState extends ConsumerState<FamilySosListsScreen> {
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

    return FamilyBoardScaffold(
      title: 'Who your SOS reaches',
      gap: 10,
      children: [
        const FamilyBoardNote(
          'Set your lists here so you never choose in an emergency. One '
          'group per list, up to 4 lists.',
        ),
        for (final list in lists) _listCardBuilder(list),
        FamilyBoardPrimaryButton(
          key: const Key('sos-list-new'),
          label: 'New list',
          indigo: true,
          onPressed: () => context.push(
            FamilySosListEditScreen.route,
            extra: const FamilySosListEditScreenArgs(),
          ),
        ),
      ],
    );
  }

  Widget _listCardBuilder(final FamilySosList list) {
    final count = list.memberIds.length;
    final people = '$count ${count == 1 ? 'person' : 'people'}';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.spMin),
      child: InkWell(
        key: Key('sos-list-${list.id}'),
        borderRadius: BorderRadius.circular(18.spMin),
        onTap: () => context.push(
          FamilySosListEditScreen.route,
          extra: FamilySosListEditScreenArgs(list: list),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.spMin),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.spMin,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          list.name,
                          style: TextStyle(
                            fontSize: 16.spMin,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        if (list.isDefault) const FamilyBoardPill('Default'),
                      ],
                    ),
                    SizedBox(height: 2.spMin),
                    FamilyBoardMuted(
                      list.needsRepair != null
                          ? '$people · needs repair'
                          : people,
                      size: 12,
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18.spMin,
                color: AppColors.mediumGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
