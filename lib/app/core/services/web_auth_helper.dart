import 'dart:async';

import 'package:google_identity_services_web/loader.dart' as gis_loader;
import 'package:google_identity_services_web/oauth2.dart' as gis;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

Future<auth.AccessCredentials> requestWebCredentials(
  String clientId,
  List<String> scopes,
) async {
  await gis_loader.loadWebSdk();

  final completer = Completer<auth.AccessCredentials>();

  void callback(gis.TokenResponse response) {
    if (completer.isCompleted) return;
    if (response.error != null) {
      completer.completeError(
          Exception('${response.error}: ${response.error_description}'));
      return;
    }
    final token = auth.AccessToken(
      response.token_type ?? 'Bearer',
      response.access_token ?? '',
      DateTime.now().add(
        Duration(seconds: response.expires_in ?? 3600),
      ),
    );
    completer.complete(auth.AccessCredentials(token, null, scopes.toList()));
  }

  void errorCallback(gis.GoogleIdentityServicesError? error) {
    if (error != null && !completer.isCompleted) {
      completer.completeError(
          Exception('${error.type}: ${error.message}'));
    }
  }

  final config = gis.TokenClientConfig(
    callback: callback,
    client_id: clientId,
    scope: scopes,
    prompt: 'select_account',
    error_callback: errorCallback,
  );

  final client = gis.oauth2.initTokenClient(config);
  client.requestAccessToken();

  return completer.future;
}

http.Client createAutoRefreshingClient(
  auth.ClientId clientId,
  auth.AccessCredentials credentials,
  http.Client baseClient,
) {
  return auth.autoRefreshingClient(
    clientId,
    credentials,
    baseClient,
  );
}
