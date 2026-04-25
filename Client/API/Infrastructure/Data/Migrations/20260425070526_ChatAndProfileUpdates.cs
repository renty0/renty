using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class ChatAndProfileUpdates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ApplicationUserId",
                table: "items",
                type: "bigint",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "message",
                table: "chat_messages",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<Guid>(
                name: "ContextItemId",
                table: "chat_messages",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MediaUrl",
                table: "chat_messages",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "MessageType",
                table: "chat_messages",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_items_ApplicationUserId",
                table: "items",
                column: "ApplicationUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_items_Users_ApplicationUserId",
                table: "items",
                column: "ApplicationUserId",
                principalTable: "Users",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_items_Users_ApplicationUserId",
                table: "items");

            migrationBuilder.DropIndex(
                name: "IX_items_ApplicationUserId",
                table: "items");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                table: "items");

            migrationBuilder.DropColumn(
                name: "ContextItemId",
                table: "chat_messages");

            migrationBuilder.DropColumn(
                name: "MediaUrl",
                table: "chat_messages");

            migrationBuilder.DropColumn(
                name: "MessageType",
                table: "chat_messages");

            migrationBuilder.AlterColumn<string>(
                name: "message",
                table: "chat_messages",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);
        }
    }
}
