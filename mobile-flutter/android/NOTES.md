# How this fits into a real Flutter project

Like the Laravel backend, this isn't a complete, buildable Android project
on its own — `android/build.gradle`, `android/settings.gradle`, Gradle
wrapper files, and most of `android/app/build.gradle` must come from
`flutter create` (which needs the Flutter SDK, not available in the
environment this was written in).

**Setup order** (see the root README for the full walkthrough):
1. `flutter create --org com.bantai --project-name bantai_mobile .` in this
   `mobile-flutter/` folder — this generates the missing Gradle files
   without touching `lib/`, `pubspec.yaml`, or this `AndroidManifest.xml`
   if you answer "no" to overwrite prompts for those.
2. Add this snippet to `android/app/build.gradle` (inside the `android {}`
   block, above `defaultConfig`), so the Maps API key placeholder in
   `AndroidManifest.xml` resolves from a git-ignored properties file instead
   of being committed:

   ```groovy
   def localProperties = new Properties()
   def localPropertiesFile = rootProject.file('local.properties')
   if (localPropertiesFile.exists()) {
       localPropertiesFile.withReader('UTF-8') { reader ->
           localProperties.load(reader)
       }
   }

   android {
       defaultConfig {
           // ...existing config...
           manifestPlaceholders += [
               GOOGLE_MAPS_API_KEY: localProperties.getProperty('googleMaps.apiKey', '')
           ]
       }
   }
   ```

3. Add your key to `android/local.properties` (create it if `flutter
   create` didn't, and confirm it's listed in `.gitignore` — it always is
   by default in a generated Flutter project):

   ```
   googleMaps.apiKey=AIzaSy...your-real-key...
   ```
