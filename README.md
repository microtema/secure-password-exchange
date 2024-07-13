# Secure Password Exchange

## 1. Introduction and Goals

### 1.1 Requirements Overview
- **Customer Requirement**: Secure way for employees to exchange passwords.
- **Key Requirement**: Application accessible only from the customer's private network.
- **Technology**: Yopass-like solution using AWS tools.

### 1.2 Quality Goals
- **Security**: High priority on secure data exchange and storage.
- **Usability**: Ease of use for end-users.
- **Maintainability**: Easy to update and maintain the system.

## 2. Constraints
- **Security Constraints**: Application must operate within a private network.
- **Technology Constraints**: Must use AWS tools.
- **Compliance Constraints**: Follow GDPR guidelines for data security and privacy.

## 3. Context and Scope

![Context-And-Scope-View](./docs/images/04-Context-And-Scope-View.png)

### 3.1 Business Context
- **Customer**: Company requiring secure password exchange among employees.
- **Stakeholders**: IT department, Security team, End-users.

### 3.2 Technical Context
- **External Systems**: Internal network, authentication systems.
- **Interfaces**: API Gateway, VPC.

## 4. Solution Strategy

### 4.1 Overall Solution Approach
- **Architecture Style**: Microservices deployed using containers (Docker) orchestrated by Kubernetes (EKS).
- **Security Measures**: Use AWS IAM, Secrets Manager, and encrypted storage (S3).

### 4.2 Key Decisions
- **Cloud Provider**: AWS.
- **EventBridge**: AWS serverless event bus service.
- **Secrets Management**: AWS Secrets Manager.

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
  - User actions (store, read, delete passwords) trigger API calls via the API Gateway.

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

![Building-Block-View](./docs/images/05-Building-Block-View.png)

This diagram illustrates the serverless architecture of the secure password exchange application, highlighting the interaction between users, API Gateway, Lambda functions, and other AWS services. It showcases how each component fits into the overall system to ensure security, scalability, and maintainability.


## 6. Runtime View

![Runtime-View](./docs/images/06-Runtime-View.png)

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

## 8. Cross-cutting Concepts

### 8.1 Security
- **Encryption**: Data is encrypted at rest and in transit.
- **IAM Roles**: Strict access control using IAM roles.

### 8.2 Monitoring and Logging
- **CloudWatch**: Logs application activities and alerts on anomalies.

### 8.3 Compliance
- **Data Protection**: Adheres to GDPR requirements.

## 8. Cross-cutting Concepts

### 8.1 Security
- **Encryption**: Data is encrypted at rest and in transit.
- **IAM Roles**: Strict access control using IAM roles.

### 8.2 Monitoring and Logging
- **CloudWatch**: Logs application activities and alerts on anomalies.

### 8.3 Compliance
- **Data Protection**: Adheres to GDPR requirements.

## 9. Design Decisions
- **Use AWS Lambdas**: For cloud computing.
- **Use DynamoDB**: For scalable and secure storage of encrypted data.
- **Use EventBridge**: Centralized stream for managing events from different sources.

## 10. Quality Requirements

### 10.1 Quality Tree
- **Security**: Highest priority, secure data exchange and storage.
- **Availability**: Ensure high availability and reliability.
- **Performance**: Optimize for efficient processing and minimal latency.

### 10.2 Quality Scenarios
- **Scenario 1**: Unauthorized access attempt - system must log and alert.
- **Scenario 2**: Data breach - system must encrypt all sensitive data.

## 11. Risks and Technical Debt
- **Risks**:
    - **Data Breach**: Mitigated by strong encryption and IAM policies.
    - **Insider Threat**: Mitigated by least privilege access and monitoring.
- **Technical Debt**: Regular audits and updates to address potential vulnerabilities.

# Glossary

| Term  | Beschreibung                           | 
|-------|----------------------------------------| 
| AWS   | Amazon Web Services                    |
| VPC   | Virtual Private Cloud                  |
| IAM   | Identity and Access Management         |
| GDPR  | Global Data Protection Regulatory      |



