using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddItemIdToChat : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_chats_user1_id_user2_id",
                table: "chats");

            migrationBuilder.AddColumn<Guid>(
                name: "item_id",
                table: "chats",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_chats_item_id",
                table: "chats",
                column: "item_id");

            migrationBuilder.CreateIndex(
                name: "IX_chats_user1_id_user2_id_item_id",
                table: "chats",
                columns: new[] { "user1_id", "user2_id", "item_id" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_chats_items_item_id",
                table: "chats",
                column: "item_id",
                principalTable: "items",
                principalColumn: "id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_chats_items_item_id",
                table: "chats");

            migrationBuilder.DropIndex(
                name: "IX_chats_item_id",
                table: "chats");

            migrationBuilder.DropIndex(
                name: "IX_chats_user1_id_user2_id_item_id",
                table: "chats");

            migrationBuilder.DropColumn(
                name: "item_id",
                table: "chats");

            migrationBuilder.CreateIndex(
                name: "IX_chats_user1_id_user2_id",
                table: "chats",
                columns: new[] { "user1_id", "user2_id" },
                unique: true);
        }
    }
}
