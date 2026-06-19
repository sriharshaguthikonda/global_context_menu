# 🤖 Android Text Router fork of Global Context Menu

This fork keeps the original `global_context_menu` Flutter plugin, but turns the bundled `example` Android app into a compact selected-text router for Dr Harsha's phone.

When you select text on Android, the toolbar entry is:

```text
🤖
```

Tap it to open an ordered router:

```text
🤖 ChatGPT
🟣 Claude
❌ Grok
🔍 Perplexity
🌐 Edge / Bing search
☎ Truecaller
📤 Android share sheet
📋 Copy only
```

## Build APK on GitHub

This repo includes:

```text
.github/workflows/build-android-apk.yml
```

It builds the example app on push to `main` or `master`, on pull requests, and manually from **Actions → Build Android APK → Run workflow**.

The APK is uploaded as the artifact:

```text
text-router-debug-apk
```

APK path inside the artifact:

```text
app-debug.apk
```

## Install

After downloading and unzipping the artifact:

```bat
adb install -r app-debug.apk
```

Then check whether Android sees the text-selection entry:

```bat
adb shell cmd package query-activities --components -a android.intent.action.PROCESS_TEXT -t text/plain
```

Expected entry:

```text
io.github.sriharshaguthikonda.textrouter/com.lkrjangid.global_context_menu_example.TextProcessorActivity
```

## Make the toolbar cleaner

After installing this router, you can hide the original individual selected-text entries while keeping the apps installed:

```bat
adb shell pm disable-user --user 0 ai.perplexity.app.android/.ui.common.TrampolineActivity
adb shell pm disable-user --user 0 ai.x.grok/.textselection.TextSelectionIntegrationActivity
adb shell pm disable-user --user 0 com.anthropic.claude/.deeplink.DeepLinkActivity
adb shell pm disable-user --user 0 com.kengblog.aikeyboard/.ui.processtext.ProcessTextActivity
adb shell pm disable-user --user 0 com.microsoft.emmx/com.microsoft.bing.ProcessTextSearch
adb shell pm disable-user --user 0 com.openai.chatgpt/.TextProcessorActivity
adb shell pm disable-user --user 0 com.truecaller/.search.process_text.ProcessTextActivity
```

Re-enable if needed:

```bat
adb shell pm enable ai.perplexity.app.android/.ui.common.TrampolineActivity
adb shell pm enable ai.x.grok/.textselection.TextSelectionIntegrationActivity
adb shell pm enable com.anthropic.claude/.deeplink.DeepLinkActivity
adb shell pm enable com.kengblog.aikeyboard/.ui.processtext.ProcessTextActivity
adb shell pm enable com.microsoft.emmx/com.microsoft.bing.ProcessTextSearch
adb shell pm enable com.openai.chatgpt/.TextProcessorActivity
adb shell pm enable com.truecaller/.search.process_text.ProcessTextActivity
```

## Privacy

The router example app declares no dangerous permissions and no internet permission. See [`SECURITY_REVIEW.md`](SECURITY_REVIEW.md).

Important: the router itself does not upload selected text, but target apps like ChatGPT, Claude, Grok, Perplexity, Edge, and Truecaller may send the text to their own services once you choose them.

## Ordering note

The manifest uses:

```xml
<intent-filter android:label="🤖" android:priority="999">
```

This is a best-effort attempt to appear early. Android/OEM text-selection toolbar sorting can still override it.

---

## Original plugin information

# 📱 Global Context Menu

A Flutter plugin that enables adding custom actions to Android's text selection toolbar using the `ACTION_PROCESS_TEXT` intent.

[![Pub](https://img.shields.io/pub/v/global_context_menu.svg)](https://pub.dev/packages/global_context_menu)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ Features

- 🔠 Add custom actions to Android's text selection toolbar
- 📝 Process selected text from any app
- 🔄 Return modified text to replace the selection
- 🔒 Support for both read-only and editable text selections

## 📋 Requirements

- 📱 Android 6.0 (API level 23) or higher
- 💙 Flutter 2.5.0 or higher

## Plugin setup summary

Register an Android activity with an `ACTION_PROCESS_TEXT` intent filter:

```xml
<activity
    android:name=".YourProcessTextActivity"
    android:label="Your Action Name"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.PROCESS_TEXT" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="text/plain" />
    </intent-filter>
</activity>
```

Then read selected text from Flutter:

```dart
final textData = await GlobalContextMenu.getProcessedText();
final selectedText = textData['text'] as String? ?? '';
final isReadOnly = textData['isReadOnly'] as bool? ?? false;
```

For full original plugin usage, see the upstream project: `lkrjangid1/global_context_menu`.
