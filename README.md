# Markdown Studio 📝

A fast, responsive, cross-platform Markdown editor and reader for **Windows PC** and **Android**.

## ✨ Features
- **Adaptive Layout**: Side-by-side split screen (Editor + Live Preview) on PC desktop; tab switcher (Edit / Preview) on mobile devices.
- **Rich Markdown Toolbar**: One-tap formatting for Bold, Italic, Headings, Lists, Checkboxes, Blockquotes, Tables, and Code blocks.
- **File Management**: Open existing `.md` files, edit, Save, and Save As.
- **Multi-Format Export**:
  - 📄 **PDF**: Generate clean, printable PDF documents.
  - 📝 **Microsoft Word (.doc)**: Word-compatible formatted document.
  - 🌐 **HTML**: Standalone web page with GitHub-Flavored styles.
- **Themes**: Auto system theme with instant Dark and Light mode switcher.

---

## 🚀 How to Build `.exe` and `.apk` using Free GitHub Actions

You don't need Flutter or Android Studio installed on your computer! GitHub will compile both files for you automatically.

### Step 1: Create a GitHub Repository
1. Go to [GitHub.com](https://github.com) and click **New Repository**.
2. Name it `markdown-studio`.
3. Set it to **Public** or **Private** and click **Create repository**.

### Step 2: Upload Project Files
Upload all the files and folders from this project into your repository:
```
├── .github/
│   └── workflows/
│       └── build.yml
├── lib/
│   ├── main.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── services/
│   │   ├── file_service.dart
│   │   └── export_service.dart
│   └── widgets/
│       └── markdown_toolbar.dart
├── pubspec.yaml
└── README.md
```

### Step 3: Download Your `.exe` and `.apk`
1. In your GitHub repository, click the **Actions** tab at the top.
2. You will see a running workflow titled **Build PC (.exe) and Android (.apk)**.
3. Once completed (takes ~3-5 minutes):
   - Click on the completed workflow run.
   - Scroll down to the **Artifacts** section.
   - Download:
     - **`MarkdownStudio-Android-APK`**: Contains `app-release.apk` (install on Android).
     - **`MarkdownStudio-Windows-x64`**: Contains the Windows `.exe` and dependencies in a `.zip` (extract and run on PC).

---

## 💻 Local Development (Optional)
If you have Flutter installed locally:
```bash
# Get dependencies
flutter pub get

# Run on PC (Windows)
flutter run -d windows

# Run on Android phone / emulator
flutter run -d android

# Build Release APK
flutter build apk --release

# Build Release Windows App
flutter build windows --release
```
