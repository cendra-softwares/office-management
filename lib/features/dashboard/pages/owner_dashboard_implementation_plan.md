# Owner Dashboard Implementation Plan

This document outlines the plan for implementing the owner-specific dashboard in the office management application.

## 1. Role-Based Access

- **Objective:** Ensure that only users with the 'owner' role can access the dashboard.
- **Implementation:**
    - In `lib/features/dashboard/pages/dashboard_page.dart`, fetch the current user's role from the `user_profiles` table.
    - If the user's role is not 'owner', redirect them to an appropriate page (e.g., a "not authorized" page or the login page).

## 2. UI Structure

- **Objective:** Create a dashboard UI similar to the superadmin dashboard, with a grid-based layout for key metrics and actions.
- **Implementation:**
    - Use a `Scaffold` with an `AppBar`.
    - The body will contain a `GridView.count` to display dashboard items.
    - Create a `HoverCard` widget (similar to the one in `superadmin_dashboard_page.dart`) for each dashboard item.

## 3. Projects Table

- **Objective:** Display a table of projects associated with the owner's company.
- **Implementation:**
    - Create a new page, `lib/features/dashboard/pages/projects_page.dart`, to display the projects table.
    - The projects page will be similar in structure to `lib/features/dashboard/pages/companies_page.dart`.
    - Fetch projects from the `projects` table, filtered by the `company_id` of the logged-in owner.
    - The table will display columns such as 'Project Name', 'Status', 'Start Date', and 'End Date'.
    - Implement sorting for the table columns.

## 4. Project Creation

- **Objective:** Allow owners to create new projects.
- **Implementation:**
    - Add a "Create Project" button on the `projects_page.dart`.
    - Clicking the button will open a dialog for creating a new project.
    - The dialog will contain a form with fields for project name, description, start date, and end date.
    - Upon successful creation, the projects table will be refreshed to display the new project.

## 5. Navigation

- **Objective:** Add a "Projects" card to the owner's dashboard to navigate to the projects page.
- **Implementation:**
    - In `dashboard_page.dart`, add a `HoverCard` for "Projects".
    - The `onTap` action for the card will navigate to the `ProjectsPage`.

## Mermaid Diagram

```mermaid
graph TD
    A[Owner Dashboard] --> B{Projects};
    B --> C[Projects Table];
    C --> D[Create Project Dialog];