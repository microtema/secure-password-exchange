## 5. Building Block View

### 5.1 Whitebox Overall System

**System Context:**
The system is designed to provide a secure method for exchanging passwords among employees, leveraging AWS serverless architecture. The application is accessible only within the customer's private network.

**Key Components:**
1. **User**: The end-user accessing the application.
2. **Route S3**: Manages routing for static content.
3. **Amazon S3**: Stores static web content.
4. **Hosted Zone**: Manages DNS settings for the application.
5. **API Gateway**: Exposes RESTful API endpoints for interacting with the application.
6. **Cognito Identity**: Manages authentication and authorization for users.
7. **Lambda Functions**:
  - **Store Password**: Handles storing of passwords.
  - **Read Password**: Handles retrieval of passwords.
  - **Delete Password**: Handles deletion of passwords.
8. **NoSQL DB**: Stores password data securely.
9. **EventBridge**: Manages event-driven processing for password expiration and deletion.
10. **CloudWatch Logs**: Monitors and logs application activity.

### 5.2 Level 2: Container Diagram

**Containers:**
1. **User Interface**:
  - **User**: Interacts with the application via web interface hosted on Amazon S3.
  - **HTML/HTTP**: Protocols used to access the web content.

2. **Routing and API Management**:
  - **Route S3**: Directs users to the correct web resources.
  - **API Gateway**: Manages API calls from the user, providing endpoints for storing, reading, and deleting passwords.
  - **API Key**: Secures API access.
  - **IAM Policy**: Defines permissions for API access.

3. **Authentication**:
  - **Cognito Identity**: Authenticates users and grants access tokens for API usage.

4. **Password Management**:
  - **Store Password (Lambda)**: A function that processes POST requests to store encrypted passwords in NoSQL DB.
  - **Read Password (Lambda)**: A function that processes GET requests to retrieve encrypted passwords from NoSQL DB.
  - **Delete Password (Lambda)**: A function that processes DELETE requests to remove passwords from NoSQL DB.

5. **Database**:
  - **NoSQL DB**: Stores password entries, ensuring data integrity and security.

6. **Event Handling**:
  - **EventBridge**: Triggers events based on password storage, read, and deletion actions.
  - **Triggers**:
    - **On Stored Event**: Schedules expiration events.
    - **On Read Event**: Fires expiration events.
    - **On Delete Event**: Calls delete triggers.

7. **Logging and Monitoring**:
  - **CloudWatch Logs**: Collects logs from various AWS services and monitors application performance and security.

8. **Permissions and Security**:
  - **IAM Roles**: Assigns permissions to Lambda functions and other services.

### 5.3 Level 3: Detailed Design

**Detailed Interaction and Processes:**
1. **User Interaction**:
  - User accesses the web application via a browser. The content is served from an S3 bucket.
  - User actions (store, read passwords) trigger API calls via the API Gateway.

2. **API Gateway**:
  - Receives user requests and routes them to the appropriate Lambda function.
  - Uses API Keys and IAM policies to ensure secure access.

3. **Lambda Functions**:
  - **Store Password**: Encrypts and stores the password in the NoSQL DB.
  - **Read Password**: Retrieves and decrypts the password from the NoSQL DB.
  - **Delete Password**: Removes the password entry from the NoSQL DB.

4. **Database Operations**:
  - NoSQL DB operations are handled by the Lambda functions.
  - Database events trigger further actions via EventBridge.

5. **EventBridge**:
  - Manages lifecycle events such as password expiration and deletion.
  - Uses triggers to automate workflows based on database events.

6. **Logging and Monitoring**:
  - All activities and errors are logged to CloudWatch Logs for monitoring and troubleshooting.

7. **Security**:
  - IAM roles and policies ensure that only authorized actions are performed by the Lambda functions.
  - Cognito Identity provides secure user authentication and authorization.

### Diagram Summary

![Building-Block-View](./images/05-Building-Block-View.png)

This diagram illustrates the serverless architecture of the secure password exchange application, highlighting the interaction between users, API Gateway, Lambda functions, and other AWS services. 
It showcases how each component fits into the overall system to ensure security, scalability, and maintainability.
