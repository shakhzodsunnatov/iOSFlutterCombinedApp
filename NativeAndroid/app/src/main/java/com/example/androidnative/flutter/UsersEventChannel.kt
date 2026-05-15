package com.example.androidnative.flutter

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class UsersEventChannel(messenger: BinaryMessenger) : EventChannel.StreamHandler {

    private val channel = EventChannel(messenger, CHANNEL_NAME)
    private var eventSink: EventChannel.EventSink? = null

    init {
        channel.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun push(users: List<Map<String, Any>>) {
        eventSink?.success(users)
    }

    fun destroy() {
        channel.setStreamHandler(null)
    }

    companion object {
        const val CHANNEL_NAME = "com.huh.nativeflutter/users/stream"
    }
}
