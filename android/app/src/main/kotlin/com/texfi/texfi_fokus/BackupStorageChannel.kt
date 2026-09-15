package com.texfi.texfi_fokus

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Доступ к общему внутреннему хранилищу для резервных копий.
 *
 * Папка `TexFi Backup` осознанно лежит в корне внутреннего хранилища, а не
 * в собственной песочнице приложения (`getExternalFilesDir`): песочница
 * исчезает вместе с удалением приложения, а бэкап — это страховка именно на
 * такой случай. Начиная с Android 11 (API 30) произвольная папка вне
 * песочницы читается и пишется только с разрешением
 * `MANAGE_EXTERNAL_STORAGE`, которое выдаётся не диалогом, а отдельным
 * системным экраном — отсюда [requestManageStorage].
 *
 * На Android до 11 для той же папки достаточно обычного
 * `WRITE_EXTERNAL_STORAGE`, которое к этому моменту уже запрошено как обычное
 * разрешение манифеста, и [hasAccess] возвращает true без дополнительного
 * экрана.
 */
class BackupStorageChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasAccess" -> result.success(hasAccess())
            "requestManageStorage" -> result.success(requestManageStorage())
            "openBackupFolder" -> result.success(openBackupFolder())
            else -> result.notImplemented()
        }
    }

    private fun hasAccess(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Environment.isExternalStorageManager()
        } else {
            // До Android 11 доступ к публичной папке хранилища даёт обычное
            // разрешение манифеста, которое уже запрошено в рантайме той же
            // стороной, что показывает объяснение перед первым запросом.
            true
        }
    }

    /**
     * Открывает системный экран согласия на «Доступ ко всем файлам».
     *
     * Результат этого вызова — не согласие, а лишь то, что экран открылся:
     * согласие проверяется следующим [hasAccess] после возврата в приложение,
     * ровно как и доступ к «Не беспокоить» в [FocusModeChannel].
     */
    private fun requestManageStorage(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return true
        return try {
            val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                .setData(Uri.parse("package:${context.packageName}"))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            true
        } catch (error: Exception) {
            // Часть прошивок (в первую очередь без Google Play Services)
            // не поддерживает этот конкретный экран — тогда ведём на общий
            // список разрешений приложения, чтобы попытка не провалилась
            // молча.
            try {
                val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                    .setData(Uri.parse("package:${context.packageName}"))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(fallback)
                true
            } catch (fallbackError: Exception) {
                false
            }
        }
    }

    /**
     * Открывает папку `TexFi Backup` в системном приложении «Файлы» —
     * `ACTION_VIEW` на документ каталога через провайдер общего хранилища.
     *
     * Возвращает `false`, если ни один обработчик не нашёлся: тогда экран
     * импорта в приложении сам покажет путь текстом — честное «не открылось
     * само» лучше вида, что что-то произошло.
     */
    private fun openBackupFolder(): Boolean {
        val documentId = "primary:$BACKUP_FOLDER_NAME"
        val uri = Uri.parse(
            "content://com.android.externalstorage.documents/document/" +
                Uri.encode(documentId),
        )
        return try {
            val intent = Intent(Intent.ACTION_VIEW)
                .setDataAndType(uri, "vnd.android.document/directory")
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            context.startActivity(intent)
            true
        } catch (error: Exception) {
            false
        }
    }

    companion object {
        private const val CHANNEL = "com.texfi.texfi_fokus/backup_storage"
        const val BACKUP_FOLDER_NAME = "TexFi Backup"

        fun register(messenger: BinaryMessenger, context: Context) {
            MethodChannel(messenger, CHANNEL)
                .setMethodCallHandler(BackupStorageChannel(context))
        }
    }
}
