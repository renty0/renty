using Domain.Entities;
using Domain.Enums;
using Domain.Extensions;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data;

public class ApplicationDbContextInitialiser
{
    private readonly ILogger<ApplicationDbContextInitialiser> _logger;
    private readonly ApplicationDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<ApplicationRole> _roleManager;

    public ApplicationDbContextInitialiser(
        ILogger<ApplicationDbContextInitialiser> logger,
        ApplicationDbContext context,
        UserManager<ApplicationUser> userManager,
        RoleManager<ApplicationRole> roleManager)
    {
        _logger = logger;
        _context = context;
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task InitialiseAsync()
    {
        try
        {
            await _context.Database.MigrateAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while initialising the database.");
            throw;
        }
    }

    public async Task SeedAsync()
    {
        try
        {
            await ResetSequencesAsync();
            await TrySeedAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while seeding the database.");
            throw;
        }
    }

    private async Task TrySeedAsync()
    {
        // Create roles
        foreach (var role in Enum.GetNames<SecurityRoles>())
        {
            if (!await _roleManager.RoleExistsAsync(role))
            {
                await _roleManager.CreateAsync(new ApplicationRole(role, $"{role} role"));
            }
        }

        // Seed Permissions
        var permissions = Enum.GetValues<PermissionType>();
        foreach (var perm in permissions)
        {
            var value = perm.ToPermissionString();
            if (!await _context.Permissions.AnyAsync(p => p.Value == value))
            {
                _context.Permissions.Add(new Permission
                {
                    Value = value,
                    Name = perm.ToString(),
                    Module = perm.GetModule(),
                    Action = perm.ToString()
                });
            }
        }
        await _context.SaveChangesAsync();

        // Assign all permissions to SuperAdmin role
        var superAdminRole = await _roleManager.FindByNameAsync(SecurityRoles.SuperAdmin.ToString());
        if (superAdminRole != null)
        {
            var existingPerms = await _context.RolePermissions
                .Where(rp => rp.RoleId == superAdminRole.Id)
                .Select(rp => rp.PermissionValue)
                .ToListAsync();

            foreach (var perm in permissions)
            {
                var value = perm.ToPermissionString();
                if (!existingPerms.Contains(value))
                {
                    _context.RolePermissions.Add(new RolePermission
                    {
                        RoleId = superAdminRole.Id,
                        RoleName = superAdminRole.Name!,
                        PermissionValue = value
                    });
                }
            }
            await _context.SaveChangesAsync();
        }

        // Create super admin user
        var adminEmail = Environment.GetEnvironmentVariable("SEED_ADMIN_EMAIL") ?? "admin@rently.com";
        var adminPassword = Environment.GetEnvironmentVariable("SEED_ADMIN_PASSWORD") ?? "Admin@123!";

        var adminUser = await _userManager.FindByEmailAsync(adminEmail);
        if (adminUser == null)
        {
            adminUser = new ApplicationUser
            {
                UserName = adminEmail,
                Email = adminEmail,
                FirstName = "Super",
                LastName = "Admin",
                EmailConfirmed = true,
                IsActive = true,
                IsVerified = true
            };

            var result = await _userManager.CreateAsync(adminUser, adminPassword);
            if (result.Succeeded)
            {
                await _userManager.AddToRoleAsync(adminUser, SecurityRoles.SuperAdmin.ToString());
                await _userManager.AddToRoleAsync(adminUser, SecurityRoles.Admin.ToString());
                _logger.LogInformation("Super Admin user created successfully.");
            }
            else
            {
                _logger.LogWarning("Failed to create admin user: {Errors}", string.Join(", ", result.Errors.Select(e => e.Description)));
            }
        }
    }

    private async Task ResetSequencesAsync()
    {
        _logger.LogInformation("Resetting database sequences (C# implementation)...");
        try
        {
            // 1. Get all potential identity/serial columns
            var columnsSql = @"
                SELECT table_name as TableName, column_name as ColumnName 
                FROM information_schema.columns 
                WHERE table_schema = 'public' 
                AND (column_default LIKE 'nextval(%' OR is_identity = 'YES')";

            var columns = await _context.Database.SqlQueryRaw<ColumnInfo>(columnsSql).ToListAsync();

            foreach (var col in columns)
            {
                try
                {
                    // 2. Get the actual sequence name for the column
                    var seqNameSql = $"SELECT pg_get_serial_sequence('\"{col.TableName}\"', '{col.ColumnName}') AS \"Value\"";
                    var seqName = await _context.Database.SqlQueryRaw<string>(seqNameSql).FirstOrDefaultAsync();

                    if (!string.IsNullOrEmpty(seqName))
                    {
                        // 3. Get max ID
                        var maxIdSql = $"SELECT COALESCE(MAX(\"{col.ColumnName}\"), 0) AS \"Value\" FROM \"{col.TableName}\"";
                        var maxId = await _context.Database.SqlQueryRaw<long>(maxIdSql).FirstOrDefaultAsync();

                        // 4. Reset sequence
                        var resetSql = $"SELECT setval('{seqName}', {maxId + 1}, false) AS \"Value\"";
                        await _context.Database.ExecuteSqlRawAsync(resetSql);

                        _logger.LogInformation("Reset sequence {Sequence} for table {Table} to {NextValue}", seqName, col.TableName, maxId + 1);
                    }
                    else
                    {
                        _logger.LogWarning("Could not find sequence for {Table}.{Column}", col.TableName, col.ColumnName);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to reset sequence for {Table}.{Column}", col.TableName, col.ColumnName);
                }
            }

            _logger.LogInformation("Database sequences reset completed.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while resetting database sequences.");
        }
    }

    private class ColumnInfo
    {
        public string TableName { get; set; } = string.Empty;
        public string ColumnName { get; set; } = string.Empty;
    }
}
