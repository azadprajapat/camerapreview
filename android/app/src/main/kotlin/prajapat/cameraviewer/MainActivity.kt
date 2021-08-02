package prajapat.cameraviewer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.os.Build
import android.os.Handler
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.atan
import kotlin.math.sqrt


class MainActivity : FlutterActivity() {

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    if (call.method == "cameradata") {
                        startCameraSession(result);
                    }
                }
    }

    companion object {
        private const val CHANNEL = "get"
    }

    private fun startCameraSession(result: MethodChannel.Result) {
        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        if (cameraManager.cameraIdList.isEmpty()) {
        }
        val firstCamera = cameraManager.cameraIdList[0]
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        cameraManager.openCamera(firstCamera, object : CameraDevice.StateCallback() {
            override fun onDisconnected(p0: CameraDevice) {}
            override fun onError(p0: CameraDevice, p1: Int) {}

            override fun onOpened(cameraDevice: CameraDevice) {
                // use the camera
                val cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraDevice.id)
                val cOrientation = cameraCharacteristics.get(CameraCharacteristics.LENS_FACING);
                if(cOrientation!= CameraCharacteristics.LENS_FACING_BACK){
                    result.success("Front camera is on")
                }
                try {
                    val focal_length = cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)[0];
                    val physicalsize = cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE);
                    val sensorh= physicalsize.height;
                    val sensorw = physicalsize.width;
                    val sensor_px_w= cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE).width;
                    val sensor_px_h= cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE).height;
                    val hfv = 2 * atan(sensorw / (2 * focal_length));
                    val vfv = 2 * atan(sensorh / (2 *focal_length));
                     result.success(hashMapOf(
                            "sensorw" to sensorw,
                            "sensorh" to sensorh,
                            "hfv" to hfv,
                            "vfv" to vfv,
                            "sensorpx" to sensor_px_w,
                            "sensorpy" to sensor_px_h,
                            "focal_length" to focal_length))
                } catch (e: Exception) {
                    Log.v("Error", "cant get ydpi")
                }

            }
        }, Handler { true })
    }
}
