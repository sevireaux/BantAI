# How this folder fits into a real Flutter project

`lib/` and `pubspec.yaml` here are complete, hand-written application code —
but the surrounding Flutter/Android project scaffold (Gradle files, iOS
folder if you want it, the `flutter` toolchain's generated boilerplate)
can only come from running `flutter create`, which needs the Flutter SDK
installed. That's not available in the environment this was written in, so
this folder is an overlay, not a ready-to-build project by itself.

See the root README's "Set up the Flutter app" section for the exact
setup order. In short: `flutter create` first, then copy `lib/` and
`pubspec.yaml` from here into the generated project (overwriting the
generated ones), then `flutter pub get`, then the Drift code-generation
step (`dart run build_runner build`), then see `android/NOTES.md` for the
Google Maps API key wiring.
