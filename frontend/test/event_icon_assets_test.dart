import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/event_icon_assets.dart';

void main() {
  test('lookup keys match the keys the loader writes', () {
    expect(
      EventIconAssets.bitmapKey('aws/bushfire_action'),
      EventIconAssets.lookupKey(
        isAws: true,
        categoryId: 'bushfire',
        bandName: 'action',
      ),
    );
    expect(
      EventIconAssets.bitmapKey('non_aws/crash_critical'),
      EventIconAssets.lookupKey(
        isAws: false,
        categoryId: 'crash',
        bandName: 'critical',
      ),
    );
  });

  test('only artwork in the locked band colours is listed', () {
    expect(EventIconAssets.names.contains('aws/bushfire_info'), isFalse);
    expect(EventIconAssets.names.contains('non_aws/powerOutage_info'), isTrue);
    expect(EventIconAssets.names.contains('non_aws/crash_action'), isTrue);
  });
}
