# Billetto Rails Test Assignment

## Setup Instructions

### 1. Install dependencies

```bash
bundle install
```

### 2. Configure environment variables

Create a `.env` file or export these before starting the server:

```bash
# Billetto API (https://api.billetto.com)
export BILLETTO_API_KEY=your_billetto_api_key

# Clerk.com (https://clerk.com → Dashboard → API Keys)
export CLERK_SECRET_KEY=sk_test_...
export CLERK_PUBLISHABLE_KEY=pk_test_...
```

### 3. Set up the database

```bash
rails db:create db:migrate
```

### 4. Fetch events from Billetto API

```bash
rails billetto:fetch_events
```

### 5. Start the server

```bash
rails s
```

### 6. Run the test suite

```bash
bundle exec rspec
```

---

## Features Implemented

- Fetch and ingest events from Billetto API (upserts by `external_id`)
- Display events with title, date, image, and description
- Voting system (upvote / downvote) restricted to authenticated users
- Event-driven architecture using Rails Event Store
- Clerk.com authentication (sign-in, sign-out, user button in header)
- RSpec tests: model, request, event store command, and Capybara system specs

---

## Architecture Overview

This application follows an event-driven architecture using Rails Event Store.

### Voting Flow

```
User → EventsController → VoteOnEvent command → Event Store → UpdateVoteCount handler → EventVoteCount (read model)
```

- Votes are recorded as domain events (`EventUpvoted`, `EventDownvoted`) with `user_id` and `event_id` in the payload
- A read model (`EventVoteCount`) materialises the vote totals for efficient display
- This avoids re-scanning events on every page load

### Authentication Flow

```
Browser → ClerkJS (sets __session cookie) → ApplicationController#current_user → Clerk::SDK#verify_token → ClerkUser
```

- `authenticate_user!` is called before the `vote` action
- The Clerk session JWT is read from the `__session` cookie (set automatically by ClerkJS on the frontend)
- Unauthenticated requests to protected actions are redirected to Clerk's hosted sign-in page

---

## Key Design Decisions

- **Event Sourcing for votes**: provides a full audit trail — every vote is a first-class event with `user_id`, making it traceable per requirement
- **Read model (`EventVoteCount`)**: avoids replaying events on every request; the handler updates counts synchronously on publish
- **Clerk for auth**: offloads session management, OAuth, MFA, and user storage to Clerk — no `users` table needed in this app
- **Thin controllers**: controllers only validate the session and dispatch commands; all domain logic lives in `app/domain/`

---

## Tradeoffs

- Event-driven architecture adds indirection compared to plain CRUD, but enables auditability and scalability
- Synchronous handler (`UpdateVoteCount`) keeps the implementation simple; in production this would move to an async subscriber to avoid blocking the request

---
