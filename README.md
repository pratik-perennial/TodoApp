# TodoApp

A clean and modern SwiftUI-based To-Do list application for iOS that helps you manage tasks efficiently. This app supports creating, updating, deleting, and filtering your to-dos, along with weather integration to enhance your productivity experience.

## Features

- Manage a list of to-dos with titles, notes, due dates, and completion status.
- Create different User profiles and add to-dos
- Filter tasks by Upcoming, Past, or Completed.
- Add, edit, and delete tasks with a sleek user interface.
- Integrated current weather and hourly temperature forecast display.
- Location-aware weather updates.
- Modern SwiftUI design with smooth animations and responsive layouts.
- Clean architecture using MVVM pattern with asynchronous API calls.

## Screenshots

<div style="display: flex; overflow-x: auto;">
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/user_selection.png" width="250" style="margin-right: 10px;" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/user_creation.png" width="250" style="margin-right: 10px;" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/user_login.png" width="250" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/location_permission.png" width="250" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/dashboard.png" width="250" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/create_todo.png" width="250" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/todo_filter.png" width="250" />
  <img src="https://github.com/pratik-perennial/TodoApp/blob/develop/raw/edit_todo.png" width="250" />
</div>


## Tech Stack

- Swift & SwiftUI for UI development.
- Combine framework for reactive data binding.
- Moya for network layer with async/await support.
- Open-Meteo API for weather data.
- Firebase integration.
- Unit testing with XCTest.

## Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 17 or later deployment target

### Installation

1. Clone this repository:
```
  git clone https://github.com/pratik-perennial/TodoApp.git
```
  
3. Open the project in Xcode:
```
  cd TodoApp
  open TodoApp.xcodeproj
```

4. Build and run on a simulator or real device.

## Project Structure

- **Models**: Data models for ToDoItem, Weather, User, etc.
- **ViewModels**: Business logic and data management for views.
- **Views**: SwiftUI views and UI components.
- **Services**: Networking, API service, permission service, and utilities.
- **Resources**: Assets, icons, and supporting files.
- **Tests**: Unit tests.

