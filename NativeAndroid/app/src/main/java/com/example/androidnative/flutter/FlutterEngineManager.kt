package com.example.androidnative.flutter

import android.content.Context
import com.example.androidnative.store.UsersStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

object FlutterEngineManager {

    lateinit var engine: FlutterEngine
        private set

    private lateinit var bridgeChannel: UsersBridgeChannel
    private lateinit var eventChannel: UsersEventChannel

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    var onCloseFlutter: (() -> Unit)? = null

    fun warmUp(context: Context, store: UsersStore) {
        engine = FlutterEngine(context)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())

        val messenger = engine.dartExecutor.binaryMessenger

        bridgeChannel = UsersBridgeChannel(
            messenger = messenger,
            store = store,
            onCloseFlutter = { onCloseFlutter?.invoke() },
        )
        eventChannel = UsersEventChannel(messenger = messenger)

        scope.launch {
            store.users.collect { users ->
                eventChannel.push(users.map { it.toBridgeMap() })
            }
        }
    }

    fun presentRoute(route: String) {
        bridgeChannel.invokeMethod("presentRoute", route)
    }
}
