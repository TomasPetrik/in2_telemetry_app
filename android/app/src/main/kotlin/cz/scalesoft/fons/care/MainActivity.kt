package cz.scalesoft.fons.care

import android.app.Activity
import android.bluetooth.le.ScanFilter
import android.companion.AssociationInfo
import android.companion.AssociationRequest
import android.companion.BluetoothLeDeviceFilter
import android.companion.CompanionDeviceManager
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequest
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.concurrent.Executor
import java.util.concurrent.TimeUnit

// A randomly selected constant unique value
const val SELECT_DEVICE_REQUEST_CODE = 923919

class MainActivity() : FlutterActivity() {
    private var deviceManagerCompletable: CompletableDeferred<Boolean>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val guiMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
        guiMethodChannel.setMethodCallHandler { call, result ->
            println("Kotlin: received method call ${call.method}")
            when (call.method) {

                DISASSOCIATE_DEVICES -> {
                    val macAddresses = call.argument<List<String>>(MAC_ADDRESS_KEY);
                    if (macAddresses != null) {
                        disassociateDevices(macAddresses)
                    }
                    result.success(null)
                }

                ASSOCIATE_DEVICES -> {
                    val scope = CoroutineScope(Dispatchers.IO)
                    val macAddresses = call.argument<List<String>>(MAC_ADDRESS_KEY);
                    if (macAddresses.isNullOrEmpty()) {
                        result.success(null);
                        return@setMethodCallHandler
                    }
                    scope.launch {
                        try {
                            associateDevices(macAddresses)
                            result.success(null)
                        } catch (e: RuntimeException) {
                            result.error("associate-failed", e.toString(), null)
                        }
                    }
                }

                GET_ASSOCIATED_DEVICES -> {
                    val associations = getAssociatedDevices()
                    result.success(associations)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getAssociatedDevices(): List<String> {
        val deviceManager = getSystemService(Context.COMPANION_DEVICE_SERVICE) as CompanionDeviceManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return deviceManager.myAssociations.map { x -> x.deviceMacAddress.toString() }.toList()
        } else {
            // There is no alternative for Android < 13
            @Suppress("DEPRECATION")
            return deviceManager.associations;
        }
    }

    private fun disassociateDevices(macAddresses: List<String>) {
        println(macAddresses.first())
        val deviceManager = getSystemService(Context.COMPANION_DEVICE_SERVICE) as CompanionDeviceManager

        val associationsEmpty: Boolean

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            for (association in deviceManager.myAssociations) {
                println(association.deviceMacAddress)
                if (macAddresses.any { x -> x.lowercase() == association.deviceMacAddress.toString().lowercase() }) {
                    println("Kotlin: Disassociating $association")
                    deviceManager.disassociate(association.id)
                }

            }

            associationsEmpty = deviceManager.myAssociations.isEmpty()
        } else {
            // There is no alternative for Android < 13
            @Suppress("DEPRECATION")
            for (address in macAddresses) {
                deviceManager.disassociate(address)
            }
            @Suppress("DEPRECATION")
            associationsEmpty = deviceManager.associations.isEmpty();
        }

        if (associationsEmpty) {
            println("Kotlin: Deactivating background service")
            val wm = WorkManager.getInstance(applicationContext)
            wm.cancelUniqueWork(UNIQUE_WORK_NAME)
        }
    }

    private suspend fun associateDevices(macAddresses: List<String>) {
        val deviceManager = getSystemService(Context.COMPANION_DEVICE_SERVICE) as CompanionDeviceManager

        for (address in macAddresses) {
            val macAddressFilter = ScanFilter.Builder()
                .setDeviceAddress(address)
                .build()

            val deviceFilter =
                BluetoothLeDeviceFilter.Builder()
                    .setScanFilter(macAddressFilter).build()

            val associationRequest = AssociationRequest.Builder()
                .addDeviceFilter(deviceFilter)
                .setSingleDevice(true)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                associateDevice(deviceManager, associationRequest)
            } else {
                associateDeviceLegacy(deviceManager, associationRequest)
            }
        }

        val wm = WorkManager.getInstance(applicationContext)
        wm.cancelAllWork()
        wm.enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME, ExistingPeriodicWorkPolicy.CANCEL_AND_REENQUEUE,
            PeriodicWorkRequest.Builder(WatchWorker::class.java, 15, TimeUnit.MINUTES)
                .setInitialDelay(5, TimeUnit.SECONDS)
                .build()
        )
    }


    private suspend fun associateDeviceLegacy(
        deviceManager: CompanionDeviceManager,
        associationRequest: AssociationRequest
    ) {
        deviceManagerCompletable = CompletableDeferred()

        deviceManager.associate(
            associationRequest,
            object : CompanionDeviceManager.Callback() {
                @Deprecated("Deprecated in Java")
                override fun onDeviceFound(intentSender: IntentSender) {
                    startIntentSenderForResult(intentSender, SELECT_DEVICE_REQUEST_CODE, null, 0, 0, 0)
                    println("Found device?")
                }

                override fun onFailure(error: CharSequence?) {
                    deviceManagerCompletable?.completeExceptionally(RuntimeException(error.toString()))
                }
            }, null
        )

        deviceManagerCompletable?.await()
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private suspend fun associateDevice(deviceManager: CompanionDeviceManager, associationRequest: AssociationRequest) {
        deviceManagerCompletable = CompletableDeferred()

        val executor = Executor { it.run() }

        deviceManager.associate(
            associationRequest,
            executor,
            object : CompanionDeviceManager.Callback() {
                override fun onAssociationPending(intentSender: IntentSender) {
                    startIntentSenderForResult(intentSender, SELECT_DEVICE_REQUEST_CODE, null, 0, 0, 0)
                    println("Kotlin: Found device")
                }

                override fun onAssociationCreated(associationInfo: AssociationInfo) {
                    println("Kotlin: Association created: ${associationInfo.deviceMacAddress}")
                    deviceManagerCompletable?.complete(true)
                }


                override fun onFailure(error: CharSequence?) {
                    deviceManagerCompletable?.completeExceptionally(RuntimeException(error.toString()))
                }
            },
        )

        deviceManagerCompletable?.await()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return super.onActivityResult(requestCode, resultCode, data)
        }

        when (requestCode) {
            SELECT_DEVICE_REQUEST_CODE -> when (resultCode) {
                Activity.RESULT_OK -> {
                    println("Kotlin: Successfully associated with device")
                    deviceManagerCompletable?.complete(true)
                }

                else -> {
                    println("Kotlin: Failed to associate with device")
                    deviceManagerCompletable?.completeExceptionally(RuntimeException())
                }
            }
        }

        return super.onActivityResult(requestCode, resultCode, data)
    }
}
