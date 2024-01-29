import android.companion.CompanionDeviceManager

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat.getSystemService
import cz.scalesoft.fons.care.BLUETOOTH_SYNC_METHOD
import cz.scalesoft.fons.care.FLUTTER_TIMEOUT_MILLIS
import cz.scalesoft.fons.care.MAC_ADDRESS_KEY
import cz.scalesoft.fons.care.METHOD_CHANNEL_NAME
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.withTimeout

class ServiceManager(private val flutterEngine: FlutterEngine, private var deviceManager: CompanionDeviceManager) : AutoCloseable {

    private var noGuiMethodChannel: MethodChannel =
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)

    companion object {
        suspend fun create(appContext: Context): ServiceManager {
            println("Kotlin: creating flutter engine")
            // The original flutter engine gets destroyed when the app closes, so we need to create a new one
            val engineCompletable = CompletableDeferred<FlutterEngine>()

            // Flutter engines can only be created, destroyed and communicated with from the UI thread.
            Handler(Looper.getMainLooper()).post {
                println("Kotlin: jumped to main thread")
                val flutterEngine = FlutterEngine(appContext)

                println(DartExecutor.DartEntrypoint.createDefault().pathToBundle);
                flutterEngine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint(
                        "flutter_assets",
                        "watchSyncBackgroundTask"
                    )
                )

                engineCompletable.complete(flutterEngine)
            }

            val deviceManager = getSystemService(appContext, CompanionDeviceManager::class.java) as CompanionDeviceManager

            val engine = engineCompletable.await()

            return ServiceManager(engine, deviceManager)
        }
    }

    private fun getAssociatedDevices(): List<String> {


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return deviceManager.myAssociations.map { x -> x.deviceMacAddress.toString() }.toList()
        } else {
            // There is no alternative for Android < 13
            @Suppress("DEPRECATION")
            return deviceManager.associations;
        }
    }

    suspend fun callFlutterAsync() {
        val devices = getAssociatedDevices();

        val completable = CompletableDeferred<Boolean>()

        val callback = object : MethodChannel.Result {
            override fun success(result: Any?) {
                completable.complete(true)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                completable.completeExceptionally(RuntimeException(errorMessage))
            }

            override fun notImplemented() {
                completable.completeExceptionally(NotImplementedError())
            }
        }

        // InvokeMethod can only be called from the UI thread
        Handler(Looper.getMainLooper()).post {
            println("Kotlin: invoking method from main thread")
            this.noGuiMethodChannel.invokeMethod(
                BLUETOOTH_SYNC_METHOD,
                mapOf(MAC_ADDRESS_KEY to devices),
                callback
            )
        }

        withTimeout(FLUTTER_TIMEOUT_MILLIS) {
            completable.await()
        }
    }

    override fun close() {
        Handler(Looper.getMainLooper()).post {
            flutterEngine.destroy()
        }
    }
}