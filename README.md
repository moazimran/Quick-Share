<div align="center">

# ⚡ Quick-Share

### _Share anything. Instantly. No strings attached._

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-State_Mgmt-0057B8?style=for-the-badge)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

<br/>

> **Upload a file → Get a 6-digit code → Anyone downloads it.**
> No accounts. No compression. No friction.

<br/>

[✨ Features](#-key-features) • [🛠 Tech Stack](#-tech-stack) • [🚀 Getting Started](#-getting-started) • [📸 Screenshots](#-screenshots--demo) • [🗺 Roadmap](#-future-roadmap)

---

</div>

<br/>

## 📖 About The Project

**Quick-Share** is a cross-platform file sharing app built with Flutter and powered by Supabase. It solves a simple but frustrating problem — sharing a file quickly with someone without needing their contact, a shared platform, or creating an account on either end.

The sender uploads any file and receives a unique **6-digit numeric code**. The receiver enters that code in the app and instantly downloads the original, uncompressed file. That's it. No logins, no email chains, no broken download links.

Built as a portfolio-grade project, Quick-Share demonstrates real-world usage of **Clean Architecture**, **Riverpod state management**, **Supabase Storage + Database**, and a polished **dark-mode UI** — all within a tight, scalable folder structure.

```
The Problem:    Sharing a file fast = too many steps, too many apps.
The Solution:   One code. One tap. Done.
```

<br/>

## ✨ Key Features

- ⚡ **Instant Upload** — Pick any file and upload it to the cloud in seconds with a single tap.
- 🔢 **6-Digit Secure Code** — A cryptographically random unique code is generated per upload — collision-safe by design.
- 🗜️ **Zero Compression** — Files are stored and delivered in their **original quality**. No re-encoding, no resizing, ever.
- 📡 **Real-Time Fetching** — Receivers get instant results the moment a valid code is entered, powered by Supabase's real-time infrastructure.
- 🚫 **No Registration Required** — Zero friction for both sender and receiver. No account, no email, no waiting.
- 📥 **Dual Download Options** — Save directly to the device's Downloads folder **or** open in browser — user's choice via a sleek bottom sheet.
- 🎨 **Modern Dark UI** — Clean, professional dark-mode interface built with `Google Fonts`, rounded containers, and smooth state transitions.
- 🔄 **Async State Handling** — Every loading, success, and error state is handled gracefully using Riverpod's `AsyncValue` — zero `setState` in the codebase.

<br/>

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Framework** | Flutter + Dart | Cross-platform mobile UI |
| **State Management** | Riverpod 2.x | Reactive, provider-based state |
| **Backend / DB** | Supabase (PostgreSQL) | Shares table, code lookup |
| **File Storage** | Supabase Storage | Original file hosting |
| **File Picker** | `file_picker` | Cross-platform file selection |
| **HTTP Client** | `dio` | Streaming file downloads |
| **URL Handling** | `url_launcher` | Browser-based file viewing |
| **Fonts** | `google_fonts` | DM Sans + Space Grotesk |
| **Device Info** | `device_info_plus` | Android version-aware permissions |
| **Permissions** | `permission_handler` | Runtime storage permissions |

<br/>

## 📸 Screenshots & Demo

<div align="center">

| Upload Screen | Code Generated | Download Screen | Bottom Sheet |
|:---:|:---:|:---:|:---:|
| ![Upload](https://placehold.co/200x400/0D0F14/6C63FF?text=Upload) | ![Code](https://placehold.co/200x400/0D0F14/22D3A6?text=Code) | ![Download](https://placehold.co/200x400/0D0F14/6C63FF?text=Download) | ![Options](https://placehold.co/200x400/0D0F14/22D3A6?text=Options) |

> 📌 _Replace placeholders above with actual screenshots from your device._

</div>

<br/>

## 🗂 Project Structure

```
lib/
├── main.dart                          # App entry point + Supabase init
│
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Dark mode palette, typography
│   └── supabase/
│       └── supabase_client.dart       # Supabase singleton accessor
│
└── features/
    ├── home/
    │   └── screens/
    │       └── home_screen.dart       # Tab navigation shell
    │
    ├── share/
    │   ├── models/
    │   │   └── share_model.dart       # ShareModel (fromJson / toJson)
    │   ├── repositories/
    │   │   └── share_repository.dart  # All Supabase DB + Storage calls
    │   ├── providers/
    │   │   └── share_providers.dart   # Riverpod upload + download state
    │   └── screens/
    │       ├── upload_screen.dart     # File picker + upload UI
    │       └── download_screen.dart   # Code input + fetch + download UI
    │
    └── widgets/
        ├── qs_button.dart             # Reusable loading-aware button
        └── status_card.dart           # Error / success message card
```

<br/>

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A [Supabase](https://supabase.com) account (free tier works perfectly)
- Android Studio / VS Code

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/quick-share.git
cd quick-share
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Supabase

**a.** Create a new project at [supabase.com](https://supabase.com).

**b.** Go to **SQL Editor** and run the following schema:

```sql
-- Shares table
CREATE TABLE public.shares (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code        VARCHAR(6)  NOT NULL UNIQUE,
  file_url    TEXT        NOT NULL,
  file_name   TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shares_code ON public.shares (code);

-- Row Level Security
ALTER TABLE public.shares ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public inserts" ON public.shares FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public selects" ON public.shares FOR SELECT USING (true);

-- Storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('quick-share-files', 'quick-share-files', true);

CREATE POLICY "Allow public uploads" ON storage.objects FOR INSERT TO public
WITH CHECK (bucket_id = 'quick-share-files');

CREATE POLICY "Allow public downloads" ON storage.objects FOR SELECT TO public
USING (bucket_id = 'quick-share-files');
```

**c.** Go to **Settings → API** and copy your Project URL and `anon` key.

### 4. Add your credentials

Open `lib/main.dart` and replace the placeholders:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 5. Android permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="29"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>

<queries>
  <intent>
    <action android:name="android.intent.action.VIEW"/>
    <data android:scheme="https"/>
  </intent>
</queries>
```

### 6. Run the app

```bash
flutter run
```

<br/>

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  supabase_flutter: ^2.5.0      # Backend + storage
  file_picker: ^8.0.3           # File selection
  dio: ^5.4.3                   # File downloading
  url_launcher: ^6.2.5          # Browser opening
  google_fonts: ^6.2.1          # Typography
  path: ^1.9.0                  # Path utilities
  path_provider: ^2.1.3         # Device directories
  permission_handler: ^11.3.1   # Runtime permissions
  device_info_plus: ^10.1.0     # Android SDK detection
```

<br/>

## 🗺 Future Roadmap

- [ ] 🔐 **End-to-End Encryption** — Encrypt files before upload, decrypt on download
- [ ] ⏱ **Code Expiry** — Auto-delete shares after 24 hours using `pg_cron`
- [ ] 🔑 **Password Protection** — Optional password on top of the 6-digit code
- [ ] 📊 **Upload Progress Bar** — Real-time Dio upload progress indicator
- [ ] 🔍 **QR Code Generation** — Generate a scannable QR instead of typing code
- [ ] 📜 **Transfer History** — Local history of sent and received files
- [ ] 🌐 **Flutter Web Support** — Same codebase, browser-accessible
- [ ] 🌙 **Light Mode** — Theme toggle for light/dark preference
- [ ] 📁 **Multi-file Upload** — Bundle multiple files in one share
- [ ] 📬 **Push Notifications** — Notify when your shared file is downloaded

<br/>

## 🤝 Contributing

Contributions are welcome! If you have a feature idea or found a bug:

1. Fork the repository
2. Create your branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

<br/>

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

<br/>

## 👨‍💻 Author

<div align="center">

Built with ❤️ by **[Your Name](https://github.com/YOUR_USERNAME)**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/YOUR_USERNAME)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/YOUR_USERNAME)
[![Portfolio](https://img.shields.io/badge/Portfolio-FF5722?style=for-the-badge&logo=firefox&logoColor=white)](https://yourportfolio.com)

<br/>

⭐ **Star this repo if you found it useful!** ⭐

</div>
