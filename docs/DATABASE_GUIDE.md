# Database Guide: Multi-Tenant Project Management App

This document is the single source of truth for understanding the database schema, its underlying logic, and the best practices for building an application on top of it.

## Table of Contents

1.  [Core Concepts](#core-concepts)
2.  [Schema Deep Dive](#schema-deep-dive)
    - [`companies`](#1-companies)
    - [`user_profiles`](#2-user_profiles)
    - [`projects`](#3-projects)
3.  [Key Functions & Triggers](#key-functions--triggers)
4.  [Building Your Application: A Practical Guide](#building-your-application-a-practical-guide)
    - [How to Set Up the Superadmin](#how-to-set-up-the-superadmin)
    - [User & Company Onboarding Flow](#user--company-onboarding-flow)
    - [Checking for Access](#checking-for-access)
    - [Superadmin Tasks](#superadmin-tasks)
5.  [Dos and Don'ts](#dos-and-donts)

---

## Core Concepts

This database is designed for a multi-tenant SaaS application where security, automation, and scalability are paramount.

### 1. Multi-Tenancy

The entire system revolves around the `companies` table. Every significant piece of data (like users and projects) belongs to a company. Row Level Security (RLS) ensures that users from one company can **never** see data from another.

### 2. The Superadmin Role

There is a special `user_role` called `'superadmin'`. A superadmin:

- Does **not** belong to a company (`company_id` is `NULL` in their profile).
- Bypasses almost all Row Level Security rules.
- Is responsible for managing companies (approving, banning, extending trials).
- Is created manually in the database (see setup guide below).

### 3. Automated Trial System

The trial system is automated through a combination of fields and triggers.

- `companies.is_active`: This is the **superadmin's master switch**. If you set this to `false`, the company is immediately locked out, regardless of their trial status.
- `companies.trial_end_date`: Determines when a trial expires.
- `companies.status` (ENUM): This is the **system's calculated state** (`trialing`, `active`, `expired`, `canceled`). It is automatically kept in sync by a trigger. **You should not set this field manually.**

### 4. Security via Row Level Security (RLS)

**RLS is enabled on all tables by default.** It is the primary security mechanism. All data access from the client-side (e.g., your web app) is filtered by these policies. You should **never** need to write `WHERE company_id = '...'` in your client-side code, as the database handles this automatically and securely.

### 5. Soft Deletes

The `user_profiles` table uses a soft-delete pattern. When a user is "deleted," you should `UPDATE` their `deleted_at` column to the current timestamp. They will be hidden from all queries but their data will be preserved. Hard `DELETE` operations are restricted to the superadmin.

---

## Schema Deep Dive

### 1. `companies`

- **Purpose**: Represents a tenant in the application. This is the central table.
- **Key Columns**:
  - `is_active` (boolean): The superadmin's manual override. Set to `false` to ban a company.
  - `status` (company_status): The calculated state of the company. **This is the field your application should read to determine access.**
  - `trial_end_date` (timestamptz): The date the trial expires. `NULL` for paid/active customers.

### 2. `user_profiles`

- **Purpose**: Extends the built-in `auth.users` table with application-specific data.
- **Key Columns**:
  - `id` (uuid): A foreign key to `auth.users.id`, creating a 1-to-1 relationship.
  - `company_id` (uuid): Links the user to their company. Can be `NULL` only for the `superadmin`.
  - `role` (user_role): Determines the user's permissions within their company (`owner`, `admin`, `member`) or the system (`superadmin`).
  - `deleted_at` (timestamptz): If this is not `NULL`, the user is considered deleted and will be hidden by RLS policies.

### 3. `projects`

- **Purpose**: Stores project information.
- **Key Columns**:
  - `company_id` (uuid): Ensures every project belongs to a company. Access is strictly controlled by RLS to only allow members of that company.

---

## Key Functions & Triggers

The database contains several functions and triggers that provide automation and security.

- **`sync_company_status()` (Trigger)**:

  - Fires `BEFORE` any `INSERT` or `UPDATE` on the `companies` table.
  - It reads `is_active` and `trial_end_date` and automatically sets the `status` ENUM correctly.
  - **This is the heart of the trial automation.**

- **`handle_updated_at()` (Trigger)**:

  - A standard utility that automatically updates the `updated_at` timestamp on any row change.

- **`is_company_active(uuid)` (RLS Helper Function)**:

  - The single function used in RLS policies to check if a company should have access.
  - It simply checks if `status` is `'trialing'` or `'active'`.
  - This is your single source of truth for access control.

- **`get_my_company_id()`, `get_my_role()`, `is_superadmin()` (RLS Helper Functions)**:
  - These functions provide the context of the currently logged-in user (`auth.uid()`) to the RLS policies, making them clean and powerful.

---

## Building Your Application: A Practical Guide

### How to Set Up the Superadmin

The first superadmin must be created manually.

1.  Sign up for a new user account in your app normally.
2.  Go to the Supabase Table Editor -> `user_profiles` table.
3.  Find the row for your new user.
4.  Change their `role` to `'superadmin'`.
5.  Set their `company_id` to `NULL`.

### User & Company Onboarding Flow

When a new user signs up and creates a new company, you must perform these steps **in order**:

1.  **Create the Company**: `INSERT` a new record into the `companies` table. The `trial_end_date` and `status` will be set automatically by their defaults and the trigger.
2.  **Create the User Profile**: After getting the `id` of the newly created company, `INSERT` a record into `user_profiles`.
    - `id`: Use the `id` from the newly created `auth.users` record.
    - `company_id`: Use the `id` from step 1.
    - `role`: Set this to `'owner'`.

### Checking for Access

In your application code, you don't need to worry about trial dates. The RLS policies handle it all.

- Simply query for the data you need (e.g., `supabase.from('projects').select('*')`).
- If the user's company is expired or banned, the query will correctly return an empty array or throw a security error.
- On your dashboard, you can display the company's `status` to the user so they know if their trial is `expired`.

### Superadmin Tasks

- **To Ban a Company**: `UPDATE companies SET is_active = false WHERE id = ...`
- **To Un-ban a Company**: `UPDATE companies SET is_active = true WHERE id = ...`
- **To Extend a Trial**: `UPDATE companies SET trial_end_date = 'YYYY-MM-DD' WHERE id = ...`
- **To Convert a Trial to a Paid Plan**: `UPDATE companies SET trial_end_date = NULL WHERE id = ...` (The trigger will automatically set the `status` to `'active'`).
- **To "Delete" a User**: `UPDATE user_profiles SET deleted_at = now() WHERE id = ...`

---

## Dos and Don'ts

### ✅ Do

- **Trust the Database**: Let RLS do its job. Write your frontend queries as if you're only dealing with one user's data.
- **Use the `status` field**: Read the `companies.status` field in your UI to show users their current state (Trialing, Expired, etc.).
- **Use Soft Deletes**: Always update `deleted_at` instead of running a `DELETE` command on users, unless you are a superadmin cleaning up data.
- **Wrap Onboarding in a Transaction**: When creating a new company and user, use a database function (`RPC`) to ensure both operations succeed or fail together.
- **Protect your Superadmin Account**: Use a strong, unique password and enable Multi-Factor Authentication (MFA).

### ❌ Don't

- **Never Bypass RLS**: Do not use the `service_role` key on the client-side. It is for server-side administrative tasks only.
- **Don't Manually Set `status`**: The `sync_company_status` trigger handles this. Manual changes will be overwritten.
- **Don't Replicate Security Logic**: Do not write frontend code that checks `trial_end_date > now()`. This logic belongs in the database (`is_company_active` function) and duplicating it is asking for bugs.
- **Don't Hardcode Roles**: Don't check for roles like `if (user.role === 'owner')` on the client for security. The database RLS policies should be the ultimate authority on what a user can or cannot do.
