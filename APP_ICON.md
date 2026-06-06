# App Icon Generation Instructions

To generate the Timbo app icon:

1. Add the `flutter_launcher_icons` dev dependency:
   ```bash
   flutter pub add --dev flutter_launcher_icons
   ```

2. Create the icon images using a tool like Figma or Canva:
   - `assets/images/app_icon.png` (1024×1024): White letter "T" in Sora font on a deep navy blue circle (#1F2937) with a small lightning bolt (⚡) overlapping the bottom-right of the "T"
   - `assets/images/app_icon_foreground.png` (1024×1024): Just the "T" + lightning bolt on a transparent background (for Android adaptive icon)

3. The `pubspec.yaml` already has the configuration:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/images/app_icon.png"
     adaptive_icon_background: "#1F2937"
     adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
   ```

4. Run the generator:
   ```bash
   dart run flutter_launcher_icons
   ```

Design specs for the icon:
- Background: Deep navy blue circle (#1F2937) — corner radius proportional
- Foreground: White letter "T" in Sora font, bold weight, centered
- Accent: Gold/amber (#F59E0B) lightning bolt (⚡) positioned at the bottom-right overlap
- The icon should be clean, minimal, and professional
