## 6. Runtime View

![Runtime-View](./images/06-Runtime-View.png)

### 6.1 Runtime Scenarios

**Password Storage Process:**

1. **HTTP Message Received**:
  - **Trigger**: User sends a request to store a password.
  - **Action**: The system receives the HTTP message containing the password data.

2. **Encrypt Password**:
  - **Trigger**: Receipt of the HTTP message.
  - **Action**: The system encrypts the password using a secure encryption algorithm.

3. **Store Password**:
  - **Trigger**: Completion of password encryption.
  - **Action**: The encrypted password is stored in the NoSQL database.

4. **Generate Response**:
  - **Trigger**: Successful storage of the encrypted password.
  - **Action**: The system generates a response to the user indicating successful storage.

5. **Process Completed**:
  - **Outcome**: The password storage process is completed.

**Password Retrieval Process:**

1. **HTTP Message Received**:
  - **Trigger**: User sends a request to retrieve a password.
  - **Action**: The system receives the HTTP message requesting password retrieval.

2. **Read Password**:
  - **Trigger**: Receipt of the HTTP message.
  - **Action**: The system reads the encrypted password from the NoSQL database.

3. **Decrypt Password**:
  - **Trigger**: Successful retrieval of the encrypted password.
  - **Action**: The system decrypts the password.

4. **Decision Point (Storage Expired Type?)**:
  - **Trigger**: After decrypting the password.
  - **Action**: The system checks if the password storage is of type "Once" or "Other".

5. **Throw PasswordExpired Event**:
  - **Trigger**: If the password storage type is "Once".
  - **Action**: The system triggers a PasswordExpired event.

6. **Process Completed**:
  - **Outcome**: The password retrieval process is completed.

**Password Expired Scheduler Process:**

1. **On Message Stored Event**:
  - **Trigger**: A password is stored in the system.
  - **Action**: The system receives a message indicating a stored password event.

2. **Decision Point (Storage Type?)**:
  - **Trigger**: Upon receiving the stored event message.
  - **Action**: The system determines if the storage type is "Once" or "Time Based".

3. **Schedule PasswordExpiredEvent**:
  - **Trigger**: If the storage type is "Time Based".
  - **Action**: The system schedules a PasswordExpired event based on the specified expiration time.

4. **Wait for expired time**:
  - **Trigger**: After scheduling the PasswordExpired event.
  - **Action**: The system waits until the expiration time is reached.

5. **Throw PasswordExpired Event**:
  - **Trigger**: When the expiration time is reached.
  - **Action**: The system triggers a PasswordExpired event.

6. **Process Completed**:
  - **Outcome**: The password expired scheduler process is completed.

**Password Delete Process:**

1. **On PasswordExpired Event**:
  - **Trigger**: A PasswordExpired event is triggered.
  - **Action**: The system receives a message indicating a PasswordExpired event.

2. **Delete Password**:
  - **Trigger**: Receipt of the PasswordExpired event.
  - **Action**: The system deletes the expired password from the NoSQL database.

3. **Process Completed**:
  - **Outcome**: The password delete process is completed.