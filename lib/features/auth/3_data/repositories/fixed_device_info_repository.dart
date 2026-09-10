import 'package:habits/features/auth/1_domain/repositories/device_info_repository.dart';

/// [DeviceInfoRepository] con valores fijos para tests.
class FixedDeviceInfoRepository implements DeviceInfoRepository {
  const FixedDeviceInfoRepository({this.timezone = 'Europe/Madrid'});

  final String timezone;

  @override
  Future<String> currentTimezone() async => timezone;
}
