import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

Future<auth.AccessCredentials> requestWebCredentials(
  String clientId,
  List<String> scopes,
) {
  throw UnsupportedError('Web auth not available on this platform');
}

http.Client createAutoRefreshingClient(
  auth.ClientId clientId,
  auth.AccessCredentials credentials,
  http.Client baseClient,
) {
  throw UnsupportedError('Web auth not available on this platform');
}
