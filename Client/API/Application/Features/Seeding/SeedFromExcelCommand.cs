using Application.Common.Interfaces;
using Domain.Entities;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using OfficeOpenXml;
using System.IO;
using LicenseContext = OfficeOpenXml.LicenseContext;

namespace Application.Features.Seeding;

public record SeedFromExcelCommand(string FilePath) : IRequest<SeedFromExcelResponse>;

public record SeedFromExcelResponse(
    bool Success,
    string Message,
    Dictionary<string, int> ImportedCounts
);

public class SeedFromExcelCommandValidator : AbstractValidator<SeedFromExcelCommand>
{
    public SeedFromExcelCommandValidator()
    {
        RuleFor(x => x.FilePath)
            .NotEmpty().WithMessage("File path is required.")
            .Must(System.IO.File.Exists).WithMessage("File does not exist.");
    }
}

public class SeedFromExcelCommandHandler : IRequestHandler<SeedFromExcelCommand, SeedFromExcelResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogger<SeedFromExcelCommandHandler> _logger;

    public SeedFromExcelCommandHandler(
        IApplicationDbContext context,
        ILogger<SeedFromExcelCommandHandler> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<SeedFromExcelResponse> Handle(SeedFromExcelCommand request, CancellationToken cancellationToken)
    {
        var importedCounts = new Dictionary<string, int>();

        try
        {
            _logger.LogInformation("Starting Excel data import from: {FilePath}", request.FilePath);

            // Set EPPlus license context
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            // Step 1: Clear existing data
            await ClearDatabaseAsync(cancellationToken);
            _logger.LogInformation("Database cleared successfully");

            // Step 2: Import data from Excel
            using var package = new ExcelPackage(new FileInfo(request.FilePath));

            // Import in order of dependencies
            importedCounts["ProductCategories"] = await ImportProductCategoriesAsync(package, cancellationToken);
            importedCounts["ProductSubcategories"] = await ImportProductSubcategoriesAsync(package, cancellationToken);
            importedCounts["Products"] = await ImportProductsAsync(package, cancellationToken);
            importedCounts["Territories"] = await ImportTerritoriesAsync(package, cancellationToken);
            importedCounts["Customers"] = await ImportCustomersAsync(package, cancellationToken);
            importedCounts["Calendars"] = await ImportCalendarsAsync(package, cancellationToken);
            importedCounts["Sales"] = await ImportSalesAsync(package, cancellationToken);
            importedCounts["Returns"] = await ImportReturnsAsync(package, cancellationToken);

            var totalImported = importedCounts.Values.Sum();
            var message = $"Successfully imported {totalImported} total records from Excel file.";
            
            _logger.LogInformation("Excel import completed: {Message}", message);
            
            return new SeedFromExcelResponse(true, message, importedCounts);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred during Excel import");
            return new SeedFromExcelResponse(false, $"Import failed: {ex.Message}", importedCounts);
        }
    }

    private async Task ClearDatabaseAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Clearing database...");

        // Delete in reverse order of dependencies
        var returns = await _context.Returns.ToListAsync(cancellationToken);
        _context.Returns.RemoveRange(returns);
        
        var sales = await _context.Sales.ToListAsync(cancellationToken);
        _context.Sales.RemoveRange(sales);
        
        var calendars = await _context.Calendars.ToListAsync(cancellationToken);
        _context.Calendars.RemoveRange(calendars);
        
        var customers = await _context.Customers.ToListAsync(cancellationToken);
        _context.Customers.RemoveRange(customers);
        
        var territories = await _context.Territories.ToListAsync(cancellationToken);
        _context.Territories.RemoveRange(territories);
        
        // Delete rental-related data
        var rentRequests = await _context.RentRequests.ToListAsync(cancellationToken);
        _context.RentRequests.RemoveRange(rentRequests);
        
        var rentableItemImages = await _context.RentableItemImages.ToListAsync(cancellationToken);
        _context.RentableItemImages.RemoveRange(rentableItemImages);
        
        var rentableItems = await _context.RentableItems.ToListAsync(cancellationToken);
        _context.RentableItems.RemoveRange(rentableItems);
        
        // Delete products
        var productImages = await _context.ProductImages.ToListAsync(cancellationToken);
        _context.ProductImages.RemoveRange(productImages);
        
        var products = await _context.Products.ToListAsync(cancellationToken);
        _context.Products.RemoveRange(products);
        
        var subcategories = await _context.ProductSubcategories.ToListAsync(cancellationToken);
        _context.ProductSubcategories.RemoveRange(subcategories);
        
        var categories = await _context.ProductCategories.ToListAsync(cancellationToken);
        _context.ProductCategories.RemoveRange(categories);

        await _context.SaveChangesAsync(cancellationToken);
        
        _logger.LogInformation("Database cleared successfully");
    }

    private async Task<int> ImportProductCategoriesAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Product Category"];
        if (worksheet == null)
        {
            _logger.LogWarning("Product Category sheet not found");
            return 0;
        }

        var categories = new List<ProductCategory>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        for (int row = 2; row <= rowCount; row++)
        {
            var categoryKey = worksheet.Cells[row, 1].GetValue<int?>();
            var categoryName = worksheet.Cells[row, 2].GetValue<string>();

            if (categoryKey.HasValue && !string.IsNullOrWhiteSpace(categoryName))
            {
                categories.Add(new ProductCategory
                {
                    Id = categoryKey.Value,
                    NameEn = categoryName,
                    NameAr = categoryName,
                    DescriptionEn = categoryName,
                    DescriptionAr = categoryName,
                    Created = DateTimeOffset.UtcNow,
                    LastModified = DateTimeOffset.UtcNow
                });
            }
        }

        await _context.ProductCategories.AddRangeAsync(categories);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Imported {Count} product categories", categories.Count);
        return categories.Count;
    }

    private async Task<int> ImportProductSubcategoriesAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Product Subcategory"];
        if (worksheet == null)
        {
            _logger.LogWarning("Product Subcategory sheet not found");
            return 0;
        }

        var subcategories = new List<ProductSubcategory>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        for (int row = 2; row <= rowCount; row++)
        {
            var subcategoryKey = worksheet.Cells[row, 1].GetValue<int?>();
            var subcategoryName = worksheet.Cells[row, 2].GetValue<string>();
            var categoryKey = worksheet.Cells[row, 3].GetValue<int?>();

            if (subcategoryKey.HasValue && !string.IsNullOrWhiteSpace(subcategoryName) && categoryKey.HasValue)
            {
                subcategories.Add(new ProductSubcategory
                {
                    Id = subcategoryKey.Value,
                    NameEn = subcategoryName,
                    NameAr = subcategoryName,
                    DescriptionEn = subcategoryName,
                    DescriptionAr = subcategoryName,
                    ProductCategoryId = categoryKey.Value,
                    Created = DateTimeOffset.UtcNow,
                    LastModified = DateTimeOffset.UtcNow
                });
            }
        }

        await _context.ProductSubcategories.AddRangeAsync(subcategories);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Imported {Count} product subcategories", subcategories.Count);
        return subcategories.Count;
    }

    private async Task<int> ImportProductsAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Product Lookup"];
        if (worksheet == null)
        {
            _logger.LogWarning("Product Lookup sheet not found");
            return 0;
        }

        var products = new List<Product>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        for (int row = 2; row <= rowCount; row++)
        {
            var productKey = worksheet.Cells[row, 1].GetValue<long?>();
            var productSku = worksheet.Cells[row, 2].GetValue<string>();
            var productName = worksheet.Cells[row, 3].GetValue<string>();
            var modelName = worksheet.Cells[row, 4].GetValue<string>();
            var description = worksheet.Cells[row, 5].GetValue<string>();
            var color = worksheet.Cells[row, 6].GetValue<string>();
            var subcategoryKey = worksheet.Cells[row, 7].GetValue<int?>();
            var productCost = worksheet.Cells[row, 8].GetValue<decimal?>();
            var productPrice = worksheet.Cells[row, 9].GetValue<decimal?>();
            var discountPrice = worksheet.Cells[row, 10].GetValue<decimal?>();

            if (productKey.HasValue && !string.IsNullOrWhiteSpace(productSku) && subcategoryKey.HasValue)
            {
                products.Add(new Product
                {
                    Id = productKey.Value,
                    ProductSku = productSku,
                    NameEn = productName ?? "Unknown",
                    NameAr = productName ?? "Unknown",
                    ModelName = modelName,
                    DescriptionEn = description,
                    DescriptionAr = description,
                    Color = color,
                    ProductSubcategoryId = subcategoryKey.Value,
                    ProductCost = productCost ?? 0,
                    RentPricePerDay = productPrice ?? 0,
                    RentDiscountPrice = discountPrice,
                    Created = DateTimeOffset.UtcNow,
                    LastModified = DateTimeOffset.UtcNow
                });
            }
        }

        await _context.Products.AddRangeAsync(products);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Imported {Count} products", products.Count);
        return products.Count;
    }

    private async Task<int> ImportTerritoriesAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Territory Lookup"];
        if (worksheet == null)
        {
            _logger.LogWarning("Territory Lookup sheet not found");
            return 0;
        }

        var territories = new List<Territory>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        for (int row = 2; row <= rowCount; row++)
        {
            var territoryKey = worksheet.Cells[row, 1].GetValue<int?>();
            var region = worksheet.Cells[row, 2].GetValue<string>();
            var country = worksheet.Cells[row, 3].GetValue<string>();
            var continent = worksheet.Cells[row, 4].GetValue<string>();

            if (territoryKey.HasValue)
            {
                territories.Add(new Territory
                {
                    Id = territoryKey.Value,
                    Region = region ?? "Unknown",
                    Country = country ?? "Unknown",
                    Continent = continent ?? "Unknown"
                });
            }
        }

        await _context.Territories.AddRangeAsync(territories);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Imported {Count} territories", territories.Count);
        return territories.Count;
    }

    private async Task<int> ImportCustomersAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets["Customer Lookup"];
        if (worksheet == null)
        {
            _logger.LogWarning("Customer Lookup sheet not found");
            return 0;
        }

        var customers = new List<Customer>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        _logger.LogInformation("Processing {RowCount} customer rows", rowCount - 1);

        for (int row = 2; row <= rowCount; row++)
        {
            var customerKey = worksheet.Cells[row, 1].GetValue<long?>();
            var prefix = worksheet.Cells[row, 2].GetValue<string>();
            var firstName = worksheet.Cells[row, 3].GetValue<string>();
            var lastName = worksheet.Cells[row, 4].GetValue<string>();
            var birthDate = worksheet.Cells[row, 5].GetValue<DateTime?>();
            var maritalStatus = worksheet.Cells[row, 6].GetValue<string>();
            var gender = worksheet.Cells[row, 7].GetValue<string>();
            var emailAddress = worksheet.Cells[row, 8].GetValue<string>();
            var annualIncome = worksheet.Cells[row, 9].GetValue<decimal?>();
            var totalChildren = worksheet.Cells[row, 10].GetValue<int?>();
            var educationLevel = worksheet.Cells[row, 11].GetValue<string>();
            var occupation = worksheet.Cells[row, 12].GetValue<string>();
            var homeOwner = worksheet.Cells[row, 13].GetValue<string>();

            if (customerKey.HasValue && !string.IsNullOrWhiteSpace(firstName))
            {
                customers.Add(new Customer
                {
                    Id = customerKey.Value,
                    Prefix = prefix,
                    FirstName = firstName,
                    LastName = lastName ?? "",
                    BirthDate = birthDate.HasValue ? DateOnly.FromDateTime(birthDate.Value) : null,
                    MaritalStatus = maritalStatus,
                    Gender = gender,
                    EmailAddress = emailAddress,
                    AnnualIncome = annualIncome,
                    TotalChildren = totalChildren,
                    EducationLevel = educationLevel,
                    Occupation = occupation,
                    HomeOwner = homeOwner?.Equals("Y", StringComparison.OrdinalIgnoreCase),
                    Created = DateTimeOffset.UtcNow,
                    LastModified = DateTimeOffset.UtcNow
                });
            }

            // Save in batches to avoid memory issues
            if (customers.Count >= 1000)
            {
                await _context.Customers.AddRangeAsync(customers);
                await _context.SaveChangesAsync(cancellationToken);
                _logger.LogInformation("Saved batch of {Count} customers", customers.Count);
                customers.Clear();
            }
        }

        // Save remaining customers
        if (customers.Count > 0)
        {
            await _context.Customers.AddRangeAsync(customers);
            await _context.SaveChangesAsync(cancellationToken);
        }

        var totalCount = await _context.Customers.CountAsync(cancellationToken);
        _logger.LogInformation("Imported {Count} customers", totalCount);
        return totalCount;
    }

    private async Task<int> ImportCalendarsAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Calendar Lookup"];
        if (worksheet == null)
        {
            _logger.LogWarning("Calendar Lookup sheet not found");
            return 0;
        }

        var calendars = new List<Domain.Entities.Calendar>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        for (int row = 2; row <= rowCount; row++)
        {
            var date = worksheet.Cells[row, 1].GetValue<DateTime?>();
            
            if (date.HasValue)
            {
                var dateOnly = DateOnly.FromDateTime(date.Value);
                
                calendars.Add(new Domain.Entities.Calendar
                {
                    Date = dateOnly,
                    DayName = date.Value.DayOfWeek.ToString(),
                    StartOfWeek = dateOnly.AddDays(-(int)date.Value.DayOfWeek),
                    StartOfMonth = new DateOnly(date.Value.Year, date.Value.Month, 1),
                    StartOfQuarter = new DateOnly(date.Value.Year, ((date.Value.Month - 1) / 3) * 3 + 1, 1),
                    MonthName = date.Value.ToString("MMMM"),
                    Month = date.Value.Month,
                    StartOfYear = new DateOnly(date.Value.Year, 1, 1),
                    Year = date.Value.Year,
                    Quarter = (date.Value.Month - 1) / 3 + 1,
                    DayOfWeek = (int)date.Value.DayOfWeek,
                    DayOfMonth = date.Value.Day,
                    DayOfYear = date.Value.DayOfYear,
                    WeekOfYear = System.Globalization.CultureInfo.CurrentCulture.Calendar.GetWeekOfYear(
                        date.Value, 
                        System.Globalization.CalendarWeekRule.FirstDay, 
                        DayOfWeek.Sunday),
                    IsWeekend = date.Value.DayOfWeek == DayOfWeek.Saturday || date.Value.DayOfWeek == DayOfWeek.Sunday
                });
            }
        }

        await _context.Calendars.AddRangeAsync(calendars);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Imported {Count} calendar entries", calendars.Count);
        return calendars.Count;
    }

    private async Task<int> ImportSalesAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Sales Data"];
        if (worksheet == null)
        {
            _logger.LogWarning("Sales Data sheet not found");
            return 0;
        }

        var sales = new List<Sale>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        _logger.LogInformation("Processing {RowCount} sales rows", rowCount - 1);

        for (int row = 2; row <= rowCount; row++)
        {
            var orderDate = worksheet.Cells[row, 1].GetValue<DateTime?>();
            var stockDate = worksheet.Cells[row, 2].GetValue<DateTime?>();
            var orderNumber = worksheet.Cells[row, 3].GetValue<string>();
            var productKey = worksheet.Cells[row, 4].GetValue<long?>();
            var customerKey = worksheet.Cells[row, 5].GetValue<long?>();
            var territoryKey = worksheet.Cells[row, 6].GetValue<int?>();
            var orderLineItem = worksheet.Cells[row, 7].GetValue<int?>();
            var orderQuantity = worksheet.Cells[row, 8].GetValue<int?>();

            if (orderDate.HasValue && productKey.HasValue && customerKey.HasValue && territoryKey.HasValue)
            {
                sales.Add(new Sale
                {
                    OrderDate = DateOnly.FromDateTime(orderDate.Value),
                    StockDate = stockDate.HasValue ? DateOnly.FromDateTime(stockDate.Value) : null,
                    OrderNumber = orderNumber ?? "",
                    ProductId = productKey.Value,
                    CustomerId = customerKey.Value,
                    TerritoryId = territoryKey.Value,
                    OrderLineItem = orderLineItem ?? 1,
                    OrderQuantity = orderQuantity ?? 1,
                    Created = DateTimeOffset.UtcNow,
                    LastModified = DateTimeOffset.UtcNow
                });
            }

            // Save in batches
            if (sales.Count >= 1000)
            {
                await _context.Sales.AddRangeAsync(sales);
                await _context.SaveChangesAsync(cancellationToken);
                _logger.LogInformation("Saved batch of {Count} sales", sales.Count);
                sales.Clear();
            }
        }

        // Save remaining sales
        if (sales.Count > 0)
        {
            await _context.Sales.AddRangeAsync(sales);
            await _context.SaveChangesAsync(cancellationToken);
        }

        var totalCount = await _context.Sales.CountAsync(cancellationToken);
        _logger.LogInformation("Imported {Count} sales", totalCount);
        return totalCount;
    }

    private async Task<int> ImportReturnsAsync(ExcelPackage package, CancellationToken cancellationToken)
    {
        var worksheet = package.Workbook.Worksheets[" Returns Data"];
        if (worksheet == null)
        {
            _logger.LogWarning("Returns Data sheet not found");
            return 0;
        }

        var returns = new List<Return>();
        var rowCount = worksheet.Dimension?.Rows ?? 0;

        for (int row = 2; row <= rowCount; row++)
        {
            var returnDate = worksheet.Cells[row, 1].GetValue<DateTime?>();
            var territoryKey = worksheet.Cells[row, 2].GetValue<int?>();
            var productKey = worksheet.Cells[row, 3].GetValue<long?>();
            var returnQuantity = worksheet.Cells[row, 4].GetValue<int?>();
            var returnReason = worksheet.Cells[row, 5].GetValue<string>();

            if (returnDate.HasValue && territoryKey.HasValue && productKey.HasValue)
            {
                returns.Add(new Return
                {
                    ReturnDate = DateOnly.FromDateTime(returnDate.Value),
                    TerritoryId = territoryKey.Value,
                    ProductId = productKey.Value,
                    ReturnQuantity = returnQuantity ?? 1,
                    ReturnReason = returnReason,
                    Created = DateTimeOffset.UtcNow,
                    LastModified = DateTimeOffset.UtcNow
                });
            }
        }

        await _context.Returns.AddRangeAsync(returns);
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Imported {Count} returns", returns.Count);
        return returns.Count;
    }
}
