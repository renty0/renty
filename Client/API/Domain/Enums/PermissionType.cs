using System.Runtime.Serialization;
using Domain.Attributes;
using Domain.Constants;

namespace Domain.Enums;

public enum PermissionType
{
    // Items
    [EnumMember(Value = "Permissions.Items.View")]
    [Permission("Items", "View", Roles.Admin, Roles.User, Roles.Support)]
    ItemsView,
    [EnumMember(Value = "Permissions.Items.Create")]
    [Permission("Items", "Create", Roles.User)]
    ItemsCreate,
    [EnumMember(Value = "Permissions.Items.Update")]
    [Permission("Items", "Update", Roles.User, Roles.Admin)]
    ItemsUpdate,
    [EnumMember(Value = "Permissions.Items.Delete")]
    [Permission("Items", "Delete", Roles.User, Roles.Admin)]
    ItemsDelete,
    [EnumMember(Value = "Permissions.Items.Verify")]
    [Permission("Items", "Verify", Roles.Admin, Roles.Support)]
    ItemsVerify,

    // Rentals
    [EnumMember(Value = "Permissions.Rentals.View")]
    [Permission("Rentals", "View", Roles.Admin, Roles.User, Roles.Support)]
    RentalsView,
    [EnumMember(Value = "Permissions.Rentals.Approve")]
    [Permission("Rentals", "Approve", Roles.User)]
    RentalsApprove,
    [EnumMember(Value = "Permissions.Rentals.Complete")]
    [Permission("Rentals", "Complete", Roles.User)]
    RentalsComplete,

    // Orders
    [EnumMember(Value = "Permissions.Orders.View")]
    [Permission("Orders", "View", Roles.Admin, Roles.User, Roles.Support)]
    OrdersView,
    [EnumMember(Value = "Permissions.Orders.Manage")]
    [Permission("Orders", "Manage", Roles.Admin, Roles.Support)]
    OrdersManage,

    // Users
    [EnumMember(Value = "Permissions.Users.View")]
    [Permission("Users", "View", Roles.Admin, Roles.Support)]
    UsersView,
    [EnumMember(Value = "Permissions.Users.Create")]
    [Permission("Users", "Create", Roles.Admin)]
    UsersCreate,
    [EnumMember(Value = "Permissions.Users.Update")]
    [Permission("Users", "Update", Roles.Admin)]
    UsersUpdate,
    [EnumMember(Value = "Permissions.Users.Delete")]
    [Permission("Users", "Delete", Roles.Admin)]
    UsersDelete,

    // Roles
    [EnumMember(Value = "Permissions.Roles.View")]
    [Permission("Roles", "View", Roles.Admin, Roles.SuperAdmin)]
    RolesView,
    [EnumMember(Value = "Permissions.Roles.Create")]
    [Permission("Roles", "Create", Roles.SuperAdmin)]
    RolesCreate,
    [EnumMember(Value = "Permissions.Roles.Update")]
    [Permission("Roles", "Update", Roles.SuperAdmin)]
    RolesUpdate,
    [EnumMember(Value = "Permissions.Roles.Delete")]
    [Permission("Roles", "Delete", Roles.SuperAdmin)]
    RolesDelete,

    // Wallet & Payments
    [EnumMember(Value = "Permissions.Wallet.View")]
    [Permission("Wallet", "View", Roles.Admin, Roles.User)]
    WalletView,
    [EnumMember(Value = "Permissions.Payment.Manage")]
    [Permission("Payment", "Manage", Roles.Admin)]
    PaymentManage,

    // Support
    [EnumMember(Value = "Permissions.Support.ManageTickets")]
    [Permission("Support", "ManageTickets", Roles.Admin, Roles.Support)]
    SupportManageTickets,
    [EnumMember(Value = "Permissions.Support.ResolveDisputes")]
    [Permission("Support", "ResolveDisputes", Roles.Admin, Roles.Support)]
    SupportResolveDisputes,

    // Admin/KPIs
    [EnumMember(Value = "Permissions.Admin.ViewDashboard")]
    [Permission("Admin", "ViewDashboard", Roles.Admin, Roles.Support)]
    AdminViewDashboard,
    [EnumMember(Value = "Permissions.Admin.ViewKpis")]
    [Permission("Admin", "ViewKpis", Roles.Admin)]
    AdminViewKpis,
    [EnumMember(Value = "Permissions.Admin.IdentifyFraud")]
    [Permission("Admin", "IdentifyFraud", Roles.Admin)]
    AdminIdentifyFraud
}
