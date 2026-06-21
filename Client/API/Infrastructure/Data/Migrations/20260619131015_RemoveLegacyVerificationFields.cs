using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class RemoveLegacyVerificationFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "HandoffCode",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "IsHandoffVerified",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "IsReturnVerified",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "ReturnCode",
                table: "rentals");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "HandoffCode",
                table: "rentals",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsHandoffVerified",
                table: "rentals",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsReturnVerified",
                table: "rentals",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "ReturnCode",
                table: "rentals",
                type: "text",
                nullable: true);
        }
    }
}
