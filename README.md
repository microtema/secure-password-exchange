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
- **Containerization**: Docker.
- **Orchestration**: EKS.
- **Secrets Management**: AWS Secrets Manager.

## 5. Building Block View

![Building-Block-View](./docs/images/05-Building-Block-View.png)

### 5.1 Whitebox Overall System
- **System Context**: The system is deployed within a VPC, with restricted access through API Gateway.
- **Key Components**:
    - **DynamoDB**: Stores encrypted data.
    - **Lambda**: Executes serverless functions.
    - **CloudWatch**: Monitors and logs activities.

### 5.2 Level 2: Container Diagram
- **DynamoDB**: Stores encrypted files.
- **API Gateway**: Controls access to the application.

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
- **Use EventBridge**: For scheduling and fire events.

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



