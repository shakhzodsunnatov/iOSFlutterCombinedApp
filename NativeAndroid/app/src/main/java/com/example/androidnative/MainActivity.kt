package com.example.androidnative

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.androidnative.ui.FlutterHostActivity
import com.example.androidnative.ui.UsersViewModel
import com.example.androidnative.ui.screens.UsersListScreen
import com.example.androidnative.ui.theme.AndroidNativeTheme

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        val store = (application as NativeAndroidApp).store

        setContent {
            AndroidNativeTheme {
                val viewModel: UsersViewModel = viewModel(
                    factory = UsersViewModel.Factory(store)
                )
                UsersListScreen(
                    viewModel = viewModel,
                    onOpenFlutter = { route ->
                        startActivity(FlutterHostActivity.createIntent(this, route))
                    },
                )
            }
        }
    }
}
