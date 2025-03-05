# Dift Donations API 💸

A fun (and functional!) REST API that allows users to record donations in various currencies and retrieve their total donated amount in any supported currency.

## Table of Contents
- [Overview](#overview)
- [Requirements](#requirements)
- [Tech Stack](#tech-stack)
- [Setup](#setup)
- [Usage](#usage)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Approach](#approach)
- [Testing](#testing)
- [License](#license)

## Overview
This project was built as a homework assignment for Dift, focusing on clean and tested code. It provides:

### **POST** `/api/donations`
Record a user’s donation, specifying:
- `amount` (in cents)
- `currency` (e.g., USD, EUR, etc.)
- `project` (a reference to a Project record)

### **GET** `/api/donations/total?currency=XYZ`
Retrieve the user’s total donation amount in the specified currency (converted via an external currency exchange API).

Authentication is handled by a simple token-based mechanism. Each user has an `api_token` which must be passed in the `Authorization` header for every request.

## Requirements
- Ruby 3.2+
- Rails 8
- PostgreSQL (for primary data storage)
- SQLite (for Rails cache, if using the Solid Cache feature)
- An external API key for currency conversion (e.g., Exchangerate-API)

## Tech Stack
- **Ruby on Rails** – Main framework for the API.
- **PostgreSQL** – Primary database.
- **Rspec** – Testing framework.
- **FactoryBot** – Factories for test data.
- **Faraday** – (Optional) For HTTP requests to the external currency API.
- **Solid Cache** – (Rails 8) Using a separate SQLite DB for caching exchange rates.

## Setup
### Clone the Repository
```bash
git clone https://github.com/Mesnet/dift.git
cd dift
```

### Install Dependencies
```bash
bundle install
```

### Set Up Databases
Create & Migrate the main database:
```bash
rails db:create
rails db:migrate
```

### Seed the Database (Optional)
```bash
rails db:seed
```
This will create some sample users, projects, and donations.

### Configure External API Key
Add your Exchangerate-API (or other service) key to your environment:
```bash
export EXCHANGE_RATE_API_KEY="d543c39ef04a2460e35ab0c0"
```
Or use Rails credentials, `.env` files, etc.

### Start the Server
```bash
rails server
```
The API will be available at [http://localhost:3000](http://localhost:3000).

## Usage

### Authentication
All requests must include an `Authorization` header containing the user’s API token. For example:
```makefile
Authorization: abc123
```
You can find or generate a user’s API token by checking the database (`users.api_token`) or creating a new user.

## Endpoints

### **Record a Donation**
#### **POST** `/api/donations`
##### Request Body (JSON):
```json
{
  "donation": {
    "amount": 5000,
    "currency": "USD",
    "project_id": 1
  }
}
```
##### Response (JSON, 201 Created):
```json
{
  "id": 10,
  "amount": 5000,
  "currency": "USD",
  "project_id": 1,
  "user_id": 2,
  "created_at": "2025-03-05T12:00:00.000Z",
  "updated_at": "2025-03-05T12:00:00.000Z"
}
```

### **Get Total Donations**
#### **GET** `/api/donations/total?currency=EUR`
##### Response (JSON, 200 OK):
```json
{
  "total": 2700,
  "currency": "EUR"
}
```
Here, `total` is the sum of donations for the current user, converted to EUR (in cents).

## Approach
### Token-Based Authentication:
- Each `User` has an `api_token`. All endpoints require an `Authorization` header with this token.

### Currency Conversion:
- Donations are stored in their original currency and cents.
- When retrieving totals, we convert each donation to the requested currency using a cached exchange rate.
- If the rate is unavailable, we gracefully handle the error (e.g., treat as zero or skip).

### Clean, Tested Code:
- Services (e.g., `ExchangeRateService`, `DonationTotalService`) handle domain logic.
- Controllers remain lean, focusing on input/output.
- RSpec ensures reliability with request specs, model specs, and service specs.

## Testing
Run all tests:
```bash
bundle exec rspec
```
- **Factories**: We use `FactoryBot` for generating test data.
- **Stubbing External Calls**: We stub the external currency API calls (e.g., using `WebMock`) to ensure consistent, offline-friendly tests.

## License
This project is provided as an educational example. Feel free to adapt and reuse the code. If you do, a shout-out to the original authors is always appreciated! ✨

Happy coding and donating! 🎉
