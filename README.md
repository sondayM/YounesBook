# Book Tracker

A modern Flutter mobile app to track books you read, manage reading lists, and monitor reading progress.

## Features

- **Authentication** – Email/password sign up, login, forgot password, persistent session (local storage)
- **Home Dashboard** – Greeting, stats (books read, reading, to read, pages this month), currently reading, favorites, recently added
- **Add Book** – Title, author, genre, description, total pages, cover image (saved locally), reading status, dates, rating, notes
- **Library** – Grid of books with filters (Want to Read / Currently Reading / Finished) and search
- **Book Details** – View/edit/delete, update progress (current page & %), favorites, notes
- **Statistics** – Total books/pages, average rating, books this year/month, pages per month chart, books by genre chart
- **Favorites** – Mark books as favorite; Favorites section on Home
- **Notes** – Add, edit, delete notes per book (quotes, thoughts, summary)
- **Rating** – 1–5 stars on books

## Tech Stack

- **Flutter** with **Clean Architecture** (domain, data, presentation)
- **Local storage**: SharedPreferences (users, books, session), path_provider (cover images)
- **Material Design 3**, light/dark theme, primary color #3E7CB1
- **State management**: flutter_bloc
- **Navigation**: go_router
- **Charts**: fl_chart

## Setup

```bash
flutter pub get
flutter run
```

No backend or API keys required; all data is stored on device.

## Structure

- `lib/core/` – theme, router, errors, utils, widgets (e.g. BookCoverImage)
- `lib/features/auth/` – auth (domain, data with local data source, presentation)
- `lib/features/books/` – books (domain, data with local data source, presentation)
- `lib/features/home/` – home dashboard
- `lib/features/statistics/` – statistics and charts
- `lib/features/profile/` – profile and logout

Bottom nav: Home, Library, Statistics, Profile. FAB: Add Book.
# YounesBook
