package com.lkrjangid.global_context_menu_example

import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

open class RouterFlutterActivity : FlutterActivity() {
    private val channelName = "text_router"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "copyText" -> {
                        copyText(call.argument<String>("text") ?: "")
                        result.success(true)
                    }
                    "openPackage" -> {
                        val packageName = call.argument<String>("packageName") ?: ""
                        val text = call.argument<String>("text") ?: ""
                        copyText(text)
                        openPackage(packageName, text)
                        result.success(true)
                    }
                    "openUrl" -> {
                        val url = call.argument<String>("url") ?: ""
                        val preferredPackage = call.argument<String>("preferredPackage") ?: ""
                        val text = call.argument<String>("text") ?: ""
                        copyText(text)
                        openUrl(url, preferredPackage)
                        result.success(true)
                    }
                    "shareText" -> {
                        val text = call.argument<String>("text") ?: ""
                        copyText(text)
                        shareText(text)
                        result.success(true)
                    }
                    "openAppInfo" -> {
                        openAppInfo()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("TEXT_ROUTER_ERROR", e.message, null)
            }
        }
    }

    private fun copyText(text: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText("selected text", text))
        Toast.makeText(this, "Copied selected text", Toast.LENGTH_SHORT).show()
    }

    private fun openPackage(packageName: String, text: String) {
        if (packageName.isBlank()) {
            Toast.makeText(this, "Missing package name", Toast.LENGTH_LONG).show()
            return
        }

        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
            setPackage(packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        try {
            startActivity(sendIntent)
            return
        } catch (ignored: ActivityNotFoundException) {
        } catch (ignored: Exception) {
        }

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent == null) {
            Toast.makeText(this, "App not found: $packageName", Toast.LENGTH_LONG).show()
            return
        }

        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        launchIntent.putExtra(Intent.EXTRA_TEXT, text)
        try {
            startActivity(launchIntent)
        } catch (e: Exception) {
            Toast.makeText(this, "Could not open: $packageName", Toast.LENGTH_LONG).show()
        }
    }

    private fun openUrl(url: String, preferredPackage: String) {
        if (url.isBlank()) {
            Toast.makeText(this, "Missing URL", Toast.LENGTH_LONG).show()
            return
        }

        val preferredIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            setPackage(preferredPackage)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        try {
            startActivity(preferredIntent)
            return
        } catch (ignored: Exception) {
        }

        val fallbackIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            startActivity(fallbackIntent)
        } catch (e: Exception) {
            Toast.makeText(this, "Could not open URL", Toast.LENGTH_LONG).show()
        }
    }

    private fun shareText(text: String) {
        val shareIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        startActivity(Intent.createChooser(shareIntent, "Send selected text to"))
    }

    private fun openAppInfo() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.parse("package:$packageName")
        }
        startActivity(intent)
    }
}
