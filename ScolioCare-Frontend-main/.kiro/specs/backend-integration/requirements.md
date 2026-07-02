# Requirements Document

## Introduction

This document specifies the requirements for integrating the existing Flutter ScolioCare frontend application with the complete backend REST API. The integration replaces all mock and hardcoded data with real backend API calls while preserving the existing UI/UX, screen structure, navigation flow, and Provider-based state management architecture.

The ScolioCare backend API provides 60+ REST endpoints across 8 core modules: User Management, AI Imaging & Analysis, Notification System, Exercise Module, Tracking & Monitoring, Report Generation, AI Chatbot, and Settings & Legal. The frontend currently has 14 screens and 7 Provider classes that use mock data. This integration will connect all screens and providers to their corresponding backend endpoints.

## Glossary

- **API_Client**: The centralized HTTP client service that handles all API communication with the backend
- **Auth_Provider**: The frontend state management class responsible for authentication state
- **Scan_Provider**: The frontend state management class responsible for imaging and analysis state
- **Exercise_Provider**: The frontend state management class responsible for exercise program state
- **Chat_Provider**: The frontend state management class responsible for chatbot interaction state
- **Settings_Provider**: The frontend state management class responsible for application settings state
- **Profile_Provider**: The frontend state management class responsible for user profile state
- **Scoliometer_Provider**: The frontend state management class responsible for scoliometer readings state
- **Backend_API**: The ScolioCare REST API server at https://api.scoliocare.app/v1
- **JWT_Token**: JSON Web Token used for authenticating API requests
- **Access_Token**: Short-lived JWT token for API authentication (expires in 15 minutes)
- **Refresh_Token**: Long-lived token for obtaining new access tokens (expires in 7 days)
- **Request_DTO**: Data Transfer Object for API request payloads
- **Response_DTO**: Data Transfer Object for API response payloads
- **Token_Interceptor**: HTTP interceptor that adds authentication tokens to outgoing requests
- **Refresh_Interceptor**: HTTP interceptor that automatically refreshes expired tokens
- **Error_Handler**: Centralized error handling component that translates API errors to user messages
- **Secure_Storage**: Flutter secure storage for persisting sensitive data like JWT tokens
- **Multipart_Request**: HTTP request that supports file uploads with binary data
- **Response_Envelope**: Standard API response wrapper containing success, data, message, timestamp, and errorCode fields
- **Analysis_Status**: The current state of an AI image analysis (pending, processing, completed, failed)
- **Report_Status**: The current state of a report generation (pending, generating, completed, failed)

- **Loading_State**: UI state indicating an async operation is in progress
- **Error_State**: UI state indicating an operation has failed with error details
- **Empty_State**: UI state indicating no data is available to display
- **Success_State**: UI state indicating an operation completed successfully
- **Offline_Mode**: Application state when network connectivity is unavailable

## Requirements

### Requirement 1: API Client Layer

**User Story:** As a developer, I want a centralized API client layer, so that all HTTP communication with the backend is consistent and maintainable.

#### Acceptance Criteria

1. THE API_Client SHALL provide methods for GET, POST, PUT, PATCH, and DELETE HTTP operations
2. THE API_Client SHALL use the base URL https://api.scoliocare.app/v1 for all API requests
3. THE API_Client SHALL parse all responses using the Response_Envelope format
4. WHEN a response has success=false, THE API_Client SHALL throw an exception with the errorCode and message
5. THE API_Client SHALL set the Content-Type header to application/json for all non-multipart requests
6. THE API_Client SHALL support Multipart_Request for image upload endpoints
7. THE API_Client SHALL provide timeout configuration with a default of 30 seconds
8. THE API_Client SHALL log all request and response details in debug mode
9. FOR ALL API requests with authentication, THE API_Client SHALL include the Access_Token in the Authorization header
10. THE API_Client SHALL provide methods to serialize Request_DTO objects to JSON
11. THE API_Client SHALL provide methods to deserialize JSON responses to Response_DTO objects

### Requirement 2: Authentication Token Management

**User Story:** As a user, I want my authentication session to be maintained securely, so that I remain logged in across app restarts and my tokens are refreshed automatically.

