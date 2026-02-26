package dev.macss.whatsapp_direct_send

import android.app.Activity
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/**
 * Flutter plugin that allows sending text messages and/or images directly
 * to a WhatsApp contact via Android's [Intent.ACTION_SEND].
 *
 * Detects WhatsApp / WhatsApp Business automatically and falls back to the
 * system share sheet when neither is installed.
 */
class WhatsappDirectSendPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    companion object {
        private const val TAG = "WaDirect"
        private const val CHANNEL_NAME = "whatsapp_direct_send"

        /** Authority suffix appended to the host app's applicationId. */
        private const val PROVIDER_AUTHORITY_SUFFIX =
            ".whatsapp_direct_send.fileprovider"
    }

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    // ── FlutterPlugin lifecycle ──────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ── ActivityAware lifecycle ──────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    // ── Method channel handler ──────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "send" -> handleSend(call, result)
            "registry" -> handleRegistry(call, result)
            else -> result.notImplemented()
        }
    }

    // ── Core sharing logic ──────────────────────────────────────────────

    private fun handleSend(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error(
                "NO_ACTIVITY",
                "Plugin requires a foreground Activity.",
                null,
            )
            return
        }

        val phone = call.argument<String>("phone") ?: ""
        val text = call.argument<String>("text") ?: ""
        val filePath = call.argument<String>("filePath")

        try {
            val hasFile = !filePath.isNullOrEmpty() && File(filePath).exists()

            if (!filePath.isNullOrEmpty() && !hasFile) {
                result.error(
                    "FILE_NOT_FOUND",
                    "The file does not exist: $filePath",
                    null,
                )
                return
            }

            val sendIntent: Intent
            var uri: Uri? = null

            if (hasFile) {
                val file = File(filePath!!)
                val authority =
                    "${currentActivity.applicationContext.packageName}$PROVIDER_AUTHORITY_SUFFIX"

                uri = FileProvider.getUriForFile(
                    currentActivity,
                    authority,
                    file,
                )

                val clip = ClipData.newUri(
                    currentActivity.contentResolver,
                    "image",
                    uri,
                )

                sendIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "image/*"
                    putExtra(Intent.EXTRA_STREAM, uri)
                    putExtra(Intent.EXTRA_TEXT, text)
                    putExtra("jid", "$phone@s.whatsapp.net")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    clipData = clip
                }
            } else {
                // Text-only message
                sendIntent = Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                    putExtra("jid", "$phone@s.whatsapp.net")
                }
            }

            val pm = currentActivity.packageManager
            val targetPkg = resolveWhatsAppPackage(pm)

            if (targetPkg != null) {
                sendIntent.setPackage(targetPkg)
                if (uri != null) {
                    currentActivity.grantUriPermission(
                        targetPkg,
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION,
                    )
                }
                currentActivity.startActivity(sendIntent)
                result.success(null)
            } else {
                // No WhatsApp found — try the system share sheet
                val resolved = pm.queryIntentActivities(
                    sendIntent,
                    PackageManager.MATCH_DEFAULT_ONLY,
                )
                if (resolved.isNotEmpty()) {
                    if (uri != null) {
                        for (ri in resolved) {
                            currentActivity.grantUriPermission(
                                ri.activityInfo.packageName,
                                uri,
                                Intent.FLAG_GRANT_READ_URI_PERMISSION,
                            )
                        }
                    }
                    currentActivity.startActivity(
                        Intent.createChooser(sendIntent, "Share via"),
                    )
                    result.success(null)
                } else {
                    result.error(
                        "WHATSAPP_NOT_FOUND",
                        "No app found to handle the sharing intent.",
                        null,
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error sharing to WhatsApp", e)
            result.error("SHARE_ERROR", e.message, null)
        }
    }

    // ── Click-to-Chat via wa.me ──────────────────────────────────────

    /**
     * Opens a WhatsApp chat with the given phone number using the
     * Click-to-Chat URL scheme (`https://wa.me/{phone}?text={text}`).
     *
     * This uses [Intent.ACTION_VIEW] which works for **any** phone number,
     * regardless of whether the user has previously chatted with that number.
     */
    private fun handleRegistry(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error(
                "NO_ACTIVITY",
                "Plugin requires a foreground Activity.",
                null,
            )
            return
        }

        val phone = call.argument<String>("phone") ?: ""
        val text = call.argument<String>("text") ?: ""

        try {
            val encodedText = Uri.encode(text)
            val url = "https://wa.me/$phone?text=$encodedText"

            val viewIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))

            val pm = currentActivity.packageManager
            val targetPkg = resolveWhatsAppPackage(pm)

            if (targetPkg != null) {
                viewIntent.setPackage(targetPkg)
                currentActivity.startActivity(viewIntent)
                result.success(null)
            } else {
                // Try without package — system browser or share sheet
                val resolved = pm.queryIntentActivities(
                    viewIntent,
                    PackageManager.MATCH_DEFAULT_ONLY,
                )
                if (resolved.isNotEmpty()) {
                    currentActivity.startActivity(viewIntent)
                    result.success(null)
                } else {
                    result.error(
                        "WHATSAPP_NOT_FOUND",
                        "No app found to handle the wa.me URL.",
                        null,
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error opening WhatsApp via wa.me", e)
            result.error("SHARE_ERROR", e.message, null)
        }
    }

    /**
     * Returns the package name of the installed WhatsApp variant, preferring
     * the standard consumer app over the Business edition.
     *
     * Returns `null` when neither is installed.
     */
    private fun resolveWhatsAppPackage(pm: PackageManager): String? {
        val candidates = listOf("com.whatsapp", "com.whatsapp.w4b")
        for (pkg in candidates) {
            try {
                pm.getPackageInfo(pkg, 0)
                return pkg
            } catch (_: Exception) {
                // not installed — try next
            }
        }
        return null
    }
}
