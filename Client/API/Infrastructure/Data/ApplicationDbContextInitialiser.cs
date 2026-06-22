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
        // Cleanup existing test data to ensure clean IDs and relationships
        await CleanSeedDataAsync();

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

        // Create expert user
        var expertEmail = Environment.GetEnvironmentVariable("SEED_EXPERT_EMAIL") ?? "expert@rently.com";
        var expertPassword = Environment.GetEnvironmentVariable("SEED_EXPERT_PASSWORD") ?? "Password12!";

        var expertUser = await _userManager.FindByEmailAsync(expertEmail);
        if (expertUser == null)
        {
            expertUser = new ApplicationUser
            {
                UserName = expertEmail,
                Email = expertEmail,
                FirstName = "Test",
                LastName = "Expert",
                EmailConfirmed = true,
                IsActive = true,
                IsVerified = true
            };

            var result = await _userManager.CreateAsync(expertUser, expertPassword);
            if (result.Succeeded)
            {
                await _userManager.AddToRoleAsync(expertUser, SecurityRoles.Expert.ToString());
                _logger.LogInformation("Expert user created successfully.");
            }
            else
            {
                _logger.LogWarning("Failed to create expert user: {Errors}", string.Join(", ", result.Errors.Select(e => e.Description)));
            }
        }
        else
        {
            // Reset password to ensure it matches the requested seed password
            var token = await _userManager.GeneratePasswordResetTokenAsync(expertUser);
            await _userManager.ResetPasswordAsync(expertUser, token, expertPassword);
        }

        // Create support user
        var supportEmail = Environment.GetEnvironmentVariable("SEED_SUPPORT_EMAIL") ?? "support@renty.com";
        var supportPassword = Environment.GetEnvironmentVariable("SEED_SUPPORT_PASSWORD") ?? "Password12!";

        var supportUser = await _userManager.FindByEmailAsync(supportEmail);
        if (supportUser == null)
        {
            supportUser = new ApplicationUser
            {
                UserName = supportEmail,
                Email = supportEmail,
                FirstName = "Test",
                LastName = "Support",
                EmailConfirmed = true,
                IsActive = true,
                IsVerified = true
            };

            var result = await _userManager.CreateAsync(supportUser, supportPassword);
            if (result.Succeeded)
            {
                await _userManager.AddToRoleAsync(supportUser, SecurityRoles.Support.ToString());
                _logger.LogInformation("Support user created successfully.");
            }
            else
            {
                _logger.LogWarning("Failed to create support user: {Errors}", string.Join(", ", result.Errors.Select(e => e.Description)));
            }
        }
        else
        {
            // Reset password to ensure it matches the requested seed password
            var token = await _userManager.GeneratePasswordResetTokenAsync(supportUser);
            await _userManager.ResetPasswordAsync(supportUser, token, supportPassword);
        }

        // Seed Arabic users
        await SeedArabicUsersAsync();

        // Seed items for the first 10 regular users
        await SeedUserItemsAsync();

        // Seed Rentals and Disputes
        await SeedRentalsAndDisputesAsync();

        // Seed Expert Verifications
        await SeedExpertVerificationsAsync();

        // Seed ID Verifications
        await SeedIdVerificationsAsync();
    }

    private async Task SeedUserItemsAsync()
    {
        // Skip if items already seeded
        if (await _context.Items.AnyAsync())
            return;

        // Get first 10 users with the "User" role
        var userRole = await _roleManager.FindByNameAsync("User");
        if (userRole == null) return;

        var userIds = await _context.UserRoles
            .Where(ur => ur.RoleId == userRole.Id)
            .Select(ur => ur.UserId)
            .ToListAsync();

        var users = await _context.Users
            .Where(u => userIds.Contains(u.Id))
            .OrderBy(u => u.Id)
            .Take(10)
            .ToListAsync();

        if (!users.Any()) return;

        // Item catalog: (TitleAr, TitleEn, DescAr, DescEn, CategoryId, SubcategoryId, BrandId, DailyPrice, WeeklyPrice, MonthlyPrice, Deposit, City, Condition, imageUrl)
        var itemCatalog = new List<(string TitleAr, string TitleEn, string DescAr, string DescEn, int? CatId, int? SubId, int? BrandId, decimal Daily, decimal Weekly, decimal Monthly, decimal Deposit, string City, string Condition, string ImageUrl)>
        {
            ("دراجة هوائية جبلية", "Mountain Bike", "دراجة هوائية جبلية بحالة ممتازة مناسبة للمسالك الوعرة", "Mountain bike in excellent condition suitable for off-road trails", 2, 5, 3, 50, 280, 900, 200, "القاهرة", "like_new", "https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800"),
            ("حذاء تنس احترافي", "Professional Tennis Shoes", "حذاء تنس احترافي مقاس 42 مناسب لملاعب الكلاي والهارد", "Professional tennis shoes size 42, suitable for clay and hard courts", 1, 1, 1, 20, 110, 350, 80, "الإسكندرية", "good", "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800"),
            ("مضرب تنس ويلسون", "Wilson Tennis Racket", "مضرب تنس ويلسون Pro Staff احترافي وزن 315 جرام", "Wilson Pro Staff professional tennis racket, 315g weight", 1, 2, 1, 30, 170, 550, 150, "القاهرة", "like_new", "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800"),
            ("كرة قدم نايك", "Nike Football", "كرة قدم نايك الأصلية مقاس 5 مناسبة للملاعب العشبية", "Original Nike football size 5, suitable for grass pitches", 4, 13, 2, 10, 55, 180, 40, "الجيزة", "new", "https://images.unsplash.com/photo-1614632537197-38a17061c2bd?w=800"),
            ("طاولة بينج بونج", "Ping Pong Table", "طاولة بينج بونج قابلة للطي بحالة جيدة جداً مع مضربين وكرات", "Foldable ping pong table in very good condition with 2 paddles and balls", 3, 9, null, 80, 450, 1400, 300, "الإسكندرية", "good", "https://images.unsplash.com/photo-1534158914592-062992fbe900?w=800"),
            ("حقيبة جيم رياضية", "Sports Gym Bag", "حقيبة جيم رياضية أديداس كبيرة الحجم بجيوب متعددة", "Large Adidas gym sports bag with multiple compartments", 6, 22, 5, 15, 80, 250, 60, "القاهرة", "like_new", "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800"),
            ("حذاء ركض أديداس", "Adidas Running Shoes", "حذاء ركض أديداس الترا بوست مقاس 43 مناسب للجري الطويل", "Adidas Ultraboost running shoes size 43, ideal for long-distance running", 1, 1, 5, 25, 140, 450, 100, "الجيزة", "good", "https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800"),
            ("بدلة سباحة احترافية", "Professional Swimsuit", "بدلة سباحة احترافية للمسابقات مقاس M للرجال", "Professional competition swimsuit size M for men", 5, 17, null, 18, 95, 300, 70, "الإسكندرية", "new", "https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800"),
            ("قفازات ملاكمة", "Boxing Gloves", "قفازات ملاكمة احترافية 12 أوقية مناسبة للتدريب والمنافسة", "Professional boxing gloves 12oz suitable for training and competition", 3, 8, null, 22, 120, 380, 90, "القاهرة", "like_new", "https://images.unsplash.com/photo-1549476464-37392f717541?w=800"),
            ("رياضة ياقا - حصيرة يوغا", "Yoga Mat", "حصيرة يوغا مضادة للانزلاق بسماكة 6 مم مع حقيبة حمل", "Anti-slip yoga mat 6mm thick with carry bag", 3, 10, null, 12, 65, 200, 50, "القاهرة", "new", "https://images.unsplash.com/photo-1601925228028-f9ea4ae61b2f?w=800"),
            ("سيكل تمرين داخلي", "Indoor Cycling Bike", "دراجة تمرين داخلية احترافية بمقاومة متغيرة مناسبة للمنزل والصالة", "Professional indoor cycling bike with variable resistance for home and gym use", 2, 5, null, 90, 500, 1600, 400, "الجيزة", "good", "https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=800"),
            ("كيس ملاكمة", "Punching Bag", "كيس ملاكمة معلق 60 كيلو جرام مناسب للتدريب الاحترافي", "Hanging punching bag 60kg suitable for professional training", 3, 8, null, 35, 200, 650, 150, "الإسكندرية", "good", "https://images.unsplash.com/photo-1590517862411-1c820ef7df6f?w=800"),
            ("مضرب بادمنتون", "Badminton Racket", "مضرب بادمنتون يونيكس احترافي خفيف الوزن للاعبين المتقدمين", "Yonex professional lightweight badminton racket for advanced players", 1, 3, null, 18, 95, 300, 70, "القاهرة", "like_new", "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800"),
            ("عدة صيد احترافية", "Professional Fishing Set", "عدة صيد احترافية تشمل السنارة والبكرة والطعوم المتنوعة", "Professional fishing set including rod, reel, and various lures", 6, 23, null, 40, 220, 700, 180, "الإسكندرية", "good", "https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800"),
            ("كرة سلة سبولدينج", "Spalding Basketball", "كرة سلة سبولدينج رسمية مقاس 7 مناسبة للملاعب الداخلية والخارجية", "Official Spalding basketball size 7, suitable for indoor and outdoor courts", 4, 14, null, 15, 80, 250, 60, "القاهرة", "new", "https://images.unsplash.com/photo-1546519638405-a9d1b8e29a8f?w=800"),
            ("رداء كاراتيه", "Karate Gi", "رداء كاراتيه أبيض قطن 100% مقاس 3 للمبتدئين والمتوسطين", "White 100% cotton karate gi size 3, for beginners and intermediate practitioners", 3, 10, null, 10, 55, 170, 40, "الجيزة", "like_new", "https://images.unsplash.com/photo-1555597673-b21d5c935865?w=800"),
            ("لوح تزلج", "Skateboard", "لوح تزلج احترافي بعجلات عالية الجودة مناسب للشوارع والبارك", "Professional skateboard with high-quality wheels, suitable for streets and skate parks", 2, 7, null, 28, 155, 490, 110, "الإسكندرية", "good", "https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=800"),
            ("جهاز تمرين متعدد", "Multi-Gym Equipment", "جهاز تمرين متعدد الوظائف لتمرين كامل الجسم في المنزل", "Multi-function home gym equipment for full body workout", 3, 10, null, 120, 680, 2200, 500, "القاهرة", "good", "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800"),
            ("خوذة ركوب دراجة", "Cycling Helmet", "خوذة ركوب دراجة بمعايير السلامة الأوروبية مقاس L", "Cycling helmet with European safety standards, size L", 6, 22, null, 8, 42, 130, 30, "الجيزة", "new", "https://images.unsplash.com/photo-1619954611463-ae45b4bbd9a2?w=800"),
            ("مجموعة غطس", "Diving Set", "مجموعة غطس كاملة تشمل الزعانف والقناع وأنبوب التنفس", "Complete diving set including fins, mask, and snorkel tube", 5, 19, null, 55, 310, 1000, 220, "الإسكندرية", "like_new", "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800"),
        };

        var itemIndex = 0;
        var cities = new[] { "القاهرة", "الإسكندرية", "الجيزة", "الإسماعيلية", "أسوان", "المنصورة" };

        for (int i = 0; i < users.Count; i++)
        {
            var user = users[i];
            // Each user gets 2 items
            for (int j = 0; j < 2; j++)
            {
                var catalog = itemCatalog[itemIndex % itemCatalog.Count];
                itemIndex++;

                // Create MediaFile for the image
                var mediaFile = new MediaFile
                {
                    Id = Guid.NewGuid(),
                    StoragePath = catalog.ImageUrl,
                    FileType = FileType.Image,
                    OriginalFileName = $"item_{itemIndex}.jpg",
                    FileExtension = ".jpg",
                    ContentType = "image/jpeg",
                    FileSize = 204800,
                    Width = 800,
                    Height = 600,
                    CreatedAt = DateTime.UtcNow.AddDays(-30 + i)
                };
                _context.MediaFiles.Add(mediaFile);

                var item = new Item
                {
                    Id = Guid.NewGuid(),
                    OwnerId = user.Id,
                    TitleAr = catalog.TitleAr,
                    TitleEn = catalog.TitleEn,
                    DescAr = catalog.DescAr,
                    DescEn = catalog.DescEn,
                    CategoryId = catalog.CatId,
                    SubcategoryId = catalog.SubId,
                    BrandId = catalog.BrandId,
                    // First 7 users get approved items; last 3 get items under review
                    Status = i < 7 ? NewItemStatus.Available : NewItemStatus.UnderReview,
                    Condition = catalog.Condition,
                    DefaultDeposit = catalog.Deposit,
                    Location = catalog.City + "، مصر",
                    City = catalog.City,
                    CancellationPolicy = CancellationPolicy.Flexible,
                    CreatedAt = DateTime.UtcNow.AddDays(-30 + i),
                    UpdatedAt = DateTime.UtcNow.AddDays(-30 + i),
                };

                item.Pricing.Add(new ItemPricing { Id = Guid.NewGuid(), ItemId = item.Id, Price = catalog.Daily,   PricingType = "daily"   });
                item.Pricing.Add(new ItemPricing { Id = Guid.NewGuid(), ItemId = item.Id, Price = catalog.Weekly,  PricingType = "weekly"  });
                item.Pricing.Add(new ItemPricing { Id = Guid.NewGuid(), ItemId = item.Id, Price = catalog.Monthly, PricingType = "monthly" });

                item.Images.Add(new ItemImage
                {
                    Id = Guid.NewGuid(),
                    ItemId = item.Id,
                    ImageId = mediaFile.Id,
                    IsPrimary = true,
                    CreatedAt = DateTime.UtcNow.AddDays(-30 + i)
                });

                _context.Items.Add(item);
            }
        }

        await _context.SaveChangesAsync();
        _logger.LogInformation("Seeded {Count} items for the first 10 regular users.", users.Count * 2);
    }

    private async Task SeedArabicUsersAsync()
    {
        var password = "Password12!";
        
        var maleNames = new[] { "أحمد", "محمد", "عمر", "علي", "كريم", "يوسف", "خالد", "مصطفى", "عمرو", "محمود", "طارق", "هشام", "هاني", "فادي", "شريف" };
        var femaleNames = new[] { "سارة", "فاطمة", "مريم", "ياسمين", "رانيا", "نادين", "هالة", "دينا", "منى", "هند", "ليلى", "ريم", "نور", "سلمى", "فرح" };
        var lastNames = new[] { "الشافعي", "النجار", "الجيار", "منصور", "المهدي", "المصري", "القاضي", "السقا", "زهران", "رضوان", "حماد", "العبد", "غانم", "سليمان", "حسني" };

        // 30 Regular Users
        var createdUserCount = 0;
        for (int i = 1; i <= 30; i++)
        {
            var email = $"user{i}@renty.com";
            try
            {
                var user = await _userManager.FindByEmailAsync(email);
                if (user == null)
                {
                    var isFemale = i % 2 == 0;
                    var firstName = isFemale ? femaleNames[(i - 1) % femaleNames.Length] : maleNames[(i - 1) % maleNames.Length];
                    var lastName = lastNames[(i - 1) % lastNames.Length];

                    // i 1-10: fully verified, 11-20: pending ID (not verified), 21-30: no ID at all
                    var isFullyVerified = i <= 10;
                    user = new ApplicationUser
                    {
                        UserName = email,
                        Email = email,
                        FirstName = firstName,
                        LastName = lastName,
                        EmailConfirmed = true,
                        IsActive = true,
                        IsVerified = isFullyVerified,
                        IdVerified = isFullyVerified,
                        CreatedAt = DateTimeOffset.UtcNow.AddDays(-60 + i)
                    };

                    var result = await _userManager.CreateAsync(user, password);
                    if (result.Succeeded)
                    {
                        await _userManager.AddToRoleAsync(user, SecurityRoles.User.ToString());
                        createdUserCount++;
                    }
                    else
                    {
                        _logger.LogWarning("Failed to create user {Email}: {Errors}", email, string.Join(", ", result.Errors.Select(e => e.Description)));
                    }
                }
                else
                {
                    createdUserCount++;
                    _logger.LogInformation("User {Email} already exists, skipping.", email);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception while creating user {Email}", email);
            }
        }
        _logger.LogInformation("SeedArabicUsersAsync: Created/found {Count} regular users.", createdUserCount);

        // 5 Support Users
        for (int i = 1; i <= 5; i++)
        {
            var email = $"support{i}@renty.com";
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    FirstName = "دعم",
                    LastName = i.ToString(),
                    EmailConfirmed = true,
                    IsActive = true,
                    IsVerified = true
                };

                var result = await _userManager.CreateAsync(user, password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, SecurityRoles.Support.ToString());
                }
            }
        }

        // 5 Admin Users
        for (int i = 1; i <= 5; i++)
        {
            var email = $"admin{i}@renty.com";
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    FirstName = "مدير",
                    LastName = i.ToString(),
                    EmailConfirmed = true,
                    IsActive = true,
                    IsVerified = true
                };

                var result = await _userManager.CreateAsync(user, password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, SecurityRoles.Admin.ToString());
                }
            }
        }

        // 5 Expert Users
        for (int i = 1; i <= 5; i++)
        {
            var email = $"expert{i}@renty.com";
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    FirstName = "خبير",
                    LastName = i.ToString(),
                    EmailConfirmed = true,
                    IsActive = true,
                    IsVerified = true
                };

                var result = await _userManager.CreateAsync(user, password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, SecurityRoles.Expert.ToString());
                }
            }
        }

        // 2 Super Admin Users
        for (int i = 1; i <= 2; i++)
        {
            var email = $"superadmin{i}@renty.com";
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    FirstName = "مدير",
                    LastName = $"عام {i}",
                    EmailConfirmed = true,
                    IsActive = true,
                    IsVerified = true
                };

                var result = await _userManager.CreateAsync(user, password);
                if (result.Succeeded)
                {
                    await _userManager.AddToRoleAsync(user, SecurityRoles.SuperAdmin.ToString());
                    await _userManager.AddToRoleAsync(user, SecurityRoles.Admin.ToString());
                }
            }
        }
    }

    private async Task SeedRentalsAndDisputesAsync()
    {
        if (await _context.Rentals.AnyAsync())
            return;

        // Fetch regular users
        var userRole = await _roleManager.FindByNameAsync("User");
        if (userRole == null) return;
        var userIds = await _context.UserRoles
            .Where(ur => ur.RoleId == userRole.Id)
            .Select(ur => ur.UserId)
            .ToListAsync();
        var users = await _context.Users
            .Where(u => userIds.Contains(u.Id))
            .OrderBy(u => u.Id)
            .ToListAsync();

        var items = await _context.Items.ToListAsync();
        if (users.Count < 10 || items.Count < 10) return;

        // Let's create some rentals.
        // Rental 1: Completed rental. user1 rents item owned by user6
        var r1 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[0].Id,
            ItemId = items.First(item => item.OwnerId == users[5].Id).Id,
            RentalPrice = 150,
            StartDate = DateTime.UtcNow.AddDays(-20),
            EndDate = DateTime.UtcNow.AddDays(-15),
            ActualReturnDate = DateTime.UtcNow.AddDays(-15),
            Status = RentalStatus.Completed,
            DepositAmount = 200,
            DepositStatus = DepositStatus.Returned,
            Notes = "تم الإرجاع بحالة ممتازة وبدون أي تلفيات.",
            CreatedAt = DateTime.UtcNow.AddDays(-22),
            UpdatedAt = DateTime.UtcNow.AddDays(-15)
        };
        _context.Rentals.Add(r1);

        // Rental 2: Completed rental. user2 rents item owned by user7
        var r2 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[1].Id,
            ItemId = items.First(item => item.OwnerId == users[6].Id).Id,
            RentalPrice = 80,
            StartDate = DateTime.UtcNow.AddDays(-10),
            EndDate = DateTime.UtcNow.AddDays(-5),
            ActualReturnDate = DateTime.UtcNow.AddDays(-5),
            Status = RentalStatus.Completed,
            DepositAmount = 100,
            DepositStatus = DepositStatus.Returned,
            Notes = "تجربة ممتازة وسلوك رائع من الطرفين.",
            CreatedAt = DateTime.UtcNow.AddDays(-12),
            UpdatedAt = DateTime.UtcNow.AddDays(-5)
        };
        _context.Rentals.Add(r2);

        // Rental 3: Active rental. user3 rents item owned by user8
        var r3 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[2].Id,
            ItemId = items.First(item => item.OwnerId == users[7].Id).Id,
            RentalPrice = 250,
            StartDate = DateTime.UtcNow.AddDays(-2),
            EndDate = DateTime.UtcNow.AddDays(5),
            Status = RentalStatus.Active,
            DepositAmount = 300,
            DepositStatus = DepositStatus.Held,
            Notes = "المنتج قيد الاستخدام حالياً.",
            CreatedAt = DateTime.UtcNow.AddDays(-4),
            UpdatedAt = DateTime.UtcNow.AddDays(-2)
        };
        _context.Rentals.Add(r3);

        // Rental 4: Active rental. user4 rents item owned by user9
        var r4 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[3].Id,
            ItemId = items.First(item => item.OwnerId == users[8].Id).Id,
            RentalPrice = 120,
            StartDate = DateTime.UtcNow.AddDays(-1),
            EndDate = DateTime.UtcNow.AddDays(3),
            Status = RentalStatus.Active,
            DepositAmount = 150,
            DepositStatus = DepositStatus.Held,
            Notes = "جاري الاستخدام.",
            CreatedAt = DateTime.UtcNow.AddDays(-3),
            UpdatedAt = DateTime.UtcNow.AddDays(-1)
        };
        _context.Rentals.Add(r4);

        // Rental 5: Pending rental. user5 rents item owned by user10
        var r5 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[4].Id,
            ItemId = items.First(item => item.OwnerId == users[9].Id).Id,
            RentalPrice = 90,
            StartDate = DateTime.UtcNow.AddDays(2),
            EndDate = DateTime.UtcNow.AddDays(5),
            Status = RentalStatus.Pending,
            DepositAmount = 100,
            DepositStatus = DepositStatus.Held,
            Notes = "بانتظار موافقة المالك لبدء الإيجار.",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.Rentals.Add(r5);

        // Rental 6: Disputed (Open). user1 rents item owned by user7
        var r6 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[0].Id,
            ItemId = items.First(item => item.OwnerId == users[6].Id).Id,
            RentalPrice = 300,
            StartDate = DateTime.UtcNow.AddDays(-7),
            EndDate = DateTime.UtcNow.AddDays(-2),
            Status = RentalStatus.Disputed,
            DepositAmount = 400,
            DepositStatus = DepositStatus.Held,
            Notes = "يوجد خلاف حول حالة المنتج عند الإرجاع.",
            CreatedAt = DateTime.UtcNow.AddDays(-8),
            UpdatedAt = DateTime.UtcNow.AddDays(-2)
        };
        _context.Rentals.Add(r6);

        // Open dispute support ticket
        var supportAgent = await _userManager.FindByEmailAsync("support1@renty.com");
        var ticket1 = new SupportTicket
        {
            Id = Guid.NewGuid(),
            UserId = users[0].Id,
            Type = SupportTicketType.Rental,
            Status = SupportTicketStatus.Open,
            RelatedRentalId = r6.Id,
            AssignedAgentId = supportAgent?.Id,
            CreatedAt = DateTime.UtcNow.AddDays(-2),
            UpdatedAt = DateTime.UtcNow
        };
        ticket1.Messages.Add(new SupportMessage
        {
            Id = Guid.NewGuid(),
            TicketId = ticket1.Id,
            SenderId = users[0].Id,
            Message = "المنتج كان به كسر خفيف في المقبض عند الاستلام، والمالك يطالب بخصم التأمين بالكامل.",
            CreatedAt = DateTime.UtcNow.AddDays(-2)
        });
        ticket1.Messages.Add(new SupportMessage
        {
            Id = Guid.NewGuid(),
            TicketId = ticket1.Id,
            SenderId = users[6].Id,
            Message = "المقبض كان سليم تماماً والكسر جديد نتيجة سوء الاستخدام.",
            CreatedAt = DateTime.UtcNow.AddDays(-1)
        });
        _context.SupportTickets.Add(ticket1);

        // Rental 7: Disputed (Resolved). user2 rents item owned by user8
        var r7 = new Rental
        {
            Id = Guid.NewGuid(),
            UserId = users[1].Id,
            ItemId = items.First(item => item.OwnerId == users[7].Id).Id,
            RentalPrice = 200,
            StartDate = DateTime.UtcNow.AddDays(-15),
            EndDate = DateTime.UtcNow.AddDays(-10),
            ActualReturnDate = DateTime.UtcNow.AddDays(-10),
            Status = RentalStatus.Completed,
            DepositAmount = 250,
            DepositStatus = DepositStatus.Returned,
            Notes = "تم حل النزاع ودياً وإرجاع مبلغ التأمين بالكامل.",
            CreatedAt = DateTime.UtcNow.AddDays(-16),
            UpdatedAt = DateTime.UtcNow.AddDays(-9)
        };
        _context.Rentals.Add(r7);

        // Resolved dispute support ticket
        var adminUserObj = await _userManager.FindByEmailAsync("admin1@renty.com");
        var ticket2 = new SupportTicket
        {
            Id = Guid.NewGuid(),
            UserId = users[1].Id,
            Type = SupportTicketType.Rental,
            Status = SupportTicketStatus.Resolved,
            RelatedRentalId = r7.Id,
            AssignedAgentId = supportAgent?.Id,
            FinancialResolutionById = adminUserObj?.Id,
            FinancialResolutionAt = DateTimeOffset.UtcNow.AddDays(-9),
            FinancialResolutionReason = "تم التراضي بين الطرفين بعد المعاينة وإثبات أن الخدوش بسيطة وناتجة عن الاستخدام الطبيعي.",
            CreatedAt = DateTime.UtcNow.AddDays(-10),
            UpdatedAt = DateTime.UtcNow.AddDays(-9)
        };
        ticket2.Messages.Add(new SupportMessage
        {
            Id = Guid.NewGuid(),
            TicketId = ticket2.Id,
            SenderId = users[1].Id,
            Message = "المنتج به خدوش سطحية والمالك يرفض تسليم التأمين.",
            CreatedAt = DateTime.UtcNow.AddDays(-10)
        });
        ticket2.Messages.Add(new SupportMessage
        {
            Id = Guid.NewGuid(),
            TicketId = ticket2.Id,
            SenderId = supportAgent?.Id ?? users[1].Id,
            Message = "تم التواصل مع الطرفين والتسوية على رد مبلغ التأمين كاملاً مع التعهد بعدم تكرار الخلاف.",
            CreatedAt = DateTime.UtcNow.AddDays(-9)
        });
        _context.SupportTickets.Add(ticket2);

        await _context.SaveChangesAsync();
    }

    private async Task SeedExpertVerificationsAsync()
    {
        if (await _context.ItemVerifications.AnyAsync())
            return;

        var items = await _context.Items.ToListAsync();
        if (!items.Any()) return;

        // Get experts
        var expertRole = await _roleManager.FindByNameAsync("Expert");
        if (expertRole == null) return;
        var expertIds = await _context.UserRoles
            .Where(ur => ur.RoleId == expertRole.Id)
            .Select(ur => ur.UserId)
            .ToListAsync();
        var experts = await _context.Users
            .Where(u => expertIds.Contains(u.Id))
            .OrderBy(u => u.Id)
            .ToListAsync();

        if (!experts.Any()) return;

        // Use safe indexing – only add a verification if the item exists
        void AddVerification(Item item, long? expertId, VerificationStatus status, string notes, string? code = null, int daysAgo = 0)
        {
            var iv = new ItemVerification
            {
                Id = Guid.NewGuid(),
                ItemId = item.Id,
                ExpertId = expertId,
                CheckType = VerificationCheck.BeforeRent,
                Status = status,
                Notes = notes,
                CreatedAt = DateTime.UtcNow.AddDays(-daysAgo),
                UpdatedAt = DateTime.UtcNow.AddDays(-Math.Max(0, daysAgo - 1))
            };
            if (code != null) iv.VerificationCode = code;
            _context.ItemVerifications.Add(iv);
        }

        // 1. Approved (assigned to expert1)
        if (items.Count > 0)
            AddVerification(items[0], experts.Count > 0 ? (long?)experts[0].Id : null, VerificationStatus.Approved,
                "تم فحص المنتج بالكامل وهو بحالة ممتازة ومطابق للوصف والصور تماماً.", "V-109283", 5);

        // 2. In-Progress (assigned to expert2, status Pending)
        if (items.Count > 1)
            AddVerification(items[1], experts.Count > 1 ? (long?)experts[1].Id : null, VerificationStatus.Pending,
                "تم استلام المنتج وجاري المعاينة والتأكد من السلامة الهيكلية.", null, 1);

        // 3-5. Pending (unassigned)
        if (items.Count > 2)
            AddVerification(items[2], null, VerificationStatus.Pending,
                "مطلوب معاينة خبير قبل تفعيل الإيجار.");

        if (items.Count > 3)
            AddVerification(items[3], null, VerificationStatus.Pending,
                "طلب تحقق من مالك المنتج لتوثيقه كحالة ممتازة.");

        if (items.Count > 4)
            AddVerification(items[4], null, VerificationStatus.Pending,
                "طلب معاينة بعد إرجاع المنتج للتأكد من سلامته.");

        await _context.SaveChangesAsync();
        _logger.LogInformation("Seeded {Count} item verifications.", Math.Min(items.Count, 5));
    }

    private async Task SeedIdVerificationsAsync()
    {
        if (await _context.IdVerifications.AnyAsync())
            return;

        // Fetch regular users user11 to user20 (index 10-19) – they uploaded ID but pending
        var userRole = await _roleManager.FindByNameAsync("User");
        if (userRole == null) return;
        var userIds = await _context.UserRoles
            .Where(ur => ur.RoleId == userRole.Id)
            .Select(ur => ur.UserId)
            .ToListAsync();
        var allUsers = await _context.Users
            .Where(u => userIds.Contains(u.Id))
            .OrderBy(u => u.Email)
            .ToListAsync();

        if (!allUsers.Any()) return;

        // users 11-20: uploaded ID, still pending (IdVerified=false, IdVerification record exists)
        var pendingUsers = allUsers.Skip(10).Take(10).ToList();
        foreach (var user in pendingUsers)
        {
            user.IdVerified = false;
            user.IsVerified = false;
            _context.Users.Update(user);

            var frontImage = new MediaFile
            {
                Id = Guid.NewGuid(),
                StoragePath = "https://images.unsplash.com/photo-1554774853-aae0a22c8aa4?w=800",
                FileType = FileType.Image,
                OriginalFileName = $"id_front_{user.Id}.jpg",
                FileExtension = ".jpg",
                ContentType = "image/jpeg",
                FileSize = 150000,
                CreatedAt = DateTime.UtcNow.AddDays(-3)
            };
            _context.MediaFiles.Add(frontImage);

            var backImage = new MediaFile
            {
                Id = Guid.NewGuid(),
                StoragePath = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800",
                FileType = FileType.Image,
                OriginalFileName = $"id_back_{user.Id}.jpg",
                FileExtension = ".jpg",
                ContentType = "image/jpeg",
                FileSize = 145000,
                CreatedAt = DateTime.UtcNow.AddDays(-3)
            };
            _context.MediaFiles.Add(backImage);

            var idVerification = new IdVerification
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                FrontImageUrl = frontImage.StoragePath,
                BackImageUrl = backImage.StoragePath,
                Status = VerificationStatus.Pending,
                CreatedAt = DateTimeOffset.UtcNow.AddDays(-3)
            };
            _context.IdVerifications.Add(idVerification);
        }

        // users 21-30: did NOT upload ID at all (IdVerified=false, no IdVerification record)
        var noIdUsers = allUsers.Skip(20).Take(10).ToList();
        foreach (var user in noIdUsers)
        {
            user.IdVerified = false;
            user.IsVerified = false;
            _context.Users.Update(user);
        }

        await _context.SaveChangesAsync();
        _logger.LogInformation("Seeded ID verifications: {Pending} pending, {NoId} with no ID uploaded.", pendingUsers.Count, noIdUsers.Count);
    }

    private async Task CleanSeedDataAsync()
    {
        _logger.LogInformation("Cleaning existing seed data before re-seeding...");

        try
        {
            // Remove rentals, verifications, disputes, items, etc.
            _context.Rentals.RemoveRange(await _context.Rentals.ToListAsync());
            _context.SupportTickets.RemoveRange(await _context.SupportTickets.ToListAsync());
            _context.SupportMessages.RemoveRange(await _context.SupportMessages.ToListAsync());
            _context.ItemVerifications.RemoveRange(await _context.ItemVerifications.ToListAsync());
            _context.IdVerifications.RemoveRange(await _context.IdVerifications.ToListAsync());
            _context.Items.RemoveRange(await _context.Items.ToListAsync());
            _context.ItemPricings.RemoveRange(await _context.ItemPricings.ToListAsync());
            _context.ItemImages.RemoveRange(await _context.ItemImages.ToListAsync());

            // Remove regular seeded users (both @renty.com and legacy @rently.com)
            var rentlyUsers = await _userManager.Users
                .Where(u => u.Email != null &&
                    (u.Email.EndsWith("@renty.com") || u.Email.EndsWith("@rently.com")) &&
                    u.Email != "admin@rently.com" && u.Email != "admin@renty.com")
                .ToListAsync();

            foreach (var user in rentlyUsers)
            {
                await _userManager.DeleteAsync(user);
            }

            await _context.SaveChangesAsync();
            _logger.LogInformation("Cleaned existing seed data.");
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error during seed data cleanup. Proceeding...");
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
