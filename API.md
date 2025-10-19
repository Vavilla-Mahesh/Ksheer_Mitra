# API Documentation - Ksheermitra

Complete API reference for the Ksheermitra Smart Milk Delivery System.

## Base URL
```
Development: http://localhost:3000/api
Production: https://api.ksheermitra.com/api
```

## Authentication

All endpoints except `/auth/*` require JWT authentication.

**Header:**
```
Authorization: Bearer <token>
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { },
  "message": "Success message"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "field": "fieldName",
      "message": "Error description"
    }
  ]
}
```

---

## Authentication Endpoints

### Send OTP
Send OTP to user's WhatsApp.

**Endpoint:** `POST /auth/send-otp`

**Request Body:**
```json
{
  "phone": "+919876543210"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "expiresAt": "2024-01-01T10:10:00.000Z"
}
```

---

### Verify OTP
Verify OTP and get authentication token.

**Endpoint:** `POST /auth/verify-otp`

**Request Body:**
```json
{
  "phone": "+919876543210",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "name": "User Name",
    "phone": "+919876543210",
    "role": "customer",
    "email": null,
    "address": null,
    "latitude": null,
    "longitude": null,
    "areaId": null,
    "isActive": true
  },
  "token": "jwt.token.here",
  "refreshToken": "refresh.token.here"
}
```

---

### Refresh Token
Get new access token using refresh token.

**Endpoint:** `POST /auth/refresh-token`

**Request Body:**
```json
{
  "refreshToken": "refresh.token.here"
}
```

**Response:**
```json
{
  "success": true,
  "token": "new.jwt.token.here"
}
```

---

## Customer Endpoints

All customer endpoints require authentication with `customer` role.

### Get Profile
**Endpoint:** `GET /customer/profile`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Customer Name",
    "phone": "+919876543210",
    "email": "customer@example.com",
    "address": "123 Main St",
    "latitude": "12.9716",
    "longitude": "77.5946",
    "areaId": "area-uuid",
    "area": {
      "id": "area-uuid",
      "name": "Zone A"
    }
  }
}
```

---

### Update Profile
**Endpoint:** `PUT /customer/profile`

**Request Body:**
```json
{
  "name": "Updated Name",
  "email": "newemail@example.com",
  "address": "New Address",
  "latitude": "12.9716",
  "longitude": "77.5946"
}
```

---

### Create Subscription
**Endpoint:** `POST /customer/subscriptions`

**Request Body:**
```json
{
  "productId": "product-uuid",
  "quantity": 1.0,
  "frequency": "daily",
  "selectedDays": [1, 3, 5],
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

**Frequency Options:**
- `daily` - Every day
- `weekly` - Selected days of week
- `monthly` - Same date every month
- `custom` - Custom schedule

**Selected Days:** (0=Sunday, 1=Monday, ..., 6=Saturday)

---

### Get Subscriptions
**Endpoint:** `GET /customer/subscriptions`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "subscription-uuid",
      "customerId": "customer-uuid",
      "productId": "product-uuid",
      "quantity": 1.0,
      "frequency": "daily",
      "selectedDays": null,
      "startDate": "2024-01-01",
      "endDate": "2024-12-31",
      "status": "active",
      "product": {
        "id": "product-uuid",
        "name": "Full Cream Milk",
        "unit": "liter",
        "pricePerUnit": 60.00
      }
    }
  ]
}
```

---

### Pause Subscription
**Endpoint:** `POST /customer/subscriptions/:id/pause`

**Request Body:**
```json
{
  "pauseStartDate": "2024-06-01",
  "pauseEndDate": "2024-06-15"
}
```

---

### Resume Subscription
**Endpoint:** `POST /customer/subscriptions/:id/resume`

---

### Get Delivery History
**Endpoint:** `GET /customer/deliveries`

**Query Parameters:**
- `startDate` (optional): YYYY-MM-DD
- `endDate` (optional): YYYY-MM-DD

---

### Get Invoices
**Endpoint:** `GET /customer/invoices`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "invoice-uuid",
      "invoiceNumber": "INV-M-202401-12345",
      "type": "monthly",
      "invoiceDate": "2024-01-01",
      "periodStart": "2024-01-01",
      "periodEnd": "2024-01-31",
      "totalAmount": 1800.00,
      "paidAmount": 0.00,
      "paymentStatus": "pending",
      "pdfPath": "/path/to/invoice.pdf"
    }
  ]
}
```

