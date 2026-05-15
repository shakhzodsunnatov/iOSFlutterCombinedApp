package com.example.androidnative.ui

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.example.androidnative.flutter.FlutterEngineManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class FlutterHostActivity : FlutterActivity() {

    override fun provideFlutterEngine(context: Context): FlutterEngine =
        FlutterEngineManager.engine

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FlutterEngineManager.onCloseFlutter = { finish() }

        val route = intent.getStringExtra(EXTRA_ROUTE) ?: "users"
        FlutterEngineManager.presentRoute(route)
    }

    override fun onDestroy() {
        FlutterEngineManager.onCloseFlutter = null
        super.onDestroy()
    }

    override fun shouldDestroyEngineWithHost() = false

    companion object {
        private const val EXTRA_ROUTE = "route"

        fun createIntent(context: Context, route: String): Intent =
            Intent(context, FlutterHostActivity::class.java)
                .putExtra(EXTRA_ROUTE, route)
    }
}
