package com.example.whatsapp_status_saver

import android.media.MediaScannerConnection
import android.os.Build
import android.os.Handler
import android.os.Looper

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val CHANNEL = "whatsappstatussaver.com/common"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, rawResult ->
            val result = MethodResultWrapper(rawResult)
            when (call.method) {
                "getAndroidVersion" -> {
                    result.success(Build.VERSION.RELEASE)
                    return@setMethodCallHandler
                }
                "sendMediaScannerBroadcast" -> {
                    val filePaths = arrayOf(call.arguments as String);
                    MediaScannerConnection.scanFile(applicationContext, filePaths, null) { _, _ ->
                        result.success(true)
                    }
                    return@setMethodCallHandler
                }
                else -> result.notImplemented()
            }
        }
    }

    private class MethodResultWrapper(result: MethodChannel.Result) :
        MethodChannel.Result {
        private val methodResult: MethodChannel.Result
        private val handler: Handler

        init {
            methodResult = result
            handler = Handler(Looper.getMainLooper())
        }

        override fun success(result: Any?) {
            handler.post {
                methodResult.success(result)
            }
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            handler.post {
                methodResult.error(errorCode, errorMessage, errorDetails)
            }
        }

        override fun notImplemented() {
            handler.post {
                methodResult.notImplemented()
            }
        }
    }
}
