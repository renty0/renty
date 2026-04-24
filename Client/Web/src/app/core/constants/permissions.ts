export const PermissionType = {
  // Users
  Users_View: 'Permissions.Users.View',
  Users_Create: 'Permissions.Users.Create',
  Users_Edit: 'Permissions.Users.Update',
  Users_Delete: 'Permissions.Users.Delete',
  
  // Roles
  Roles_View: 'Permissions.Roles.View',
  Roles_Create: 'Permissions.Roles.Create',
  Roles_Edit: 'Permissions.Roles.Update',
  Roles_Delete: 'Permissions.Roles.Delete',
  Roles_Manage: 'Permissions.Roles.ManagePermissions',

  // Items / Products
  Items_View: 'Permissions.Items.View',
  Items_Create: 'Permissions.Items.Create',
  Items_Edit: 'Permissions.Items.Update',
  Items_Delete: 'Permissions.Items.Delete',
  Items_Verify: 'Permissions.Items.Verify',
  Items_Approve: 'Permissions.Items.Approve',

  // Rentals
  Rentals_View: 'Permissions.Rentals.View',
  Rentals_Approve: 'Permissions.Rentals.Approve',
  Rentals_Complete: 'Permissions.Rentals.Complete',
  Rentals_Edit: 'Permissions.Rentals.Update',

  // Orders
  Orders_View: 'Permissions.Orders.View',
  Orders_Manage: 'Permissions.Orders.Manage',

  // Support & Disputes
  Disputes_View: 'Permissions.Support.ResolveDisputes',
  Disputes_Resolve: 'Permissions.Support.ResolveDisputes',
  Tickets_View: 'Permissions.Support.ManageTickets',
  Tickets_Manage: 'Permissions.Support.ManageTickets',
  Complaints_View: 'Permissions.Support.ManageTickets',

  // Admin & Dashboard
  Dashboards_View: 'Permissions.Admin.ViewDashboard',
  Admin_ViewKpis: 'Permissions.Admin.ViewKpis',
  Admin_IdentifyFraud: 'Permissions.Admin.IdentifyFraud',
  Settings_View: 'Permissions.Admin.ViewDashboard', // Mapping to Dashboard for now if specific setting perm missing
  Settings_Manage: 'Permissions.System.ManageSettings',

  // Wallet
  Wallet_View: 'Permissions.Wallet.View',
  
  // Payment
  Payment_Manage: 'Permissions.Payment.Manage',
} as const;
