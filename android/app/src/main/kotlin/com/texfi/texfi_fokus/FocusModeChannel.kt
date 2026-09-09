package com.texfi.texfi_fokus

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Тишина на время фокус-сессии.
 *
 * Своими уведомлениями приложение распоряжается само, но человек садится
 * работать не ради тишины от нас — ему мешают чужие. Единственный способ
 * заглушить их, не будучи системным приложением, — попросить режим
 * «Не беспокоить» и снять его после сессии.
 *
 * Фильтр берётся [NotificationManager.INTERRUPTION_FILTER_ALARMS], а не
 * `NONE`: конец сессии приходит уведомлением с категорией `alarm`, и под
 * `NONE` мы заглушили бы сами себя — сессия кончилась бы беззвучно, а это
 * ровно то, ради чего таймер и заводят.
 *
 * Прежний фильтр сохраняется в prefs, а не в поле: процесс могут выгрузить
 * посреди сессии, и тогда снимать режим будет некому. Значение переживает
 * выгрузку, а [restore] на старте приложения возвращает как было.
 */
class FocusModeChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    private val notificationManager: NotificationManager
        get() = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private val prefs
        get() = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isGranted" -> result.success(isGranted())
            "openAccessSettings" -> result.success(openAccessSettings())
            "enable" -> result.success(enable())
            "disable" -> result.success(disable())
            "restore" -> result.success(disable())
            else -> result.notImplemented()
        }
    }

    private fun isGranted(): Boolean = try {
        notificationManager.isNotificationPolicyAccessGranted
    } catch (error: Exception) {
        false
    }

    /**
     * Доступ к «Не беспокоить» не спрашивается диалогом: система открывает
     * свой экран со списком приложений. Вернуть отсюда результат согласия
     * нельзя — его проверяют следующим [isGranted] после возврата в приложение.
     */
    private fun openAccessSettings(): Boolean = try {
        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
        true
    } catch (error: Exception) {
        false
    }

    private fun enable(): Boolean {
        if (!isGranted()) return false
        return try {
            // Запоминаем только первый вход в режим. Повторный вызов посреди
            // сессии (перезаход на экран таймера, возврат из фона) не должен
            // записать поверх наш же ALARMS — иначе снимать будет некуда.
            if (!prefs.contains(KEY_PREVIOUS)) {
                prefs.edit()
                    .putInt(KEY_PREVIOUS, notificationManager.currentInterruptionFilter)
                    .apply()
            }
            notificationManager.setInterruptionFilter(
                NotificationManager.INTERRUPTION_FILTER_ALARMS,
            )
            true
        } catch (error: Exception) {
            false
        }
    }

    private fun disable(): Boolean {
        // Нечего снимать — значит режим ставили не мы, и трогать чужую
        // настройку нельзя: человек мог включить «Не беспокоить» сам.
        if (!prefs.contains(KEY_PREVIOUS)) return true
        val previous = prefs.getInt(
            KEY_PREVIOUS,
            NotificationManager.INTERRUPTION_FILTER_ALL,
        )
        prefs.edit().remove(KEY_PREVIOUS).apply()
        if (!isGranted()) return false
        return try {
            notificationManager.setInterruptionFilter(previous)
            true
        } catch (error: Exception) {
            false
        }
    }

    companion object {
        private const val CHANNEL = "com.texfi.texfi_fokus/focus_mode"
        private const val PREFS = "focus_mode"
        private const val KEY_PREVIOUS = "previous_interruption_filter"

        fun register(messenger: BinaryMessenger, context: Context) {
            MethodChannel(messenger, CHANNEL)
                .setMethodCallHandler(FocusModeChannel(context))
        }
    }
}
