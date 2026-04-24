using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddRBACAndRationalRentals : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_fraud_logs_Users_user_id",
                table: "fraud_logs");

            migrationBuilder.DropPrimaryKey(
                name: "PK_fraud_logs",
                table: "fraud_logs");

            migrationBuilder.RenameTable(
                name: "fraud_logs",
                newName: "FraudLogs");

            migrationBuilder.RenameColumn(
                name: "reason",
                table: "FraudLogs",
                newName: "Reason");

            migrationBuilder.RenameColumn(
                name: "decision",
                table: "FraudLogs",
                newName: "Decision");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "FraudLogs",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "user_id",
                table: "FraudLogs",
                newName: "UserId");

            migrationBuilder.RenameColumn(
                name: "risk_score",
                table: "FraudLogs",
                newName: "RiskScore");

            migrationBuilder.RenameColumn(
                name: "fraud_indicators",
                table: "FraudLogs",
                newName: "FraudIndicators");

            migrationBuilder.RenameColumn(
                name: "created_at",
                table: "FraudLogs",
                newName: "CreatedAt");

            migrationBuilder.RenameIndex(
                name: "IX_fraud_logs_user_id",
                table: "FraudLogs",
                newName: "IX_FraudLogs_UserId");

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

            migrationBuilder.AlterColumn<string>(
                name: "Decision",
                table: "FraudLogs",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(20)",
                oldMaxLength: 20);

            migrationBuilder.AlterColumn<Guid>(
                name: "Id",
                table: "FraudLogs",
                type: "uuid",
                nullable: false,
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldDefaultValueSql: "gen_random_uuid()");

            migrationBuilder.AddPrimaryKey(
                name: "PK_FraudLogs",
                table: "FraudLogs",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "permissions",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    Name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "text", nullable: true),
                    Module = table.Column<string>(type: "text", nullable: false),
                    Action = table.Column<string>(type: "text", nullable: false),
                    Value = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    Created = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<string>(type: "text", nullable: true),
                    LastModified = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LastModifiedBy = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_permissions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "rental_images",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    RentalId = table.Column<Guid>(type: "uuid", nullable: false),
                    ImageId = table.Column<Guid>(type: "uuid", nullable: false),
                    Type = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_rental_images", x => x.id);
                    table.ForeignKey(
                        name: "FK_rental_images_MediaFiles_ImageId",
                        column: x => x.ImageId,
                        principalTable: "MediaFiles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_rental_images_rentals_RentalId",
                        column: x => x.RentalId,
                        principalTable: "rentals",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "role_permissions",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    RoleId = table.Column<long>(type: "bigint", nullable: false),
                    RoleName = table.Column<string>(type: "text", nullable: false),
                    PermissionValue = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    Created = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<string>(type: "text", nullable: true),
                    LastModified = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    LastModifiedBy = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_role_permissions", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_permissions_Value",
                table: "permissions",
                column: "Value",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_rental_images_ImageId",
                table: "rental_images",
                column: "ImageId");

            migrationBuilder.CreateIndex(
                name: "IX_rental_images_RentalId",
                table: "rental_images",
                column: "RentalId");

            migrationBuilder.CreateIndex(
                name: "IX_role_permissions_RoleId_PermissionValue",
                table: "role_permissions",
                columns: new[] { "RoleId", "PermissionValue" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_FraudLogs_Users_UserId",
                table: "FraudLogs",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FraudLogs_Users_UserId",
                table: "FraudLogs");

            migrationBuilder.DropTable(
                name: "permissions");

            migrationBuilder.DropTable(
                name: "rental_images");

            migrationBuilder.DropTable(
                name: "role_permissions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_FraudLogs",
                table: "FraudLogs");

            migrationBuilder.DropColumn(
                name: "HandoffCode",
                table: "rentals");

            migrationBuilder.DropColumn(
                name: "IsHandoffVerified",
                table: "rentals");

            migrationBuilder.RenameTable(
                name: "FraudLogs",
                newName: "fraud_logs");

            migrationBuilder.RenameColumn(
                name: "Reason",
                table: "fraud_logs",
                newName: "reason");

            migrationBuilder.RenameColumn(
                name: "Decision",
                table: "fraud_logs",
                newName: "decision");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "fraud_logs",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "fraud_logs",
                newName: "user_id");

            migrationBuilder.RenameColumn(
                name: "RiskScore",
                table: "fraud_logs",
                newName: "risk_score");

            migrationBuilder.RenameColumn(
                name: "FraudIndicators",
                table: "fraud_logs",
                newName: "fraud_indicators");

            migrationBuilder.RenameColumn(
                name: "CreatedAt",
                table: "fraud_logs",
                newName: "created_at");

            migrationBuilder.RenameIndex(
                name: "IX_FraudLogs_UserId",
                table: "fraud_logs",
                newName: "IX_fraud_logs_user_id");

            migrationBuilder.AlterColumn<string>(
                name: "decision",
                table: "fraud_logs",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AlterColumn<Guid>(
                name: "id",
                table: "fraud_logs",
                type: "uuid",
                nullable: false,
                defaultValueSql: "gen_random_uuid()",
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddPrimaryKey(
                name: "PK_fraud_logs",
                table: "fraud_logs",
                column: "id");

            migrationBuilder.AddForeignKey(
                name: "FK_fraud_logs_Users_user_id",
                table: "fraud_logs",
                column: "user_id",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
