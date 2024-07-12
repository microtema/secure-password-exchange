## 6. Runtime View

### 6.1 Runtime Scenarios
- **Password Storage**:
    1. User submits password.
    2. API Gateway forwards request to the application.
    3. Application encrypts password and stores it in S3.
    4. Encryption keys are fetched from Secrets Manager.
- **Password Retrieval**:
    1. User requests a password.
    2. API Gateway forwards request to the application.
    3. Application fetches and decrypts the password from S3.
    4. Decryption keys are fetched from Secrets Manager.