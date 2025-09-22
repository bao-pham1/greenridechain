# GreenRideChain (demo)

A small Flutter demo app that showcases a blockchain-themed vehicle rental and tourism idea.

What's included:
- `lib/main.dart` — full app UI and demo logic (wallet connect, start/finish ride, QR unlock)
- `pubspec.yaml` — dependencies: `intl`, `qr_flutter`

How to run (PowerShell):
```powershell
cd "c:\Users\Windows\Desktop\xedien"
flutter pub get
flutter run
```

Notes:
- This is a UI demo. Real blockchain integration (wallets / smart contracts) is out-of-scope and should be added later.
- Add images to `assets/images/` if desired and update `pubspec.yaml`.

Windows build / package
1. Enable Windows desktop support if not already:

```powershell
flutter config --enable-windows-desktop
flutter doctor
```

2. Build a release executable:

```powershell
cd "c:\Users\Windows\Desktop\xedien"
flutter build windows --release
```

3. The built exe is under `build\windows\runner\Release\` — you can copy that folder to distribute. For an installer, use tools like Inno Setup or WiX.

Troubleshooting:
- If build fails, run `flutter doctor -v` and fix the indicated issues (Visual Studio components for Windows desktop are required).
- For missing dependencies in `pubspec.yaml`, check package versions and run `flutter pub get` again.
