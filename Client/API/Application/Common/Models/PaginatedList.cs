using Microsoft.EntityFrameworkCore;

namespace Application.Common.Models;

public class PaginatedList<T>
{
    public List<T> Items { get; set; } = new();
    public int PageNumber { get; set; }
    public int TotalPages { get; set; }
    public int TotalCount { get; set; }

    public PaginatedList() { }

    public PaginatedList(List<T> items, int count, int pageNumber, int pageSize)
    {
        var safePageSize = pageSize < 1 ? 1 : pageSize;
        PageNumber = pageNumber;
        TotalPages = count == 0 ? 0 : (int)Math.Ceiling(count / (double)safePageSize);
        TotalCount = count;
        Items = items;
    }

    public bool HasPreviousPage => PageNumber > 1;
    public bool HasNextPage => PageNumber < TotalPages;

    public static async Task<PaginatedList<T>> CreateAsync(
        IQueryable<T> source,
        int pageNumber,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        var safePageSize = pageSize < 1 ? 1 : pageSize;
        var safePageNumber = pageNumber < 1 ? 1 : pageNumber;
        var count = await source.CountAsync(cancellationToken);
        var items = await source
            .Skip((safePageNumber - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync(cancellationToken);

        return new PaginatedList<T>(items, count, safePageNumber, safePageSize);
    }
}
