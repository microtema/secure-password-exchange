## 5. Building Block View

### 5.1 Whitebox Overall System
- **System Context**: The system is deployed within a VPC, with restricted access through API Gateway.
- **Key Components**:
    - **EKS Cluster**: Manages the Docker containers.
    - **Secrets Manager**: Stores encryption keys.
    - **S3**: Stores encrypted data.
    - **Lambda**: Executes serverless functions.
    - **CloudWatch**: Monitors and logs activities.

### 5.2 Level 2: Container Diagram
- **EKS**: Hosts application containers.
- **Secrets Manager**: Provides secure access to secrets.
- **S3**: Stores encrypted files.
- **API Gateway**: Controls access to the application.