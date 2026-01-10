# Rently Project - Developer Onboarding Guide

Welcome to the Rently project! This guide will help you set up your development environment and understand the project structure.

## 📋 Prerequisites

Ensure you have the following installed on your machine:
*   **Node.js** (LTS version recommended, e.g., v18 or v20) - [Download](https://nodejs.org/)
*   **.NET 8 SDK** - [Download](https://dotnet.microsoft.com/download/dotnet/8.0)
*   **SQL Server** (LocalDB or Developer Edition)
*   **Visual Studio Code** or **Visual Studio 2022**

---

## 🚀 Getting Started

The project is divided into two main parts:
1.  **Backend (API)**: .NET 8 Web API
2.  **Frontend (Web)**: Angular 18+ Application

### 1. Setting up the Backend

The backend follows **Clean Architecture** principles and uses **CQRS** with MediatR.

1.  **Navigate to the API folder:**
    ```bash
    cd Client/API/Web
    ```

2.  **Restore Dependencies:**
    ```bash
    dotnet restore
    ```

3.  **Database Configuration:**
    *   Check `appsettings.json` (or `appsettings.Development.json`) in `Client/API/Web` to ensure the Connection String points to your local SQL Server instance.
    *   Apply migrations to create the database:
        ```bash
        dotnet ef database update
        ```
    *   *(Optional)* The application may seed initial data automatically on startup.

4.  **Run the API:**
    ```bash
    dotnet run
    # OR for hot reloading
    dotnet watch
    ```
    *   The API will usually start at `https://localhost:5001` (check the console output).
    *   Swagger UI is available at `https://localhost:5001/swagger/index.html`.

### 2. Setting up the Frontend

The frontend is a modern Angular application using **Signals**, **PrimeNG**, and **Angular Material**.

1.  **Navigate to the Web folder:**
    ```bash
    cd Client/Web
    ```

2.  **Install Dependencies:**
    ```bash
    npm install
    ```

3.  **Run the Development Server:**
    ```bash
    ng serve
    # OR
    npm start
    ```

4.  **Open the App:**
    *   Navigate to `http://localhost:4200` in your browser.

---

## 🏗️ Project Structure & Architecture

### Backend (`Client/API`)
The solution is organized into layers:
*   **Domain**: Entities and business logic (No dependencies).
*   **Application**: Business use cases (CQRS Commands/Queries), Interfaces, DTOs.
*   **Infrastructure**: Database context (EF Core), external services, repositories.
*   **Web**: The API entry point, Controllers (endpoints), and Dependencies Injection setup.

### Frontend (`Client/Web`)
*   **`src/app/core`**: Singleton services, API clients (generated), Interceptors, Guards.
*   **`src/app/features`**: Feature modules (e.g., `products`, `categories`, `auth`). Each feature has its own routes and components.
*   **`src/app/shared`**: Reusable components (`app-input`, `app-loading-button`), pipes, directives, and UI models.
*   **`assets/i18n`**: Translation files (`en.json`, `ar.json`).

### 🔄 Key Workflows

*   **API Client Generation**:
    If you modify the Backend DTOs or Controllers, you must regenerate the frontend API client.
    1.  Ensure the Backend is running.
    2.  Run the generation script in `Client/Web`:
        ```bash
        npm run generate-client
        ```
