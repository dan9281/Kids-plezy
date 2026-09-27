<h1>
  <img src="assets/plezy.png" alt="Kids Plezy logo" height="32" style="vertical-align: middle;" />
  Kids Plezy
</h1>

A kids-only media player for Android phones, Android TV and Amazon Fire TV Stick. It connects to your own Jellyfin, Plex or Emby server and gives children a bright, simple, remote-friendly way to watch their shows, with the grown-up bits locked away.

Kids Plezy is a personal fork of [Plezy](https://github.com/edde746/plezy) by edde746. All the playback, library and server support comes from Plezy; this fork changes the look and trims the app down for children.

## What's different from Plezy

- **"Ocean pop" theme.** Bright, friendly colours throughout, with a cartoon baby-jellyfish icon, launcher icon and TV banner.
- **Grown-ups-only settings.** Settings are behind a PIN pad that works with a TV remote's D-pad or number keys. It locks again as soon as you leave Settings.
- **Fewer tabs.** Explore (outside catalogues like Trakt, Seerr and trending), Live TV and the Downloads tab are hidden, so kids only see what's already in your library.
- **Installs alongside Plezy.** It has its own app ID (`com.dan9281.kidsplezy`) and name, so it won't replace the normal Plezy app on the same device.
- **Not locked to one server.** Point it at any Jellyfin, Plex or Emby server during setup, so a change of server URL is just a settings change.

## Download

There's no app store listing. Each push to the `kids` branch builds a fresh APK automatically.

1. Open the **[Kids APK builds](../../actions/workflows/kids-apk.yml)** page and pick the latest run with a green tick.
2. Scroll to **Artifacts** at the bottom and download **kids-plezy-apk**. You must be signed in to GitHub. On a phone, use the browser (not the GitHub app), and switch to "Desktop site" if the section doesn't show.
3. Unzip it to get `app-release.apk`.

One APK works on phones, tablets, Android TV and Fire TV. Android 7.1 (Fire OS 6) or newer is required.

## Installing

**Phone or tablet:** tap `app-release.apk` and allow "Install unknown apps" for your file manager or browser when asked. If Play Protect warns about it, choose **More details → Install anyway**. It's flagged only because it isn't from the Play Store.

**Fire TV Stick:** turn on **Settings → My Fire TV → Developer options → Install unknown apps** for the Downloader app. Then either download the APK in Downloader, or send it over with an app like LocalSend and open it from there.

**Updating:** install the new APK over the top. If Android says **"App not installed"**, the new build was signed with a different key from the one installed (see [Signing](#signing)). Uninstall Kids Plezy, then install the new APK.

## Parent PIN

The default PIN is **1234**. Change it before handing the app to the kids: edit `parentPin` in [`lib/kids/kids_config.dart`](lib/kids/kids_config.dart) and rebuild. The hidden tabs are set in the same file.

## Signing

Android only installs signed apps, and only lets an update replace an app signed with the same key. The GitHub build handles this automatically:

- **With the repository secrets `KIDS_KEYSTORE_BASE64` and `KIDS_KEYSTORE_PASSWORD` set,** every build is signed with the same permanent key. Updates install over the old app, and the kids' watch progress and settings are kept.
- **Without them,** each build gets its own throwaway key, and you'll need to uninstall before each update.

The permanent key (`android/app/kids-release.jks` plus `android/key.properties`) is never committed. Keep a backup somewhere safe. If you lose it, future builds can't update the installed app.

## Building on your own PC

Requirements: the Flutter SDK 3.47 or newer, and the Android SDK (Android Studio installs it).

On Windows, double-click **`build-kids.bat`**. It fetches packages, runs code generation, builds the release APK, and opens the output folder (`build\app\outputs\flutter-apk\app-release.apk`).

Or run the same steps by hand:

```bash
flutter pub get
dart run slang
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

If `android/key.properties` exists, the build is signed with your permanent key. Otherwise it falls back to the Android debug key.

## License

Kids Plezy is a modified version of Plezy and, like Plezy, is licensed under [GPL-3.0](LICENSE).

## Acknowledgments

- [Plezy](https://github.com/edde746/plezy) by edde746 and contributors, which provides everything under the hood
- Built with [Flutter](https://flutter.dev)
- Works with [Jellyfin](https://jellyfin.org), [Plex Media Server](https://www.plex.tv) and [Emby](https://emby.media)
- Playback powered by [mpv](https://mpv.io) and Android [ExoPlayer](https://developer.android.com/media/media3/exoplayer)