---

## Delivery Boy Endpoints

All delivery boy endpoints require authentication with `delivery_boy` role.

### Get Assigned Customers
**Endpoint:** `GET /delivery/customers`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD (defaults to today)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "customer-uuid",
      "name": "Customer Name",
      "phone": "+919876543210",
      "address": "123 Main St",
      "latitude": "12.9716",
      "longitude": "77.5946",
      "deliveries": [
        {
          "id": "delivery-uuid",
          "productName": "Full Cream Milk",
          "quantity": 1.0,
          "unit": "liter",
          "amount": 60.00,
          "status": "pending"
        }
      ]
    }
  ]
}
```

---

### Get Optimized Route
**Endpoint:** `GET /delivery/route`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD

**Response:**
```json
{
  "success": true,
  "data": {
    "optimizedOrder": [0, 2, 1],
    "optimizedDestinations": [
      {
        "id": "customer-uuid",
        "name": "Customer Name",
        "latitude": "12.9716",
        "longitude": "77.5946"
      }
    ],
    "routes": [
      {
        "startAddress": "Start Location",
        "endAddress": "Customer 1",
        "distance": "2.5 km",
        "duration": "10 mins",
        "distanceMeters": 2500,
        "durationSeconds": 600
      }
    ],
    "totalDistance": 5000,
    "totalDuration": 1200
  }
}
```

---

### Update Delivery Status
**Endpoint:** `PUT /delivery/delivery-status`

**Request Body:**
```json
{
  "deliveryId": "delivery-uuid",
  "status": "delivered",
  "notes": "Delivered successfully"
}
```

**Status Options:** `delivered`, `missed`

---

### Get Delivery Stats
**Endpoint:** `GET /delivery/stats`

**Query Parameters:**
- `date` (optional): YYYY-MM-DD

**Response:**
```json
{
  "success": true,
  "data": {
    "pending": 10,
    "delivered": 45,
    "missed": 2,
    "cancelled": 1,
    "totalDelivered": 45,
    "totalAmount": 2700.00
  }
}
```

---

### Generate Daily Invoice
**Endpoint:** `POST /delivery/generate-invoice`

**Request Body:**
```json
{
  "date": "2024-01-15"
}
```

---

## Admin Endpoints

All admin endpoints require authentication with `admin` role.

### List Customers
**Endpoint:** `GET /admin/customers`

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 50)
- `search` (optional): Search by name or phone

**Response:**
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "id": "uuid",
        "name": "Customer Name",
        "phone": "+919876543210",
        "email": "customer@example.com",
        "address": "123 Main St",
        "latitude": "12.9716",
        "longitude": "77.5946",
        "areaId": "area-uuid",
        "area": {
          "id": "area-uuid",
          "name": "Zone A",
          "deliveryBoy": {
            "id": "db-uuid",
            "name": "Delivery Boy Name"
          }
        }
      }
    ],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 50,
      "totalPages": 2
    }
  }
}
```

---

### Get Customers with Locations
**Endpoint:** `GET /admin/customers/map`

Returns all customers with GPS coordinates for map view.

---

### List Delivery Boys
**Endpoint:** `GET /admin/delivery-boys`

---

### Create Delivery Boy
**Endpoint:** `POST /admin/delivery-boys`

**Request Body:**
```json
{
  "name": "Delivery Boy Name",
  "phone": "+919876543211",
  "email": "db@example.com",
  "address": "Address",
  "latitude": "12.9716",
  "longitude": "77.5946"
}
```

---

### Assign Area
**Endpoint:** `POST /admin/assign-area`

**Request Body:**
```json
{
  "customerId": "customer-uuid",
  "areaId": "area-uuid"
}
```

