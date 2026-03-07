using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class FixProductCategoryColumnNames : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Idempotent: rename PascalCase columns to lowercase. If columns are already lowercase, renames are no-ops (exception caught).
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""CategoryName"" TO categoryname;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""Description"" TO description;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" DROP CONSTRAINT IF EXISTS ""FK_ProductCategories_MediaFiles_LogoId"";
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""LogoId"" TO logoid;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""Created"" TO created;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""CreatedBy"" TO createdby;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""LastModified"" TO lastmodified;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    ALTER TABLE ""ProductCategories"" RENAME COLUMN ""LastModifiedBy"" TO lastmodifiedby;
EXCEPTION WHEN undefined_column THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    DROP INDEX IF EXISTS ""IX_ProductCategories_LogoId"";
    CREATE INDEX IF NOT EXISTS ""IX_ProductCategories_logoid"" ON ""ProductCategories"" (logoid);
EXCEPTION WHEN others THEN NULL;
END $$;
");
            migrationBuilder.Sql(@"
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'FK_ProductCategories_MediaFiles_logoid') THEN
        ALTER TABLE ""ProductCategories"" ADD CONSTRAINT ""FK_ProductCategories_MediaFiles_logoid""
        FOREIGN KEY (logoid) REFERENCES ""MediaFiles"" (""Id"");
    END IF;
EXCEPTION WHEN others THEN NULL;
END $$;
");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ProductCategories_MediaFiles_logoid",
                table: "ProductCategories");

            migrationBuilder.RenameColumn(
                name: "logoid",
                table: "ProductCategories",
                newName: "LogoId");

            migrationBuilder.RenameColumn(
                name: "lastmodifiedby",
                table: "ProductCategories",
                newName: "LastModifiedBy");

            migrationBuilder.RenameColumn(
                name: "lastmodified",
                table: "ProductCategories",
                newName: "LastModified");

            migrationBuilder.RenameColumn(
                name: "description",
                table: "ProductCategories",
                newName: "Description");

            migrationBuilder.RenameColumn(
                name: "createdby",
                table: "ProductCategories",
                newName: "CreatedBy");

            migrationBuilder.RenameColumn(
                name: "created",
                table: "ProductCategories",
                newName: "Created");

            migrationBuilder.RenameColumn(
                name: "categoryname",
                table: "ProductCategories",
                newName: "CategoryName");

            migrationBuilder.RenameIndex(
                name: "IX_ProductCategories_logoid",
                table: "ProductCategories",
                newName: "IX_ProductCategories_LogoId");

            migrationBuilder.AddForeignKey(
                name: "FK_ProductCategories_MediaFiles_LogoId",
                table: "ProductCategories",
                column: "LogoId",
                principalTable: "MediaFiles",
                principalColumn: "Id");
        }
    }
}
