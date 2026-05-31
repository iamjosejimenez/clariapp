# Clariapp

Clariapp is a Ruby on Rails personal finance app focused on:

- Managing budgets and budget periods (`mensual`, `quincenal`, `semanal`).
- Tracking expenses per budget period.
- Syncing investment goals from external accounts (Fintual integration).
- Parsing invoice line items from uploaded images using OpenAI.

## Tech stack

- **Ruby on Rails** 8.1
- **SQLite** (default in development/test/production configs in this repo)
- **Solid Queue / Solid Cache / Solid Cable**
- **Stimulus + Turbo + Shakapacker + TailwindCSS**
- **Minitest + FactoryBot**

## Prerequisites

- Ruby (version compatible with Rails `~> 8.1.2`)
- Bundler
- Node.js + Yarn (for frontend assets)
- SQLite3

## Setup

1. Install dependencies:

   ```bash
   bundle install
   yarn install
   ```

2. Configure environment variables:

   ```bash
   cp .env.example .env
   ```

   If you do not have `.env.example`, create `.env` manually and include at least:

   ```bash
   OPENAI_API_KEY=your_openai_api_key
   ```

3. Prepare the database:

   ```bash
   bin/rails db:prepare
   ```

## Running the app

Start everything in development:

```bash
bin/dev
```

Useful alternatives:

```bash
bin/rails server
bin/jobs
bin/shakapacker-dev-server
```

Health check endpoint:

- `GET /up`

## Main features and routes

- Budgets: `GET /budgets`
- Budget periods: `GET /budgets/:budget_id/budget_periods`
- Expenses by period: `GET /budgets/:budget_id/budget_periods/:budget_period_id/expenses`
- Goals dashboard: `GET /dashboard`
- Goals detail: `GET /goals/:id`
- Invoice item extraction UI: `GET /invoices/new`

## Scheduled jobs

A recurring production job is configured in `config/recurring.yml`:

- `FetchGoalSnapshotsJob` runs **every hour**.

## Testing

Run the full test suite:

```bash
bin/rails test
```

Run a specific file:

```bash
bin/rails test test/services/invoice_item_extraction_service_test.rb
```

## Linting and security checks

```bash
bin/rubocop
bin/brakeman
bin/erb_lint app/views
```

## Data migration helpers

The project includes rake tasks under `lib/tasks/` for export/import and specific migrations. Example:

```bash
bin/rake data_migrate:export
bin/rake data_migrate:import
```

## Notes

- App strings and domain language are mostly in Spanish (e.g., categories and flash messages).
- External service usage (OpenAI and external accounts) depends on valid credentials.
