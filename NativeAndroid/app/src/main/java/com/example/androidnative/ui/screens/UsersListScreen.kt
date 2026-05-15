package com.example.androidnative.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.androidnative.models.User
import com.example.androidnative.ui.UsersViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UsersListScreen(
    viewModel: UsersViewModel,
    onOpenFlutter: (route: String) -> Unit,
) {
    val users by viewModel.users.collectAsState()
    var showCreateSheet by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Users") })
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { showCreateSheet = true }) {
                Icon(Icons.Default.Add, contentDescription = "Add user")
            }
        },
        bottomBar = {
            BottomButtons(onOpenFlutter = onOpenFlutter)
        },
    ) { padding ->
        if (users.isEmpty()) {
            EmptyState(modifier = Modifier.padding(padding))
        } else {
            LazyColumn(
                contentPadding = PaddingValues(
                    top = padding.calculateTopPadding() + 8.dp,
                    bottom = padding.calculateBottomPadding() + 8.dp,
                ),
            ) {
                items(users, key = { it.id }) { user ->
                    UserRow(
                        user = user,
                        onDelete = { viewModel.deleteUser(user.id) },
                    )
                    HorizontalDivider(modifier = Modifier.padding(start = 72.dp))
                }
            }
        }
    }

    if (showCreateSheet) {
        CreateUserSheet(
            onDismiss = { showCreateSheet = false },
            onSave = { name, email ->
                viewModel.addUser(name, email)
                showCreateSheet = false
            },
        )
    }
}

@Composable
private fun UserRow(user: User, onDelete: () -> Unit) {
    val isAndroid = user.source == User.Source.ANDROID
    val accentColor = if (isAndroid) Color(0xFF3DDC84) else Color(0xFF54C5F8)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .background(accentColor.copy(alpha = 0.15f)),
            contentAlignment = Alignment.Center,
        ) {
            val initials = user.name
                .split(" ")
                .take(2)
                .mapNotNull { it.firstOrNull()?.uppercaseChar() }
                .joinToString("")
            if (initials.isNotEmpty()) {
                Text(initials, style = MaterialTheme.typography.titleSmall, color = accentColor)
            } else {
                Icon(Icons.Default.Person, contentDescription = null, tint = accentColor)
            }
        }

        Spacer(Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(user.name, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium)
            Text(
                user.email,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        SourceBadge(source = user.source, accentColor = accentColor)

        Spacer(Modifier.width(8.dp))

        IconButton(onClick = onDelete) {
            Icon(
                Icons.Default.Delete,
                contentDescription = "Delete",
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun SourceBadge(source: User.Source, accentColor: Color) {
    Surface(
        shape = RoundedCornerShape(50),
        color = accentColor.copy(alpha = 0.15f),
    ) {
        Text(
            text = source.displayName,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
            style = MaterialTheme.typography.labelSmall,
            color = accentColor,
            fontWeight = FontWeight.SemiBold,
        )
    }
}

@Composable
private fun EmptyState(modifier: Modifier = Modifier) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Icon(
                Icons.Default.Person,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text("No users yet", style = MaterialTheme.typography.titleMedium)
            Text(
                "Tap + to add one from Android,\nor open the Flutter screen.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun BottomButtons(onOpenFlutter: (String) -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colorScheme.surface)
            .navigationBarsPadding()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Button(
            onClick = { onOpenFlutter("users") },
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("Open Flutter Screen")
        }
        OutlinedButton(
            onClick = { onOpenFlutter("create") },
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("Add User via Flutter")
        }
    }
}