---

### Bulk Assign Area
**Endpoint:** `POST /admin/bulk-assign-area`

**Request Body:**
```json
{
  "customerIds": ["uuid1", "uuid2", "uuid3"],
  "areaId": "area-uuid"
}
```

---

### List Areas
**Endpoint:** `GET /admin/areas`

---

### Create Area
**Endpoint:** `POST /admin/areas`

**Request Body:**
```json
{
  "name": "Zone E",
  "description": "New delivery zone",
  "deliveryBoyId": "db-uuid"
}
```

---

### Update Area
**Endpoint:** `PUT /admin/areas/:id`

**Request Body:**
```json
{
  "name": "Updated Zone Name",
  "deliveryBoyId": "new-db-uuid",
  "isActive": true
}
```

---

### List Products
**Endpoint:** `GET /admin/products`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Full Cream Milk",
      "description": "Fresh full cream milk",
      "category": "Dairy Products",
      "unit": "liter",
      "pricePerUnit": "60.00",
      "stock": 1000,
      "imageUrl": "/uploads/products/product-123.jpg",
      "isActive": true,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

**Accessing Product Images:**
Product images are served as static files at: `http://localhost:3000/uploads/products/filename.jpg`

---

### Create Product
**Endpoint:** `POST /admin/products`

**DEPRECATED: Use the multipart/form-data version below for image uploads**

**Request Body (JSON - without image):**
```json
{
  "name": "Product Name",
  "description": "Product description",
  "category": "Product Category",
  "unit": "liter",
  "pricePerUnit": 60.00,
  "stock": 1000
}
```

**Unit Options:** `liter`, `ml`, `kg`, `gm`, `piece`

---

### Update Product
**Endpoint:** `PUT /admin/products/:id`

**DEPRECATED: Use the multipart/form-data version below for image uploads**

**Request Body (JSON - without image):**
```json
{
  "name": "Updated Name",
  "category": "Updated Category",
  "pricePerUnit": 65.00,
  "isActive": true
}
```

---

### Get Daily Invoices
**Endpoint:** `GET /admin/invoices/daily`

**Query Parameters:**
- `startDate` (optional): YYYY-MM-DD
- `endDate` (optional): YYYY-MM-DD
- `deliveryBoyId` (optional): Filter by delivery boy

---

### Create Product (with Image Upload)
**Endpoint:** `POST /admin/products`

**Content-Type:** `multipart/form-data`

**Form Fields:**
- `name` (required): Product name (2-100 characters)
- `description` (optional): Product description
- `category` (optional): Product category (2-100 characters)
- `unit` (required): Unit of measurement (`liter`, `ml`, `kg`, `gm`, `piece`)
- `pricePerUnit` (required): Price per unit (positive decimal)
- `stock` (optional): Initial stock quantity (non-negative integer)
- `image` (optional): Product image file (JPEG, PNG, GIF, WebP, max 5MB)

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/admin/products \
  -H "Authorization: Bearer $TOKEN" \
  -F "name=Organic Milk" \
  -F "description=Fresh organic milk" \
  -F "category=Dairy Products" \
  -F "unit=liter" \
  -F "pricePerUnit=70" \
  -F "stock=500" \
  -F "image=@/path/to/image.jpg"
