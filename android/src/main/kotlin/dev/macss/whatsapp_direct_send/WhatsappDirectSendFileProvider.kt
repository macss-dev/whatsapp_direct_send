package dev.macss.whatsapp_direct_send

import androidx.core.content.FileProvider

/**
 * An empty subclass of [FileProvider] whose only purpose is to give this plugin
 * a unique `android:name` in the merged AndroidManifest.
 *
 * Without this, any host app that already uses
 * `androidx.core.content.FileProvider` (directly or via another plugin) will hit
 * a manifest-merger conflict because Android does not allow two `<provider>`
 * entries with the same `android:name`.
 *
 * By using a dedicated subclass the two providers coexist peacefully, each with
 * its own authority and path configuration.
 */
class WhatsappDirectSendFileProvider : FileProvider()
