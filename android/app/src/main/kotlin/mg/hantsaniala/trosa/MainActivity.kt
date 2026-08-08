package mg.hantsaniala.trosa

import android.annotation.SuppressLint
import android.os.Build
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        hideSystemUi()
    }

    // Re-apply the immersive flags whenever the window regains focus. Without
    // this the status bar can reappear (keyboard, dialogs, notification shade)
    // and stay visible — the "app stuck on fullscreen" bug reported on the
    // GT-i9500. IMMERSIVE_STICKY also means a swipe from the edge temporarily
    // reveals the bars, so the user is never permanently locked out.
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) hideSystemUi()
    }

    @SuppressLint("InlinedApi")
    private fun hideSystemUi() {
        val decorView = window.decorView
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // KitKat+ (API 19): true immersive mode with sticky edge-swipe.
            decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                    View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                    View.SYSTEM_UI_FLAG_FULLSCREEN
        } else {
            // Pre-KitKat (Jelly Bean, e.g. the GT-i9500 on Android 4.2.2):
            // no immersive mode — hide the bars and dim the nav keys.
            decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_LOW_PROFILE or
                    View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                    View.SYSTEM_UI_FLAG_FULLSCREEN
        }
    }
}
