import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/core/network/api_client.dart';
import 'package:rider_app/core/services/storage_service.dart';
import 'package:rider_app/models/rider_profile_model.dart';
import 'package:rider_app/providers/rider_auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late ApiClient apiClient;
  late RiderAuthProvider authProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.init();
    apiClient = ApiClient(storageService);
    authProvider = RiderAuthProvider(apiClient, storageService);
  });

  group('STRICT ROLE INVARIANT: Only Riders Can Login', () {
    test('1. Logistics Company account login attempt is strictly denied', () async {
      final success = await authProvider.login('logistics@speedyfleet.ng', 'Password123!');

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(storageService.getToken(), isNull);
      expect(authProvider.errorMessage, contains('Logistics company accounts cannot log into the rider app'));
    });

    test('2. Fleet owner login attempt (e.g. Tariq Van Logistics) is strictly denied', () async {
      final success = await authProvider.login('tariq@vanlogistics.ng', 'Password123!');

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(storageService.getToken(), isNull);
      expect(authProvider.errorMessage, contains('cannot log into the rider app'));
    });

    test('3. Merchant / Vendor account login attempt is strictly denied', () async {
      final success = await authProvider.login('merchant@apexplaza.ng', 'Password123!');

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(storageService.getToken(), isNull);
      expect(authProvider.errorMessage, contains('Only registered delivery riders can authenticate'));
    });

    test('4. Customer account login attempt is strictly denied', () async {
      final success = await authProvider.login('customer@gmail.com', 'Password123!');

      expect(success, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(storageService.getToken(), isNull);
      expect(authProvider.errorMessage, contains('Only registered delivery riders can authenticate'));
    });
  });

  group('INVARIANT: All Riders Must Belong to a Logistics Company', () {
    test('5. Valid rider (Musa) authenticates and is bound to Speedy Parcel Express', () async {
      final success = await authProvider.login('musa@speedyfleet.ng', 'Password123!');

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(storageService.getToken(), isNotNull);
      expect(authProvider.currentRider, isNotNull);
      expect(authProvider.currentRider!.fleetCompany, equals('Speedy Parcel Express'));
      expect(authProvider.currentRider!.hasLogisticsCompany, isTrue);
    });

    test('6. Valid rider (Ubong) authenticates and is bound to Van Logistics Ltd', () async {
      final success = await authProvider.login('ubong.rider@vanlogistics.ng', 'Password123!');

      expect(success, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentRider!.fleetCompany, equals('Van Logistics Ltd'));
      expect(authProvider.currentRider!.hasLogisticsCompany, isTrue);
    });

    test('7. RiderProfileModel hasLogisticsCompany validates true only with verified fleet', () {
      final validRider = RiderProfileModel(
        id: 1,
        name: 'Musa Haruna',
        email: 'musa@speedyfleet.ng',
        phone: '+2348055556677',
        logisticsCompanyId: 10,
        fleetCompany: 'Speedy Parcel Express',
        vehicleType: 'Motorbike',
        licensePlate: 'KJA-104-XY',
        rating: 4.9,
        isActive: true,
        isOnline: true,
      );
      expect(validRider.hasLogisticsCompany, isTrue);

      final unassignedRider = RiderProfileModel(
        id: 2,
        name: 'Unassigned Rider',
        email: 'rogue@gmail.com',
        phone: '+2348000000000',
        logisticsCompanyId: null,
        fleetCompany: 'Unassigned',
        vehicleType: 'Motorbike',
        licensePlate: 'KJA-000-XX',
        rating: 4.0,
        isActive: true,
        isOnline: true,
      );
      expect(unassignedRider.hasLogisticsCompany, isFalse);

      final emptyFleetRider = RiderProfileModel(
        id: 3,
        name: 'Empty Fleet Rider',
        email: 'empty@gmail.com',
        phone: '+2348000000000',
        logisticsCompanyId: null,
        fleetCompany: '',
        vehicleType: 'Motorbike',
        licensePlate: 'KJA-000-XX',
        rating: 4.0,
        isActive: true,
        isOnline: true,
      );
      expect(emptyFleetRider.hasLogisticsCompany, isFalse);
    });
  });
}
