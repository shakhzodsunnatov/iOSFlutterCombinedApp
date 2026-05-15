package com.example.androidnative.models

import java.time.Instant
import java.util.UUID

data class User(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val email: String,
    val source: Source,
    val createdAt: Instant = Instant.now(),
) {
    enum class Source(val value: String) {
        ANDROID("android"),
        FLUTTER("flutter");

        val displayName: String
            get() = when (this) {
                ANDROID -> "Android"
                FLUTTER -> "Flutter"
            }

        companion object {
            fun fromValue(value: String): Source =
                entries.firstOrNull { it.value == value } ?: ANDROID
        }
    }

    fun toBridgeMap(): Map<String, Any> = mapOf(
        "id" to id,
        "name" to name,
        "email" to email,
        "source" to source.value,
        "createdAt" to createdAt.toString(),
    )
}
