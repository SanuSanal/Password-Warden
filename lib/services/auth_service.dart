import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool canCheckDeviceCredentials = await auth.isDeviceSupported();
      bool isAuthenticated = false;
      if (canCheckBiometrics || canCheckDeviceCredentials) {
        isAuthenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to access Password Warden',
        );
      } else {
        // No authentication methods available, proceed without authentication
        isAuthenticated = true;
      }
      return isAuthenticated;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        // Biometric authentication is available but not configured
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
