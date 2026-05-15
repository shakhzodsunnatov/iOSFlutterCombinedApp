package com.example.androidnative

import android.app.Application
import com.example.androidnative.flutter.FlutterEngineManager
import com.example.androidnative.store.UsersStore

class NativeAndroidApp : Application() {

    lateinit var store: UsersStore
        private set

    override fun onCreate() {
        super.onCreate()
        store = UsersStore(this)
        FlutterEngineManager.warmUp(this, store)
    }
}
