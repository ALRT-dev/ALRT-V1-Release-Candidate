import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/family/repositories/family_repository.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/send_to_group_sheet.dart';

class MissingShareEndpoint implements FamilyRepository {
  @override
  Future<Either<void,AppError>> shareHazardWithCircle({required String circleId,required String hazardId,String? note}) async => const Failure(AppError(message:'Not found',code:'404'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class RecordingFamily extends FamilyProvider {
  RecordingFamily(Ref ref):super(ref:ref,bootstrap:false,state:const FamilyProviderState(
    circles:[FamilyCircleSummary(circleId:'one',name:'One',myMemberId:'me'),FamilyCircleSummary(circleId:'two',name:'Two',myMemberId:'me2')]));
  int checkIns=0;
  @override
  Future<void> checkIn({FamilyCheckInStatus status=FamilyCheckInStatus.safe,String? message,required bool shareLocation,String? hazardId}) async {
    checkIns++;
    state=state.copyWith(checkInState:const FamilyActionState.success());
  }
}
void main(){
  testWidgets('404 alert send fails without substituting a check-in to any group', (tester) async {
    late RecordingFamily family;
    bool? result;
    await tester.pumpWidget(ProviderScope(overrides:[
      providerOfFamilyRepository.overrideWithValue(MissingShareEndpoint()),
      providerOfFamily.overrideWith((ref)=>family=RecordingFamily(ref)),
    ],child:ScreenUtilInit(designSize:const Size(375,812),builder:(_,__)=>MaterialApp(home:Scaffold(body:Builder(builder:(context)=>TextButton(
      onPressed:() async {result=await showSendToGroupSheet(context:context,hazard:const Hazard(id:'alert',title:'Fire'),circleId:'one',circleName:'One');},child:const Text('Open'))))))));
    await tester.tap(find.text('Open'));await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));await tester.pumpAndSettle();
    expect(result,isFalse);
    // No Family provider is needed at all for a plain alert send.
    // Read it only now to demonstrate it has received no fallback action.
    final context=tester.element(find.text('Open'));
    ProviderScope.containerOf(context).read(providerOfFamily);
    expect(family.checkIns,0);
  });
}