```

**Response:**
```json
{
  "success": true,
  "message": "Product created successfully",
  "data": {
    "id": "uuid",
    "name": "Organic Milk",
    "description": "Fresh organic milk",
    "category": "Dairy Products",
    "unit": "liter",
    "pricePerUnit": "70.00",
    "stock": 500,
    "imageUrl": "/uploads/products/product-1234567890-123456789.jpg",
    "isActive": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

---

### Update Product (with Image Upload)
**Endpoint:** `PUT /admin/products/:id`

**Content-Type:** `multipart/form-data`

**Form Fields:**
All fields are optional. Include only the fields you want to update.
- `name`: Product name
- `description`: Product description
- `category`: Product category
- `unit`: Unit of measurement
- `pricePerUnit`: Price per unit
- `stock`: Stock quantity
- `isActive`: Active status (true/false)
- `image`: New product image (replaces existing image)

**Example cURL:**
```bash
curl -X PUT http://localhost:3000/api/admin/products/uuid \
  -H "Authorization: Bearer $TOKEN" \
  -F "pricePerUnit=75" \
  -F "image=@/path/to/new-image.jpg"
```

---

### Get All Subscriptions
**Endpoint:** `GET /admin/subscriptions`

**Query Parameters:**
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 50, max: 100): Items per page
- `status` (optional): Filter by status (`active`, `paused`, `cancelled`, `completed`)
- `customerId` (optional): Filter by customer UUID

**Response:**
```json
{
  "success": true,
  "data": {
    "subscriptions": [
      {
        "id": "subscription-uuid",
        "customer": {
          "id": "customer-uuid",
          "name": "Customer Name",
          "phone": "+919876543210",
          "email": "customer@example.com",
          "address": "123 Main St"
        },
        "product": {
          "id": "product-uuid",
          "name": "Full Cream Milk",
          "unit": "liter",
          "pricePerUnit": "60.00",
          "category": "Dairy Products",
          "imageUrl": "/uploads/products/product-123.jpg"
        },
        "quantity": "1.00",
        "frequency": "daily",
        "selectedDays": [1, 2, 3, 4, 5],
        "startDate": "2024-01-01",
        "endDate": "2024-12-31",
        "status": "active",
        "pauseStartDate": null,
        "pauseEndDate": null,
        "estimatedMonthlyAmount": 1800.00,
        "createdAt": "2024-01-01T00:00:00.000Z",
        "updatedAt": "2024-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 150,
      "page": 1,
      "limit": 50,
      "totalPages": 3
    }
  }
}
```

---

### Generate Monthly Invoice for Customer
**Endpoint:** `POST /admin/invoices/generate-monthly`

**Request Body:**
```json
{
  "customerId": "customer-uuid",
  "year": 2024,
  "month": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Monthly invoice generated successfully",
  "data": {
    "id": "invoice-uuid",
    "invoiceNumber": "INV-M-202401-12345678",
    "customerId": "customer-uuid",
    "type": "monthly",
    "invoiceDate": "2024-02-01",
    "periodStart": "2024-01-01",
    "periodEnd": "2024-01-31",
    "totalAmount": "1860.00",
    "paidAmount": "0.00",
    "paymentStatus": "pending",
    "pdfPath": "/path/to/invoice.pdf",
    "sentViaWhatsApp": true,
    "sentAt": "2024-02-01T00:00:00.000Z",
    "deliveryDetails": {
      "deliveries": [
        {
          "date": "01-01-2024",
          "productName": "Full Cream Milk",
          "quantity": "1.00",
          "unit": "liter",
          "amount": "60.00"
        }
      ]
    }
  }
}
```

---

### Generate Monthly Invoices for All Customers
**Endpoint:** `POST /admin/invoices/generate-all-monthly`

Generates monthly invoices for all active customers. This is a long-running operation.

**Request Body:**
```json
{
  "year": 2024,
  "month": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Monthly invoice generation completed",
  "data": {
    "total": 150,
    "generated": 145,
    "failed": 5,
    "errors": [
      {
        "customerId": "customer-uuid",
        "customerName": "Customer Name",
        "error": "No deliveries found for the specified period"
      }
    ]
  }
}
```

---

### Get Customer Invoices
**Endpoint:** `GET /admin/customers/:customerId/invoices`

**Query Parameters:**
- `type` (optional): Filter by type (`daily`, `monthly`)
- `paymentStatus` (optional): Filter by status (`pending`, `partial`, `paid`)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "invoice-uuid",
      "invoiceNumber": "INV-M-202401-12345678",
      "customerId": "customer-uuid",
      "customer": {
        "id": "customer-uuid",
        "name": "Customer Name",
        "phone": "+919876543210",
        "email": "customer@example.com",
        "address": "123 Main St"
      },
      "type": "monthly",
      "invoiceDate": "2024-02-01",
      "periodStart": "2024-01-01",
      "periodEnd": "2024-01-31",
      "totalAmount": "1860.00",
      "paidAmount": "500.00",
      "paymentStatus": "partial",
      "pdfPath": "/path/to/invoice.pdf",
      "sentViaWhatsApp": true,
      "sentAt": "2024-02-01T00:00:00.000Z"
    }
  ]
}
```

---

### Mark Invoice as Paid
**Endpoint:** `POST /admin/invoices/:invoiceId/mark-paid`

Record a payment for an invoice. Can be called multiple times to record partial payments.

**Request Body:**
```json
{
  "paidAmount": 500.00
}
```

**Response:**
```json
{
  "success": true,
  "message": "Payment recorded successfully",
  "data": {
    "id": "invoice-uuid",
    "invoiceNumber": "INV-M-202401-12345678",
    "totalAmount": "1860.00",
    "paidAmount": "500.00",
    "paymentStatus": "partial"
  }
}
```

**Payment Status Logic:**
- `pending`: paidAmount = 0
- `partial`: 0 < paidAmount < totalAmount
- `paid`: paidAmount >= totalAmount

---

### Carry Forward Dues
**Endpoint:** `POST /admin/invoices/carry-forward-dues`

Creates a new invoice for the specified month that includes all pending dues from previous months.

**Request Body:**
```json
{
  "customerId": "customer-uuid",
  "year": 2024,
  "month": 2
}
```

**Response:**
```json
{
  "success": true,
  "message": "Dues carried forward successfully",
  "data": {
    "invoice": {
      "id": "invoice-uuid",
      "invoiceNumber": "INV-M-202402-12345678",
      "customerId": "customer-uuid",
      "type": "monthly",
      "invoiceDate": "2024-03-01",
      "periodStart": "2024-02-01",
      "periodEnd": "2024-02-29",
      "totalAmount": "3220.00",
      "paidAmount": "0.00",
      "paymentStatus": "pending",
      "deliveryDetails": {
        "deliveries": [],
        "currentMonthAmount": 1860.00,
        "previousDues": 1360.00,
        "totalAmount": 3220.00
      }
    },
    "previousDues": 1360.00,
    "currentMonthAmount": 1860.00,
    "totalAmount": 3220.00
  }
}
```

---

### Assign Delivery Boy to Area
**Endpoint:** `POST /admin/areas/assign-delivery-boy`

Assigns or unassigns a delivery boy to/from an area. Only one delivery boy can be assigned to an area at a time.

**Request Body:**
```json
{
  "areaId": "area-uuid",
  "deliveryBoyId": "delivery-boy-uuid"
}
```

**To unassign a delivery boy:**
```json
{
  "areaId": "area-uuid",
  "deliveryBoyId": null
}
```

**Response:**
```json
{
  "success": true,
  "message": "Delivery boy assigned to area successfully",
  "data": {
    "id": "area-uuid",
    "name": "Zone A",
    "description": "North area",
    "deliveryBoyId": "delivery-boy-uuid",
    "isActive": true
  }
}
```

---

## Error Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (invalid token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 409 | Conflict (duplicate entry) |
| 429 | Too Many Requests (rate limited) |
| 500 | Internal Server Error |

---

## Rate Limiting

- Default: 100 requests per 15 minutes per IP
- Configurable via `RATE_LIMIT_WINDOW_MS` and `RATE_LIMIT_MAX_REQUESTS` in .env

---

## Testing with cURL

### Get Token
```bash
# Send OTP
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}'

# Verify OTP
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "otp": "123456"}'
```

### Use Token
```bash
TOKEN="your.jwt.token.here"

curl -X GET http://localhost:3000/api/customer/profile \
  -H "Authorization: Bearer $TOKEN"
```

---

## Postman Collection

Import this base request:
- **Base URL**: `{{baseUrl}}/api`
- **Authorization**: Bearer Token
- **Headers**: `Content-Type: application/json`

Create environment variables:
- `baseUrl`: http://localhost:3000
- `token`: (auto-set after login)
