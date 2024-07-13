### Database Choice

**Date:** 2024-07-11

#### Status

Accepted

#### Context

The application needs a highly available, scalable, and low latency database to store encrypted passwords.

#### Decision

Use Amazon DynamoDB as the NoSQL database for storing encrypted passwords.

#### Consequences

- **Positive:** High availability, scalability, low latency.
- **Negative:** NoSQL data model and query limitations, cost considerations based on usage.
