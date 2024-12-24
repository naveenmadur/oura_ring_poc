# Oura Ring POC

A Flutter application demonstrating Oura Ring OAuth2 authentication integration with in-app WebView.

## Oura Ring Authentication Implementation

### Overview
The application implements OAuth2 authentication with Oura Ring using an in-app WebView approach. This provides a seamless user experience by handling the entire authentication flow within the app instead of redirecting to an external browser.

### Key Components

1. **Dependencies** (`pubspec.yaml`):
   - `oauth2`: Handles OAuth2 authentication flow
   - `webview_flutter`: Provides in-app browser functionality
   - `uni_links`: Handles deep linking (for callback URL)

2. **AuthWebView** (`lib/auth_webview.dart`):
   - Custom widget that displays the Oura Ring login page in a WebView
   - Handles URL interception for the OAuth callback
   - Extracts the authorization code from the callback URL
   - Provides a clean UI with an app bar and close button

3. **OAuth Implementation** (`lib/main.dart`):
   - Uses `AuthorizationCodeGrant` from the `oauth2` package
   - Configures OAuth endpoints and credentials
   - Manages the authentication flow:
     1. Generates authorization URL
     2. Opens AuthWebView with the URL
     3. Receives authorization code from callback
     4. Exchanges code for access token

### Authentication Flow

1. User initiates authentication
2. App creates an OAuth2 authorization URL
3. AuthWebView opens showing the Oura login page
4. User logs in and authorizes the app
5. Callback URL is intercepted by AuthWebView
6. Authorization code is extracted and passed back
7. Code is exchanged for an access token
8. Authentication complete, token ready for API calls

### Configuration

```dart
const String clientId = 'YOUR_CLIENT_ID';
const String clientSecret = 'YOUR_CLIENT_SECRET';
const String authorizationEndpoint = 'https://cloud.ouraring.com/oauth/authorize';
const String tokenEndpoint = 'https://api.ouraring.com/oauth/token';
const String redirectUri = 'ouraring://callback';
```

### Platform-Specific Configuration

#### iOS Configuration (Info.plist)
Added URL scheme configuration to handle the OAuth callback:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ouraring</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.example.ouraRingPoc</string>
    </dict>
</array>
```

#### Android Configuration (AndroidManifest.xml)
Added queries for custom tabs support and browser view:
```xml
<queries>
    <!-- For in-app browser support -->
    <intent>
        <action android:name="android.support.customtabs.action.CustomTabsService" />
    </intent>
</queries>
```

Also, ensure the activity has `android:launchMode="singleTop"` and `android:taskAffinity=""` for proper handling of the OAuth flow:
```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop"
    android:taskAffinity=""
    ...>
```

### Security Note
The client ID and secret should be stored securely and not committed to version control. Consider using environment variables or a secure configuration management system in production.

## Getting Started

1. Register your application with Oura Ring to obtain client credentials
2. Update the OAuth configuration in `lib/main.dart` with your credentials
3. Ensure your redirect URI is properly configured in the Oura Ring developer console
4. Run the application using `flutter run`
