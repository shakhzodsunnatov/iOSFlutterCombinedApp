package com.example.androidnative.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.androidnative.models.User
import com.example.androidnative.store.UsersStore
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class UsersViewModel(private val store: UsersStore) : ViewModel() {

    val users: StateFlow<List<User>> = store.users
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    fun addUser(name: String, email: String) {
        viewModelScope.launch {
            store.add(name = name, email = email, source = User.Source.ANDROID)
        }
    }

    fun deleteUser(id: String) {
        viewModelScope.launch {
            store.delete(id)
        }
    }

    class Factory(private val store: UsersStore) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T =
            UsersViewModel(store) as T
    }
}
