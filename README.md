# iPad Notes Offline (Flutter)

An **offline-first** notes app designed to run smoothly on **iPad Air 2 (iPadOS 15.8)**.

## Features
- Notebooks/folders
- Notes list with pinning
- Fast full-text search (title + body)
- Rich text editor (bold, lists, links, etc.)
- Autosave with debounce for older devices

## What this repo contains
This zip contains **all Dart code + CI workflow**. It **does not include** iOS/Android platform folders by default.
The GitHub Actions build will generate the iOS project files automatically.

## Requirements (Windows)
- Flutter SDK installed on Windows (for coding and running on Android/Web)
- GitHub account (you have this)
- Sideloadly on Windows to install the IPA on your iPad

> Building iOS requires macOS + Xcode, so we use **GitHub Actions (macOS runner)** to build the `.ipa`.

## 1) Push to GitHub
1. Create a new GitHub repo (e.g. `ipad_notes_offline`)
2. Upload/push all files from this folder.

## 2) Build IPA on GitHub Actions
1. Go to **Actions** tab
2. Select **Build iOS IPA (no codesign)**
3. Click **Run workflow**
4. After it finishes, download the artifact **ios-ipa** which contains your `.ipa`

The workflow:
- runs `flutter create . --platforms=ios` to generate `ios/`
- runs `build_runner` to generate Isar models
- sets iOS minimum version to **13.0**
- builds `--release --no-codesign`

## 3) Install on iPad with Sideloadly (Windows)
1. Install **iTunes** + **iCloud** for Windows from Apple (avoid Microsoft Store versions)
2. Install **Sideloadly**
3. Connect iPad via USB and tap **Trust**
4. Drag the downloaded `.ipa` into Sideloadly
5. Sign in with your Apple ID and install
6. On iPad: Settings → General → VPN & Device Management → Trust developer profile

### Note on expiration
If you use a free Apple ID signing method, iOS apps may need periodic re-signing.

## Development notes
- Offline-only: all notes are stored locally using Isar.
- For best performance on iPad Air 2: the editor autosaves every ~450ms after you stop typing.

---

If you want, I can also add: export to PDF, backup to Files app, tags, and dark-mode polish.