#### Acceptance Criteria

1. WHEN a user successfully authenticates, THE Auth_Provider SHALL store the Access_Token and Refresh_Token in Secure_Storage
2. WHEN the app starts, THE Auth_Provider SHALL load tokens from Secure_Storage and verify their validity
3. WHEN the Access_Token expires, THE Token_Interceptor SHALL automatically use the Refresh_Token to obtain a new Access_Token
4. IF the Refresh_Token is expired or invalid, THE Auth_Provider SHALL log the user out and navigate to the login screen
5. WHEN a user logs out, THE Auth_Provider SHALL delete all tokens from Secure_Storage
6. THE Token_Interceptor SHALL add the Access_Token to the Authorization header as "Bearer {token}"
7. WHEN a 401 Unauthorized response is received, THE Refresh_Interceptor SHALL attempt token refresh before retrying the original request
8. IF token refresh succeeds, THE Refresh_Interceptor SHALL retry the original request with the new Access_Token
9. IF token refresh fails, THE Refresh_Interceptor SHALL log the user out without retrying the original request
10. THE Auth_Provider SHALL maintain a boolean isLoggedIn state based on token presence and validity

### Requirement 3: User Registration and Login

**User Story:** As a new user, I want to register with email and password or social login, so that I can create an account and access the app.

#### Acceptance Criteria

1. WHEN a user submits registration with email, password, and name, THE Auth_Provider SHALL call POST /auth/register
2. WHEN registration succeeds, THE Auth_Provider SHALL store the returned Access_Token and Refresh_Token
3. WHEN registration succeeds, THE Auth_Provider SHALL set isLoggedIn to true and navigate to the profile setup screen
4. IF registration fails with AUTH_EMAIL_EXISTS, THE Auth_Provider SHALL display "Email already registered" message
5. WHEN a user submits login with email and password, THE Auth_Provider SHALL call POST /auth/login
6. WHEN login succeeds, THE Auth_Provider SHALL store the returned tokens and navigate to the dashboard
7. IF login fails with AUTH_INVALID_CREDENTIALS, THE Auth_Provider SHALL display "Invalid email or password" message
8. WHEN a user initiates Google sign-in, THE Auth_Provider SHALL call POST /auth/google with the Google ID token
9. WHEN a user initiates Apple sign-in, THE Auth_Provider SHALL call POST /auth/apple with the Apple authorization code
10. WHEN social login succeeds, THE Auth_Provider SHALL store tokens and navigate appropriately based on profile completion status

### Requirement 4: Email Verification and OTP

**User Story:** As a user, I want to verify my email address with an OTP code, so that my account is secure and verified.

#### Acceptance Criteria

1. WHEN a user registers, THE Backend_API SHALL send a 6-digit OTP code to the registered email
2. WHEN a user submits an OTP code, THE Auth_Provider SHALL call POST /auth/verify-email with email and otp
3. WHEN OTP verification succeeds, THE Auth_Provider SHALL mark the user as verified
4. IF OTP verification fails with AUTH_INVALID_OTP, THE Auth_Provider SHALL display "Invalid or expired code" message
5. WHEN a user requests OTP resend, THE Auth_Provider SHALL call POST /auth/resend-otp
6. WHEN OTP resend succeeds, THE Auth_Provider SHALL display "Verification code sent to your email" message
7. THE Auth_Provider SHALL prevent users with unverified emails from accessing protected features where email verification is required

### Requirement 5: Password Reset Flow

**User Story:** As a user, I want to reset my forgotten password via email, so that I can regain access to my account.

#### Acceptance Criteria

1. WHEN a user submits forgot password with email, THE Auth_Provider SHALL call POST /auth/forgot-password
2. WHEN forgot password succeeds, THE Auth_Provider SHALL display "Password reset link sent to your email" message
3. WHEN a user submits new password with reset token, THE Auth_Provider SHALL call POST /auth/reset-password with token and newPassword
4. WHEN password reset succeeds, THE Auth_Provider SHALL display "Password reset successful" and navigate to login
5. IF password reset fails with AUTH_INVALID_TOKEN, THE Auth_Provider SHALL display "Reset link expired or invalid" message
