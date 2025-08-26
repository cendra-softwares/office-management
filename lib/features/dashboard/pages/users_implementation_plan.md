# Users Page Implementation Plan

## Overview
This document outlines the implementation plan for adding a users management page to the superadmin dashboard, similar to the existing companies page.

## Database Structure Analysis
From the Supabase database analysis:

### user_profiles Table
- id (uuid)
- full_name (text)
- role (user_role enum with values: superadmin, member, admin, owner)
- company_id (uuid)
- contact_phone (text)
- avatar_url (text)
- deleted_at (timestamptz)
- updated_at (timestamptz)

## Implementation Steps

### 1. Create Users Page
File: `lib/features/dashboard/pages/users_page.dart`

This page will:
- Display a table of all users
- Show columns: Full Name, Role, Company, Contact Phone, Active Status, Actions
- Include sorting functionality similar to companies page
- Have an edit button in the actions column

### 2. Create User Edit Dialog
File: `lib/features/dashboard/widgets/user_edit_dialog.dart`

This dialog will:
- Allow editing of user fields: full_name, role, contact_phone
- Include validation for required fields
- Use a dropdown for role selection with the available enum values
- Follow the same pattern as `owner_change_dialog.dart`

### 3. Update Supabase Service
File: `lib/core/services/supabase_service.dart`

Add new methods:
- `fetchAllUsers({String sortBy = 'full_name', bool ascending = true})`
- `updateUser({required String userId, required Map<String, dynamic> updates})`

### 4. Update SuperAdmin Dashboard
File: `lib/features/dashboard/pages/superadmin_dashboard_page.dart`

- Add navigation to the new users page
- Update the "Users" card to navigate to the users page instead of the TODO

## UI Components

### Users Page Structure
```dart
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Methods for data fetching, sorting, and state management
}
```

### User Edit Dialog Structure
```dart
class UserEditDialog extends StatefulWidget {
  const UserEditDialog({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}
```

## Data Flow

1. UsersPage fetches all users from SupabaseService
2. Users are displayed in a sortable table
3. When edit button is clicked, UserEditDialog is shown
4. UserEditDialog allows modification of user fields
5. Changes are saved through SupabaseService
6. UsersPage refreshes data after successful update

## Similarities to Companies Page

- Table-based layout with sorting
- Dialog-based editing
- Similar state management patterns
- Consistent styling with shadcn_ui components
- Error handling and user feedback

## Required Enum Values

User roles: superadmin, member, admin, owner

## Implementation Sequence

1. Create users_page.dart with basic structure
2. Add new methods to SupabaseService
3. Create user_edit_dialog.dart
4. Update superadmin_dashboard_page.dart navigation
5. Test functionality