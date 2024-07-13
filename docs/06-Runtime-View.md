## 6. Runtime View

![Runtime-View](./images/06-Runtime-View.png)

### 6.1 Runtime Scenarios
* **Password Storage**:
    1. User submits password.
    2. API Gateway forwards request to the application.
    3. Application encrypts password and stores it in Database.
* **Password Retrieval**:
    1. User requests a password.
    2. API Gateway forwards request to the application.
    3. Application fetches and decrypts the password from Database.
* **Password Delete**
    1. EventBridge publish a PasswordExpiredEvent.
    2. Application listen to PasswordExpiredEvent and delete the password from database.
* **Password Insert**
  1. Database fire Insert event
  2. Application listen to InsertEvent and check the storage event.
  3. If storage event is **Time based** then schedule a PasswordExpiredJob via EventBridge
* **Password Read**
  1. Database fire Read event
  2. Application listen to ReadEvent and check the storage event.
  3. If storage event is **Once** then fire a PasswordExpiredEvent via EventBridge