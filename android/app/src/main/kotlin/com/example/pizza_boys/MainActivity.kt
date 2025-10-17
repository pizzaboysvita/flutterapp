package com.example.pizza_boys

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= 35) { // Android 15+ (16KB page-size supported)
            // Enable modern edge-to-edge layout
            WindowCompat.setDecorFitsSystemWindows(window, false)
        } else {
            // Fallback for Android 14 and below: manually color status/navigation bars
            window.statusBarColor = getColor(android.R.color.black) // customize if needed
            window.navigationBarColor = getColor(android.R.color.black)
        }
    }
}
