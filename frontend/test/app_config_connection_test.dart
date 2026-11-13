import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/providers/app_config_provider.dart';
import 'package:hazard_app/features/shared/services/severity_labels.dart';

class _ConfigAdapter implements HttpClientAdapter {
  Uri? requested;
  bool fail = false;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requested = options.uri;
    if (fail) throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
    return ResponseBody.fromString('{"severityLabels":{"advice":"TEST advice"}}', 200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}

void main() {
  tearDown(() => SeverityLabels.update({}));
  test('fetches labels from the selected TEST origin without authenticating', () async {
    final adapter = _ConfigAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    await fetchAppConfig(baseUrl: 'https://api-test.safetyalrt.com', client: dio);
    expect(adapter.requested.toString(), 'https://api-test.safetyalrt.com/api/app/config');
    expect(SeverityLabels.advice(), 'TEST advice');
  });
  test('connection failure leaves existing labels usable', () async {
    SeverityLabels.update({'advice': 'Existing advice'});
    final dio = Dio()..httpClientAdapter = (_ConfigAdapter()..fail = true);
    await fetchAppConfig(baseUrl: 'https://api-test.safetyalrt.com', client: dio);
    expect(SeverityLabels.advice(), 'Existing advice');
  });
}
