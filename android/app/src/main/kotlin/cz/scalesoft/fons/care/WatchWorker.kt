package cz.scalesoft.fons.care

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE
import android.graphics.BitmapFactory
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters


class WatchWorker(context: Context, workerParams: WorkerParameters) : CoroutineWorker(context, workerParams) {
    private val channelId = "work-channel"

    override suspend fun doWork(): Result {

        println("kotlin: Worker started work")

        val channel = NotificationChannel(channelId, "Přenos dat", NotificationManager.IMPORTANCE_LOW)
        channel.description = "Informace o přenosu dat z hodinek"

        val notificationManager = getSystemService(applicationContext, NotificationManager::class.java)
        notificationManager?.createNotificationChannel(channel)

        // Below Android 12, foreground services work more reliably (and run more often) than background services.
        // On Android 12 and up, foreground services often crash or don't run at all.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            val fi = createForegroundInfo("Probíhá přenos dat z hodinek")
            setForeground(fi)
            println("kotlin: Worker moved to foreground service")
        }


        val serviceManager = ServiceManager.create(applicationContext)
        println("Kotlin: service manager created");
        serviceManager.use { s -> s.callFlutterAsync() }

        print("Kotlin: flutter finished work")

        return Result.success()
    }

    private fun createForegroundInfo(message: String): ForegroundInfo {
        val id = "2"
        val cancel = "Zrušit"
        val intent = WorkManager.getInstance(applicationContext).createCancelPendingIntent(getId())

        val notification = NotificationCompat.Builder(applicationContext, id)
            .setChannelId(channelId)
            .setContentTitle(message)
            .setTicker(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setLargeIcon(BitmapFactory.decodeResource(applicationContext.resources, R.mipmap.ic_launcher))
            .setOngoing(true)
            .addAction(0, cancel, intent)
            .build()

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ForegroundInfo(1, notification, FOREGROUND_SERVICE_TYPE_CONNECTED_DEVICE)
        } else {
            ForegroundInfo(1, notification)
        }
    }
}