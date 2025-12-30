# iOS Setup Guide for Surveyor App

## Prerequisites
- macOS with Xcode 15+ installed
- Apple Developer Account (for App Store deployment)
- CocoaPods installed (`sudo gem install cocoapods`)

## Initial Setup (One-time)

### 1. Install Dependencies
```bash
cd ios
pod install
```

### 2. Configure Signing in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** project in the navigator
3. Select the **Runner** target
4. Go to **Signing & Capabilities** tab
5. Check **Automatically manage signing**
6. Select your **Team** from the dropdown
7. Xcode will automatically create provisioning profiles

### 3. Update Bundle Identifier (if needed)
Current Bundle ID: `com.rektech.surveyor`

If you need to change it:
1. Update in Xcode under **Signing & Capabilities**
2. Update `GoogleService-Info.plist` with new Firebase iOS app
3. Update `Info.plist` URL schemes

## Building for Development

### Run on Simulator
```bash
flutter run -d ios
```

### Run on Physical Device
```bash
flutter run -d <device_id>
```

## Building for App Store Release

### 1. Update Version Number
In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # format: major.minor.patch+buildNumber
```

### 2. Build Release IPA
```bash
# Clean build
flutter clean
flutter pub get

# Build for App Store
flutter build ipa --release
```

The IPA will be at: `build/ios/ipa/surveyor.ipa`

### 3. Upload to App Store Connect

**Option A: Using Xcode**
1. Open `ios/Runner.xcworkspace`
2. Product → Archive
3. Distribute App → App Store Connect → Upload

**Option B: Using Command Line**
```bash
xcrun altool --upload-app --type ios \
  --file build/ios/ipa/surveyor.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

**Option C: Using Transporter App**
1. Download Transporter from Mac App Store
2. Drag and drop the IPA file
3. Click Deliver

## App Store Submission Checklist

### Required Assets
- [ ] App Icon (1024x1024 PNG, no alpha)
- [ ] Screenshots for all device sizes:
  - iPhone 6.7" (1290 x 2796)
  - iPhone 6.5" (1284 x 2778)
  - iPhone 5.5" (1242 x 2208)
  - iPad Pro 12.9" (2048 x 2732)
- [ ] App Preview videos (optional)

### App Store Connect Information
- [ ] App Name: Surveyor
- [ ] Subtitle (30 chars max)
- [ ] Description (4000 chars max)
- [ ] Keywords (100 chars max, comma separated)
- [ ] Support URL
- [ ] Privacy Policy URL
- [ ] Category: Business / Productivity

### Privacy Declarations
Based on the app's features, declare:
- [ ] Camera usage (profile photos)
- [ ] Photo Library usage (image selection)
- [ ] Location usage (survey locations)

## Troubleshooting

### Pod Install Fails
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
```

### Signing Issues
1. Revoke and regenerate certificates in Apple Developer Portal
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Clean build: `flutter clean`

### Build Errors
```bash
# Reset iOS build
cd ios
rm -rf Pods Podfile.lock .symlinks
cd ..
flutter clean
flutter pub get
cd ios
pod install
```

### Archive Fails
- Ensure all capabilities match between Debug and Release entitlements
- Check that DEVELOPMENT_TEAM is set in Xcode

## Firebase Configuration
The app uses Firebase for:
- Authentication (Phone Auth)
- Cloud Firestore (Database)
- Firebase Storage (File uploads)

Firebase iOS config: `ios/Runner/GoogleService-Info.plist`

## Permissions Used
| Permission | Usage |
|------------|-------|
| Camera | Capture profile photos and survey images |
| Photo Library | Select images from gallery |
| Location | Record survey locations |
| Push Notifications | Receive updates |

## Support
For issues, contact: [Your support email]
