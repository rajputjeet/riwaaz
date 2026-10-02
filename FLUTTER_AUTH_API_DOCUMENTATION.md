# 📱 Wedora — Flutter Developer API Integration Master Guide

Comprehensive, production-ready REST API documentation created specifically for the Flutter Mobile Application (Customer & Vendor apps).

> ⚡ **Important Architecture Notes:**
> 1. **No OTP Verification:** OTP verification has been removed from the backend. Sign-Up and Login return JWT access tokens immediately.
> 2. **Base URL for Flutter (Wi-Fi):** `http://192.168.1.100:5174/api`
> 3. **Authenticated Requests:** Include the header: `Authorization: Bearer <ACCESS_TOKEN>`

---

## 📑 Table of Contents

- [🌐 1. Base Configuration & Global Headers](#-1-base-configuration--global-headers)
- [👥 2. User Roles Reference](#-2-user-roles-reference)
- [📝 3. Sign Up API (Customer & Vendor)](#-3-sign-up-api-customer--vendor)
- [🔐 4. Login API (Customer & Vendor)](#-4-login-api-customer--vendor)
- [👤 5. Profile Get API](#-5-profile-get-api)
- [✏️ 6. Profile Update API](#-6-profile-update-api)
- [📄 7. Vendor Application Status & Document Submission](#-7-vendor-application-status--document-submission)
- [🚪 8. Logout API](#-8-logout-api)
- [🔑 9. Change Password API](#-9-change-password-api)
- [🗑️ 10. Delete Account API](#-10-delete-account-api)
- [💳 11. Subscription Plans List API](#-11-subscription-plans-list-api)
- [⏳ 12. My Active Plan API (Auto-Expiry Status)](#-12-my-active-plan-api-auto-expiry-status)
- [🛍️ 13. Plan Buy / Renew API](#-13-plan-buy--renew-api)
- [🏷️ 14. Categories List API](#-14-categories-list-api)
- [📜 15. CMS Content Pages API](#-15-cms-content-pages-api)
- [❓ 16. FAQ List API](#-16-faq-list-api)
- [🎨 17. Vendor Portfolio Management APIs (Add, Edit, Delete)](#-17-vendor-portfolio-management-apis-add-edit-delete)
- [📦 18. Vendor Services & Packages Management APIs (Add, Edit, Delete)](#-18-vendor-services--packages-management-apis-add-edit-delete)
- [📅 19. Vendor Bookings APIs (Receive & Accept/Reject)](#-19-vendor-bookings-apis-receive--acceptreject)
- [📊 20. Vendor Dashboard Statistics API](#-20-vendor-dashboard-statistics-api)

---

## 🌐 1. Base Configuration & Global Headers

### Server URLs
- **Local Wi-Fi Base URL (Flutter Device / Emulator):** `http://192.168.1.100:5174/api`
- **File Uploads / Images Base URL:** `http://192.168.1.100:5174` (Prefix relative paths like `/uploads/...` with this domain)

### Common Request Headers
For standard JSON APIs:
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <YOUR_ACCESS_TOKEN>
```

For File Uploads (`FormData` / `multipart/form-data`):
```http
Content-Type: multipart/form-data
Accept: application/json
Authorization: Bearer <YOUR_ACCESS_TOKEN>
```

---

## 👥 2. User Roles Reference

| Role Name | `roleId` | Description |
| :--- | :--- | :--- |
| **Admin** | `1` | Web Admin Panel Administrator |
| **Customer / User** | `2` | Mobile App Client / Customer booking services |
| **Vendor** | `3` | Mobile App Service Provider / Vendor Partner |

---

## 📝 3. Sign Up API (Customer & Vendor)

Registers a new Customer or Vendor account. OTP verification is skipped; returns the access token directly for immediate access.

- **Method:** `POST`
- **Endpoint:** `/auth/sign-up`
- **Auth Required:** No (Public)
- **Content-Type:** `application/json`

### 3.1 Customer Sign-Up Body (`roleId = 2`)
```json
{
  "fullName": "Rahul Sharma",
  "email": "rahul.customer@example.com",
  "phone": "9876543210",
  "password": "Password@123",
  "roleId": 2
}
```

### 3.2 Vendor Sign-Up Body (`roleId = 3`)
Vendors can also pass `subscriptionPlanId` during sign-up to pre-assign their chosen subscription plan.
```json
{
  "fullName": "Amit Verma",
  "email": "royal.photography@example.com",
  "phone": "9812345678",
  "password": "Password@123",
  "roleId": 3,
  "businessName": "Royal Wedding Photography",
  "businessType": "Photography",
  "city": "Mumbai",
  "subscriptionPlanId": "65b82f1a4e21a001a1c90001"
}
```

### Success Response (`201 Created` or `200 OK`)
```json
{
  "success": true,
  "message": "Account created successfully.",
  "data": {
    "_id": "65f1a2b3c4d5e6f7a8b9c0d1",
    "fullName": "Amit Verma",
    "email": "royal.photography@example.com",
    "mobile": "9812345678",
    "roleId": 3,
    "isVerified": true,
    "profileImgId": {
      "url": "",
      "public_id": ""
    },
    "vendorProfile": {
      "businessName": "Royal Wedding Photography",
      "businessType": "Photography",
      "city": "Mumbai",
      "applicationStatus": "Pending",
      "subscriptionPlanId": "65b82f1a4e21a001a1c90001",
      "subscriptionStartDate": "2026-09-30T18:00:00.000Z",
      "subscriptionEndDate": "2026-10-30T18:00:00.000Z",
      "isSubscriptionActive": true,
      "packages": [],
      "services": [],
      "portfolio": []
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## 🔐 4. Login API (Customer & Vendor)

Authenticates user credentials and returns user details with authentication token.

- **Method:** `POST`
- **Endpoint:** `/auth/login`
- **Auth Required:** No (Public)
- **Content-Type:** `application/json`

### Request Body
```json
{
  "email": "royal.photography@example.com",
  "password": "Password@123"
}
```
*(You can also send `"phone"` or `"emailOrMobile"` instead of `"email"`)*

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Login successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7a8b9c0d1",
    "fullName": "Amit Verma",
    "email": "royal.photography@example.com",
    "mobile": "9812345678",
    "roleId": 3,
    "profileImgId": {
      "url": "/uploads/users/avatar123.jpg",
      "public_id": "avatar123.jpg"
    },
    "vendorProfile": {
      "businessName": "Royal Wedding Photography",
      "applicationStatus": "Approved",
      "subscriptionPlanId": {
        "_id": "65b82f1a4e21a001a1c90001",
        "title": "Silver Partner",
        "type": "1 Month",
        "durationInMonths": 1,
        "price": 999
      },
      "subscriptionStartDate": "2026-09-30T18:00:00.000Z",
      "subscriptionEndDate": "2026-10-30T18:00:00.000Z",
      "isSubscriptionActive": true
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

## 👤 5. Profile Get API

Fetches the current logged-in user or vendor's complete profile information.

- **Method:** `GET`
- **Endpoint:** `/users/profile`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Profile data found successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7a8b9c0d1",
    "fullName": "Amit Verma",
    "email": "royal.photography@example.com",
    "mobile": "9812345678",
    "roleId": 3,
    "address": "Bandra West, Mumbai",
    "about": "Award-winning wedding photographer with 10+ years experience.",
    "profileImgId": {
      "url": "/uploads/users/avatar123.jpg",
      "public_id": "avatar123.jpg"
    },
    "vendorProfile": {
      "businessName": "Royal Wedding Photography",
      "ownerName": "Amit Verma",
      "businessAddress": "Bandra West, Mumbai",
      "businessDescription": "Award-winning wedding photographer with 10+ years experience.",
      "applicationStatus": "Approved",
      "isSubscriptionActive": true,
      "subscriptionEndDate": "2026-10-30T18:00:00.000Z",
      "packages": [],
      "services": [],
      "portfolio": []
    }
  }
}
```

---

## ✏️ 6. Profile Update API

Updates profile information for customer or vendor. Only allowed fields are modified: **name**, **profileImg**, **bio**, **address**. When a vendor updates these fields, their vendor business details are automatically kept in sync.

- **Method:** `PUT`
- **Endpoint:** `/users/edit-profile`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `multipart/form-data`

### Form Fields (Multipart / FormData)
| Field | Type | Description |
| :--- | :--- | :--- |
| `name` or `fullName` | String (Optional) | User / Vendor full name |
| `bio` or `about` | String (Optional) | Short biography / description |
| `address` | String (Optional) | City, area or address |
| `phone` or `mobile` | String (Optional) | Contact phone number |
| `profileImg` | File (Optional) | Image file for profile picture (JPEG/PNG) |

### Flutter Code Example (Dio)
```dart
FormData formData = FormData.fromMap({
  'name': 'Amit Verma',
  'bio': 'Creative cinematic wedding photographer based in Mumbai.',
  'address': 'Bandra West, Mumbai, MH',
  if (selectedImageFile != null)
    'profileImg': await MultipartFile.fromFile(
      selectedImageFile.path,
      filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ),
});

Response response = await dio.put(
  '/users/edit-profile',
  data: formData,
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Profile Updated Successfully",
  "data": {
    "_id": "65f1a2b3c4d5e6f7a8b9c0d1",
    "fullName": "Amit Verma",
    "about": "Creative cinematic wedding photographer based in Mumbai.",
    "address": "Bandra West, Mumbai, MH",
    "profileImgId": {
      "url": "/uploads/users/profile_1711234567.jpg",
      "public_id": "profile_1711234567.jpg"
    }
  }
}
```

---

## 📄 7. Vendor Application Status & Document Submission

### 7.1 Get Vendor Application Status
Checks current onboarding approval status. The `applicationStatus` field drives what is displayed in your Flutter UI.

- **Method:** `GET`
- **Endpoint:** `/users/vendor/application/status`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Possible `applicationStatus` Values
| Value | Meaning | UI Behavior |
| :--- | :--- | :--- |
| `"Pending"` | Submitted, not yet reviewed | Show ⏳ yellow badge, hide verified/approved UI |
| `"Under Review"` | Admin is reviewing documents | Show 🔍 amber badge, hide approved UI |
| `"Approved"` | Fully verified and active | Show ✅ green badge, show verified docs as "Approved ✓" |
| `"Rejected"` | Application denied | Show ❌ red badge, prompt re-submission |

> ⚠️ **Important Flutter Implementation Rule:**
> Only show **"Approved ✓"** or verified doc statuses in your UI when `applicationStatus == "Approved"` or `isVerified == true`.
> For all other statuses, show **"Pending"** or **"In Review"** on document cards.

#### Example Response — Pending Status (`200 OK`)
```json
{
  "success": true,
  "message": "Vendor application status fetched successfully",
  "data": {
    "applicationId": "APP-1002",
    "applicationStatus": "Pending",
    "isVerified": false,
    "vendorProfile": {
      "businessName": "Royal Wedding Photography",
      "applicationStatus": "Pending",
      "isSubscriptionActive": true
    }
  }
}
```

#### Example Response — Approved Status (`200 OK`)
```json
{
  "success": true,
  "message": "Vendor application status fetched successfully",
  "data": {
    "applicationId": "APP-1002",
    "applicationStatus": "Approved",
    "isVerified": true,
    "vendorProfile": {
      "businessName": "Royal Wedding Photography",
      "applicationStatus": "Approved",
      "isSubscriptionActive": true
    }
  }
}
```

#### Flutter Conditional Display Logic
```dart
// Use this logic to conditionally show "Approved" in your UI
final isApproved = data['isVerified'] == true ||
    data['applicationStatus'] == 'Approved';

// On document/verification cards:
if (isApproved) {
  // Show: 'Approved ✓' (green badge)
} else {
  // Show: 'Pending' (amber/orange badge)
}
```

### 7.2 Submit Vendor Application & KYC Documents
Submits business details and compliance documents for Admin verification.

- **Method:** `POST`
- **Endpoint:** `/users/vendor/application/submit`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `multipart/form-data`

#### Form Fields
- `businessName`: String (Required)
- `businessType`: String (Required)
- `ownerName`: String (Required)
- `contactNumber`: String (Required)
- `businessEmail`: String (Required)
- `city`: String (Required)
- `state`: String (Required)
- `businessAddress`: String (Required)
- `businessDescription`: String (Optional)
- `aadhar`: File (Aadhaar card document / image)
- `pan`: File (PAN card document / image)
- `businessCert`: File (Business registration certificate)
- `addressProof`: File (Electricity bill or lease agreement)
- `gstDoc`: File (Optional GST Certificate)

---

## 🚪 8. Logout API

Invalidates the active session and clears the server authentication token.

- **Method:** `POST` (or `GET`)
- **Endpoint:** `/auth/logout` *(or `/users/log-out`)*
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Logout successfully",
  "data": ""
}
```

---

## 🔑 9. Change Password API

Allows authenticated users or vendors to change their current password.

- **Method:** `PUT`
- **Endpoint:** `/users/change-password`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

### Request Body
```json
{
  "oldPassword": "Password@123",
  "newPassword": "NewSecurePassword@456"
}
```
*(Accepts either `"oldPassword"` or `"currentPassword"`)*

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Password changed successfully."
}
```

---

## 🗑️ 10. Delete Account API

Soft-deletes the user's account, terminates their session, and notifies the platform administrator.

- **Method:** `DELETE`
- **Endpoint:** `/users/delete-account`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

### Request Body
```json
{
  "reason": "Found alternative solution / not needed anymore",
  "description": "Closing down my wedding studio business."
}
```

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Account deleted successfully."
}
```

---

## 💳 11. Subscription Plans List API

Fetches all active subscription packages available for vendors.
> **Note:** Plans are sorted in the exact logical order: **1 Month ➡️ 3 Months ➡️ 6 Months ➡️ 1 Year**.

- **Method:** `GET`
- **Endpoint:** `/subscription/list`
- **Auth Required:** No (Public)

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Subscriptions found successfully",
  "data": [
    {
      "_id": "65b82f1a4e21a001a1c90001",
      "title": "Starter Partner",
      "type": "1 Month",
      "durationInMonths": 1,
      "price": 999,
      "description": "1 Month access to client inquiries and bookings"
    },
    {
      "_id": "65b82f1a4e21a001a1c90002",
      "title": "Quarterly Pro",
      "type": "3 Months",
      "durationInMonths": 3,
      "price": 2499,
      "description": "3 Months access with priority profile placement"
    },
    {
      "_id": "65b82f1a4e21a001a1c90003",
      "title": "Half-Year Growth",
      "type": "6 Months",
      "durationInMonths": 6,
      "price": 4499,
      "description": "6 Months access with featured listing badge"
    },
    {
      "_id": "65b82f1a4e21a001a1c90004",
      "title": "Annual Platinum",
      "type": "1 Year",
      "durationInMonths": 12,
      "price": 7999,
      "description": "12 Months VIP visibility, top search ranking and zero commission"
    }
  ]
}
```

---

## ⏳ 12. My Active Plan API (Auto-Expiry Status)

Returns the vendor's active subscription plan, expiration date, and remaining days. If the expiration date has passed, the server automatically flags the plan as expired (`isSubscriptionActive: false`, `isExpired: true`).

- **Method:** `GET`
- **Endpoint:** `/users/vendor/plan/active`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

### Active Plan Response (`200 OK`)
```json
{
  "success": true,
  "message": "Active subscription plan fetched successfully",
  "data": {
    "isSubscriptionActive": true,
    "isExpired": false,
    "daysRemaining": 26,
    "subscriptionPlan": {
      "_id": "65b82f1a4e21a001a1c90001",
      "title": "Starter Partner",
      "type": "1 Month",
      "price": 999,
      "durationInMonths": 1
    },
    "subscriptionStartDate": "2026-09-30T18:00:00.000Z",
    "subscriptionEndDate": "2026-10-30T18:00:00.000Z",
    "message": "Your subscription is active with 26 day(s) remaining."
  }
}
```

### Expired Plan Response (`200 OK`)
```json
{
  "success": true,
  "message": "Active subscription plan fetched successfully",
  "data": {
    "isSubscriptionActive": false,
    "isExpired": true,
    "daysRemaining": 0,
    "subscriptionPlan": {
      "_id": "65b82f1a4e21a001a1c90001",
      "title": "Starter Partner"
    },
    "subscriptionStartDate": "2026-08-01T00:00:00.000Z",
    "subscriptionEndDate": "2026-09-01T00:00:00.000Z",
    "message": "Your subscription plan is expired or not active. Please purchase or renew a subscription plan."
  }
}
```

---

## 🛍️ 13. Plan Buy / Renew API

Allows a vendor to purchase their initial plan or renew their plan after it expires. If renewed before the current plan ends, the duration is seamlessly extended from the existing expiry date.

- **Method:** `POST`
- **Endpoint:** `/users/vendor/plan/buy`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

### Request Body
```json
{
  "subscriptionPlanId": "65b82f1a4e21a001a1c90002",
  "paymentMethod": "UPI",
  "transactionId": "UPI-8899123847"
}
```

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Plan 'Quarterly Pro' purchased and activated successfully.",
  "data": {
    "isSubscriptionActive": true,
    "isExpired": false,
    "daysRemaining": 90,
    "subscriptionPlan": {
      "_id": "65b82f1a4e21a001a1c90002",
      "title": "Quarterly Pro",
      "type": "3 Months",
      "price": 2499,
      "durationInMonths": 3
    },
    "subscriptionStartDate": "2026-09-30T18:00:00.000Z",
    "subscriptionEndDate": "2026-12-30T18:00:00.000Z",
    "transactionId": "UPI-8899123847",
    "paymentMethod": "UPI"
  }
}
```

---

## 🏷️ 14. Categories List API

Fetches wedding vendor categories (e.g., Photography, Venue, Makeup, Catering) for dropdowns and discovery.

- **Method:** `GET`
- **Endpoint:** `/category/list`
- **Auth Required:** No (Public)

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Categories fetched successfully",
  "data": [
    {
      "_id": "65a1b2c3d4e5f6a7b8c9d001",
      "name": "Photographers",
      "description": "Wedding & Pre-wedding photography",
      "image": "/uploads/categories/photographers.png"
    },
    {
      "_id": "65a1b2c3d4e5f6a7b8c9d002",
      "name": "Wedding Venues",
      "description": "Banquet halls, lawns & resorts",
      "image": "/uploads/categories/venues.png"
    }
  ]
}
```

---

## 📜 15. CMS Content Pages API

Fetches static content such as Terms & Conditions, Privacy Policy, and About Us.

- **Method:** `GET`
- **Endpoint:** `/cms/list` (or `/cms/data/:typeId`)
- **Auth Required:** No (Public)

### Supported CMS Types
- `terms` / `1`: Terms & Conditions
- `privacy` / `2`: Privacy Policy
- `about` / `3`: About Us
- `refund` / `4`: Refund Policy

### Query by Type Endpoint
- **Endpoint:** `/cms/data/terms` or `/cms/data/privacy`

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "CMS content fetched successfully",
  "data": {
    "title": "Terms & Conditions",
    "type": "terms",
    "description": "<h3>1. Introduction</h3><p>Welcome to Wedora...</p>"
  }
}
```

---

## ❓ 16. FAQ List API

Fetches frequently asked questions for customers and vendors.

- **Method:** `GET`
- **Endpoint:** `/faq/list`
- **Auth Required:** No (Public)

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "FAQs fetched successfully",
  "data": [
    {
      "_id": "65f2a1b3c4d5e6f7a8b9c101",
      "question": "How do I book a vendor?",
      "answer": "Select any vendor, choose a package, and click Book Now.",
      "category": "Customer"
    },
    {
      "_id": "65f2a1b3c4d5e6f7a8b9c102",
      "question": "When do I need to renew my subscription?",
      "answer": "Subscriptions auto-expire after their valid duration. You can renew under My Active Plan.",
      "category": "Vendor"
    }
  ]
}
```

---

## 🎨 17. Vendor Portfolio Management APIs (Add, Edit, Delete)

Approved vendors can showcase photos and videos of their previous work.

### 17.1 Add Portfolio Item
- **Method:** `POST`
- **Endpoint:** `/users/vendor/portfolio/add`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `multipart/form-data`

#### Fields
- `title`: String (Optional / e.g., "Grand Wedding at Taj Palace")
- `type`: String (`"image"` or `"video"`)
- `file`: File (Image or Video file, sent as multipart/form-data - send file instead of url)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Portfolio item added successfully",
  "data": [
    {
      "_id": "65f3c1d2e3f4a5b6c7d8e901",
      "title": "Grand Wedding at Taj Palace",
      "url": "/uploads/taj_wedding.jpg",
      "type": "image"
    }
  ]
}
```

### 17.2 Edit Portfolio Item
- **Method:** `PUT`
- **Endpoint:** `/users/vendor/portfolio/edit/:portfolioId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `multipart/form-data` (or `application/json`)

#### Fields
- `title`: String (Optional)
- `type`: String (`"image"` or `"video"`)
- `file`: File (Optional new image/video file)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Portfolio item updated successfully",
  "data": [
    {
      "_id": "65f3c1d2e3f4a5b6c7d8e901",
      "title": "Grand Royal Wedding at Taj Palace (Updated)",
      "url": "/uploads/taj_wedding_new.jpg",
      "type": "image"
    }
  ]
}
```

### 17.3 Delete Portfolio Item
- **Method:** `DELETE`
- **Endpoint:** `/users/vendor/portfolio/delete/:portfolioId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Portfolio item deleted successfully",
  "data": []
}
```

---

## 📦 18. Vendor Services & Packages Management APIs (Add, Edit, Delete)

Vendors manage their service offerings (Title, Description, Price, Features, Image).

### 18.1 Add Package
- **Method:** `POST`
- **Endpoint:** `/users/vendor/package/add`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

#### Request Body
```json
{
  "title": "Complete Cinematic Wedding Package",
  "price": 75000,
  "description": "Full coverage of Haldi, Sangeet, and Wedding Reception with 2 photographers and 2 drone cinematographers.",
  "duration": "2 Days",
  "features": [
    "Traditional + Candid Photography",
    "Cinematic Teaser (3-5 mins)",
    "Full Length 4K Documentary (45 mins)",
    "Hardbound Luxury Photo Album (40 Pages)"
  ]
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Package added successfully",
  "data": [
    {
      "_id": "65f4d1e2f3a4b5c6d7e8f001",
      "title": "Complete Cinematic Wedding Package",
      "price": 75000,
      "duration": "2 Days",
      "description": "Full coverage of Haldi, Sangeet...",
      "features": ["Traditional + Candid Photography", "Cinematic Teaser"]
    }
  ]
}
```

### 18.2 Edit Package
- **Method:** `PUT`
- **Endpoint:** `/users/vendor/package/edit/:packageId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

#### Request Body
```json
{
  "title": "Complete Cinematic Wedding Package (Revised)",
  "price": 80000,
  "duration": "3 Days",
  "features": [
    "Traditional + Candid Photography",
    "Cinematic Teaser & Drone Video",
    "Fast 7-Day Preview Delivery"
  ]
}
```

### 18.3 Delete Package
- **Method:** `DELETE`
- **Endpoint:** `/users/vendor/package/delete/:packageId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

---

### 18.4 Add Individual Service
- **Method:** `POST`
- **Endpoint:** `/users/vendor/service/add`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `multipart/form-data`

#### Fields
- `name`: String (Required, e.g. "Pre-Wedding Drone Shoot")
- `startingPrice`: Number (Required, e.g. 15000)
- `description`: String (Optional)
- `image`: File (Optional service banner image)

### 18.5 Edit Individual Service
- **Method:** `PUT`
- **Endpoint:** `/users/vendor/service/edit/:serviceId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `multipart/form-data`

### 18.6 Delete Individual Service
- **Method:** `DELETE`
- **Endpoint:** `/users/vendor/service/delete/:serviceId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

---

## 📅 19. Vendor Bookings APIs (Receive & Accept/Reject)

### 19.1 Get Received Bookings List (Vendor)
Retrieves all customer bookings received by the logged-in vendor with customer contact details, event dates, booked package/service name, and status.

- **Method:** `GET`
- **Endpoint:** `/booking/list?status=Pending&page=1&limit=10`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Optional Query Parameters
- `status`: `"Pending"`, `"Confirmed"`, `"Completed"`, `"Cancelled"`
- `search`: Search by customer name, email, phone, or booking ID
- `page`: Page number (Default `1`)
- `limit`: Items per page (Default `10`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Bookings fetched successfully",
  "data": [
    {
      "_id": "65f5a1b2c3d4e5f6a7b8c999",
      "bookingId": "BK-1024",
      "customerName": "Pooja Malhotra",
      "customerEmail": "pooja.m@example.com",
      "customerPhone": "9876501234",
      "serviceName": "Complete Cinematic Wedding Package",
      "eventType": "Wedding Ceremony",
      "eventDate": "2026-11-20T00:00:00.000Z",
      "eventTime": "Full Day",
      "guestCount": 350,
      "venueLocation": "Grand Ballroom, Marriott Resort",
      "city": "Mumbai",
      "totalAmount": 75000,
      "advancePaid": 15000,
      "paymentStatus": "Partial",
      "status": "Pending",
      "notes": "Bride & Groom prefer natural outdoor portraits before sunset.",
      "createdAt": "2026-09-30T10:15:00.000Z"
    }
  ],
  "summary": {
    "all": 12,
    "pending": 4,
    "confirmed": 6,
    "upcoming": 6,
    "cancelled": 2,
    "rejected": 2,
    "completed": 0,
    "totalRevenue": 450000
  },
  "_meta": {
    "totalCount": 12,
    "pageCount": 2,
    "currentPage": 1,
    "perPage": 10
  }
}
```

### 19.2 Accept / Reject Booking API
Vendor accepts or rejects an incoming customer booking.

- **Method:** `PUT`
- **Endpoint:** `/users/vendor/booking/status/:bookingId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

#### Accept Booking Body
```json
{
  "status": "Confirmed",
  "notes": "Booking accepted. We will contact you 3 days prior to finalize schedule."
}
```
*(Accepts `"Confirmed"`, `"Accepted"`, or `"Approved"`)*

#### Reject Booking Body
```json
{
  "status": "Cancelled",
  "notes": "Unfortunately already booked on this specific date."
}
```
*(Accepts `"Cancelled"`, `"Rejected"`, or `"Declined"`)*

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Booking has been confirmed successfully",
  "data": {
    "_id": "65f5a1b2c3d4e5f6a7b8c999",
    "bookingId": "BK-1024",
    "status": "Confirmed",
    "notes": "Booking accepted. We will contact you 3 days prior to finalize schedule."
  }
}
```

---

## 📊 20. Vendor Dashboard Statistics API

Provides summary metrics for the vendor's home/dashboard screen: counts of All, Pending, Upcoming (Confirmed), Rejected (Cancelled) bookings, financial revenue, active subscription status, and recent bookings.

- **Method:** `GET`
- **Endpoint:** `/users/vendor/dashboard-stats`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Vendor dashboard statistics fetched successfully",
  "data": {
    "bookingsCount": {
      "all": 12,
      "pending": 4,
      "upcoming": 6,
      "rejected": 2,
      "completed": 0
    },
    "financials": {
      "totalRevenue": 450000
    },
    "portfolioStats": {
      "totalPackages": 3,
      "totalServices": 4,
      "totalPortfolioItems": 8
    },
    "subscription": {
      "isSubscriptionActive": true,
      "isExpired": false,
      "daysRemaining": 26,
      "planTitle": "Starter Partner",
      "planType": "1 Month",
      "subscriptionEndDate": "2026-10-30T18:00:00.000Z"
    },
    "applicationStatus": "Approved",
    "recentBookings": [
      {
        "_id": "65f5a1b2c3d4e5f6a7b8c999",
        "bookingId": "BK-1024",
        "customerName": "Pooja Malhotra",
        "serviceName": "Complete Cinematic Wedding Package",
        "eventDate": "2026-11-20T00:00:00.000Z",
        "status": "Pending",
        "totalAmount": 75000
      }
    ]
  }
}
```


---

## 📢 21. Ads Pricing & Vendor Sponsored Ads APIs

Complete API suite for Ads Pricing Plans, Vendor Ad Purchases, Vendor My Active Ad, and Public User Side Active Sponsored Vendors List.

### 21.1 Get Ads Pricing Plans List (Public / Vendor)

Returns active available Ad Plans for vendors to purchase (e.g. 1 Day, 3 Days, 1 Week).

- **Method:** `GET`
- **Endpoint:** `/ad/list`
- **Auth Required:** No (Public)

#### Response (`200 OK`)

```json
{
  "success": true,
  "message": "Ad Plans retrieved successfully",
  "data": [
    {
      "_id": "6701a2b3c4d5e6f7a8b9c001",
      "title": "1 Day Featured Boost",
      "duration": "1 Day",
      "durationInDays": 1,
      "price": 199,
      "description": "Showcase your business at top of homepage for 24 hours.",
      "stateId": 1
    },
    {
      "_id": "6701a2b3c4d5e6f7a8b9c002",
      "title": "3 Days Vendor Spotlight",
      "duration": "3 Days",
      "durationInDays": 3,
      "price": 499,
      "description": "Premium top placement in browse & search for 3 full days.",
      "stateId": 1
    },
    {
      "_id": "6701a2b3c4d5e6f7a8b9c003",
      "title": "1 Week Ultimate Platinum Ad",
      "duration": "1 Week",
      "durationInDays": 7,
      "price": 999,
      "description": "Maximum reach with #1 position priority & platinum badge for 7 days.",
      "stateId": 1
    }
  ]
}
```

---

### 21.2 Vendor Buy / Run Ad API (Vendor)

Purchases and immediately starts an Ad campaign for the vendor. Automatically computes `adStartDate`, `adEndDate`, and sets `isAdActive: true`.

- **Method:** `POST`
- **Endpoint:** `/ad/buy`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)
- **Content-Type:** `application/json`

#### Request Body

```json
{
  "adPlanId": "6701a2b3c4d5e6f7a8b9c001"
}
```

#### Success Response (`200 OK`)

```json
{
  "success": true,
  "message": "Ad campaign purchased and activated successfully!",
  "data": {
    "purchase": {
      "_id": "6702b3c4d5e6f7a8b9c00111",
      "vendorId": "65f1a2b3c4d5e6f7a8b9c0d1",
      "adPlanId": "6701a2b3c4d5e6f7a8b9c001",
      "amount": 199,
      "paymentStatus": "Paid",
      "startDate": "2026-10-03T00:00:00.000Z",
      "endDate": "2026-10-04T00:00:00.000Z",
      "isActive": true
    },
    "vendor": {
      "isAdActive": true,
      "adTitle": "1 Day Featured Boost",
      "adDuration": "1 Day",
      "adStartDate": "2026-10-03T00:00:00.000Z",
      "adEndDate": "2026-10-04T00:00:00.000Z",
      "adDaysLeft": 1
    }
  }
}
```

---

### 21.3 Vendor Check My Active Ad API (Vendor)

Checks if the authenticated vendor currently has an active ad running, along with days remaining and expiry details.

- **Method:** `GET`
- **Endpoint:** `/ad/my-ad`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Active Ad Response (`200 OK`)

```json
{
  "success": true,
  "message": "Active Ad status retrieved",
  "data": {
    "hasActiveAd": true,
    "ad": {
      "title": "1 Week Ultimate Platinum Ad",
      "duration": "1 Week",
      "startDate": "2026-10-03T00:00:00.000Z",
      "endDate": "2026-10-10T00:00:00.000Z",
      "daysLeft": 7,
      "isActive": true
    }
  }
}
```

---

### 21.4 Public User Side Featured / Sponsored Vendors List API (User Side)

Returns all vendors who currently have an active ad running (`isAdActive: true` and `adEndDate >= now`), automatically prioritized and sorted according to their purchased ad duration tier.

> 🌟 **Weighted Rotation & Freshness Boost Logic:**
>
> 1. **⚡ Freshness Boost (+100 Points):** Any vendor who purchases an Ad (1-Day, 3-Days, or 1-Week) within the **last 24 hours** automatically receives a **+100 Freshness Boost**. This guarantees that a newly purchased 1-Day ad immediately jumps to **Position #1 (TOP)** during its 24-hour campaign window!
> 2. **🏆 Tier Weight (7 Days = +30, 3 Days = +20, 1 Day = +10):** 7-Day and 3-Day ads retain higher base tier weights so they stay near top throughout their 7-day / 3-day active duration once the 24-hour initial boost ends.
> 3. **⏱️ Auto-Expiry Handling:** Once an ad's end date passes, `isAdActive` turns `false` automatically and the vendor is excluded from this API response.

- **Method:** `GET`
- **Endpoint:** `/ad/active-vendors`
- **Auth Required:** No (Public)
- **Optional Query Params:** `?categoryId=<CATEGORY_ID>` (Filter featured vendors by category)

#### Response (`200 OK`)

```json
{
  "success": true,
  "message": "Featured / Sponsored Vendors List",
  "data": {
    "list": [
      {
        "_id": "65f1a2b3c4d5e6f7a8b9c0d1",
        "fullName": "Royal Clicks Studio",
        "email": "royal@gmail.com",
        "mobile": "8556936887",
        "roleId": 3,
        "isFeatured": true,
        "adPriority": 1,
        "adBadge": "SPONSORED (1 WEEK PLATINUM)",
        "vendorProfile": {
          "businessName": "Royal Clicks Studio",
          "city": "Mohali",
          "isAdActive": true,
          "adTitle": "1 Week Ultimate Platinum Ad",
          "adDuration": "1 Week",
          "adDurationInDays": 7,
          "adStartDate": "2026-10-03T00:00:00.000Z",
          "adEndDate": "2026-10-10T00:00:00.000Z",
          "adDaysLeft": 7,
          "adPriority": 1,
          "adBadge": "SPONSORED (1 WEEK PLATINUM)",
          "isSubscriptionActive": true
        }
      },
      {
        "_id": "65f1a2b3c4d5e6f7a8b9c0d2",
        "fullName": "Golden Event Caterers",
        "email": "golden.caterers@gmail.com",
        "mobile": "9812345678",
        "roleId": 3,
        "isFeatured": true,
        "adPriority": 2,
        "adBadge": "SPONSORED (3 DAYS SPOTLIGHT)",
        "vendorProfile": {
          "businessName": "Golden Event Caterers",
          "city": "Chandigarh",
          "isAdActive": true,
          "adTitle": "3 Days Vendor Spotlight",
          "adDuration": "3 Days",
          "adDurationInDays": 3,
          "adStartDate": "2026-10-03T00:00:00.000Z",
          "adEndDate": "2026-10-06T00:00:00.000Z",
          "adDaysLeft": 3,
          "adPriority": 2,
          "adBadge": "SPONSORED (3 DAYS SPOTLIGHT)",
          "isSubscriptionActive": true
        }
      }
    ],
    "totalCount": 2,
    "grouped": {
      "oneWeekAds": [],
      "threeDaysAds": [],
      "oneDayAds": []
    }
  }
}
```

---

## 🛠️ Flutter Quick Integration Snippets (Dio)

### Common API Client Setup
```dart
import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.100:5174/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  static void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}
```

### Fetch Active Plan & Handle Expiry Alert
```dart
Future<void> checkVendorSubscription() async {
  try {
    final response = await ApiClient.dio.get('/users/vendor/plan/active');
    final data = response.data['data'];
    
    final bool isExpired = data['isExpired'] ?? false;
    final int daysRemaining = data['daysRemaining'] ?? 0;

    if (isExpired || daysRemaining <= 0) {
      // Show dialog prompting vendor to renew their plan
      showSubscriptionExpiredDialog();
    }
  } catch (e) {
    print('Failed to check subscription: $e');
  }
}
```

### Accept / Reject Booking in Flutter
```dart
Future<void> updateBookingStatus(String bookingId, bool accept, {String? notes}) async {
  try {
    final response = await ApiClient.dio.put(
      '/users/vendor/booking/status/$bookingId',
      data: {
        'status': accept ? 'Confirmed' : 'Cancelled',
        'notes': notes ?? (accept ? 'Accepted by vendor' : 'Declined by vendor'),
      },
    );

    if (response.data['success'] == true) {
      // Refresh vendor dashboard or bookings list
    }
  } catch (e) {
    print('Error updating booking: $e');
  }
}
```
