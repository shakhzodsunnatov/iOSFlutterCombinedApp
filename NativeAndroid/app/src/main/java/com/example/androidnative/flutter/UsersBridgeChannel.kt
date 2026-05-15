package com.example.androidnative.flutter

import com.example.androidnative.models.User
import com.example.androidnative.store.UsersStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class UsersBridgeChannel(
    messenger: BinaryMessenger,
    private val store: UsersStore,
    private val onCloseFlutter: () -> Unit,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    init {
        channel.setMethodCallHandler(this)
    }

    fun invokeMethod(method: String, arguments: Any?) {
        channel.invokeMethod(method, arguments)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getUsers" -> result.success(store.bridgeMaps())

            "createUser" -> {
                val name = (call.argument<String>("name") ?: "").trim()
                val email = (call.argument<String>("email") ?: "").trim()
                if (name.isEmpty() || email.isEmpty()) {
                    result.error("invalid_arguments", "createUser expects name and email", null)
                    return
                }
                val user = store.add(name = name, email = email, source = User.Source.FLUTTER)
                result.success(user.toBridgeMap())
            }

            "deleteUser" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrEmpty()) {
                    result.error("invalid_arguments", "deleteUser expects id", null)
                    return
                }
                store.delete(id)
                result.success(true)
            }

            "closeFlutter" -> {
                onCloseFlutter()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    fun destroy() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        const val CHANNEL_NAME = "com.huh.nativeflutter/users"
    }
}
