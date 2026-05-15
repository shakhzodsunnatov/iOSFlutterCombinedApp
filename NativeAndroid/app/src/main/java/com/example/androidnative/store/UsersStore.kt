package com.example.androidnative.store

import android.content.Context
import com.example.androidnative.models.User
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.time.Instant

class UsersStore(context: Context) {

    private val storageFile = File(context.filesDir, "users.json")

    private val _users = MutableStateFlow<List<User>>(emptyList())
    val users: StateFlow<List<User>> = _users.asStateFlow()

    init {
        _users.value = load()
    }

    fun add(name: String, email: String, source: User.Source): User {
        val user = User(name = name, email = email, source = source)
        _users.value = _users.value + user
        save()
        return user
    }

    fun delete(id: String) {
        _users.value = _users.value.filter { it.id != id }
        save()
    }

    fun bridgeMaps(): List<Map<String, Any>> = _users.value.map { it.toBridgeMap() }

    private fun load(): List<User> {
        if (!storageFile.exists()) return emptyList()
        return try {
            val array = JSONArray(storageFile.readText())
            (0 until array.length()).mapNotNull { i ->
                val obj = array.getJSONObject(i)
                User(
                    id = obj.getString("id"),
                    name = obj.getString("name"),
                    email = obj.getString("email"),
                    source = User.Source.fromValue(obj.getString("source")),
                    createdAt = Instant.parse(obj.getString("createdAt")),
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun save() {
        val array = JSONArray()
        _users.value.forEach { user ->
            array.put(JSONObject(user.toBridgeMap()))
        }
        storageFile.writeText(array.toString(2))
    }
}
