# Billetto Rails Test Assignment

## Setup Instructions

```bash
bundle install
rails db:create db:migrate
rails billetto:fetch_events
rails s
```

---

## Features Implemented

* Fetch and ingest events from Billetto API
* Display events with title, date, and image
* Voting system (upvote/downvote)
* Event-driven architecture using Rails Event Store
* Basic authentication (stubbed)
* RSpec tests

---

## Architecture Overview

This application follows an event-driven architecture using Rails Event Store.

### Voting Flow

User → Controller → Command → Event Store → Handler → Read Model

* Votes are stored as events (`EventUpvoted`, `EventDownvoted`)
* A read model (`EventVoteCount`) is used to efficiently calculate vote counts
* This avoids recalculating votes on every request

---

## Key Design Decisions

* **Event Sourcing**: Used to ensure auditability and scalability
* **Read Model**: Improves performance by avoiding repeated event queries
* **Service Layer (API Fetching)**: Keeps external API logic separate from controllers
* **Thin Controllers**: Controllers only dispatch commands

---

## Tradeoffs

* Event-driven architecture introduces additional complexity compared to traditional CRUD systems
* However, it provides better flexibility for scaling, analytics, and debugging

---

## Future Improvements

* Prevent duplicate voting per user
* Replace stubbed authentication with Clerk
* Add background jobs for API ingestion
* Add pagination for events

---
