package prajapat.cameraviewer

import android.hardware.Camera
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    var k = 5f
                    var horizontalcameraangle = -1f
                    var verticalcameraangle = -1f
                    val camera = Camera.open(0)
                    if (call.method == "get") {
                        val p = camera.parameters
                        k = p.focalLength
                        result.success(k)
                    }
                    if (call.method == "horizon") {
                        try {
                            val p = camera.parameters
                            horizontalcameraangle = p.horizontalViewAngle
                        } catch (e: Exception) {
                            Log.v("Error", "cant get angle")
                        }
                        result.success(horizontalcameraangle)
                    }
                    if (call.method == "vert") {
                        try {
                            val p = camera.parameters
                            verticalcameraangle = p.verticalViewAngle
                        } catch (e: Exception) {
                            Log.v("Error", "cant get angle")
                        }
                        result.success(verticalcameraangle)
                    }
                }
    }

    companion object {
        private const val CHANNEL = "get"
    }
}
