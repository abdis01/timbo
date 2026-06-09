# Android Release Build Guide

## Prerequisites
- Flutter SDK installed
- Android Studio / Android SDK

## Step 1: Generate a Keystore
```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias timbo_key
```
Store the password and key password in `android/key.properties`.

## Step 2: Build the App Bundle
```bash
flutter build appbundle
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## Step 3: Upload to Google Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app
3. Upload the `.aab` file
4. Complete store listing (privacy policy, screenshots, etc.)

## Notes
- App signing is managed by Google Play (recommended)
- The keystore is for upload key only
- Back up your keystore file and passwords!
