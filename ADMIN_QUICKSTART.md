# Admin Quick Start Guide

## Getting Started

This guide helps you quickly get started with the new admin features.

## Authentication

First, obtain your admin JWT token:

```bash
# 1. Request OTP
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}'

# 2. Verify OTP
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "otp": "123456"}'

# Save the token from response
TOKEN="your.jwt.token.here"
```

---

## 1. Product Management

### Create Product with Image

```bash
curl -X POST http://localhost:3000/api/admin/products \
  -H "Authorization: Bearer $TOKEN" \
  -F "name=Full Cream Milk" \
  -F "description=Fresh full cream milk" \
  -F "category=Dairy Products" \
  -F "unit=liter" \
  -F "pricePerUnit=60" \
  -F "stock=1000" \
  -F "image=@/path/to/milk-image.jpg"
```

### List All Products

```bash
curl -X GET http://localhost:3000/api/admin/products \
  -H "Authorization: Bearer $TOKEN"
```

### Update Product

```bash
# Update price and image
curl -X PUT http://localhost:3000/api/admin/products/PRODUCT_ID \
  -H "Authorization: Bearer $TOKEN" \
  -F "pricePerUnit=65" \
  -F "image=@/path/to/new-image.jpg"
```

---

## 2. Subscription Management

### View All Customer Subscriptions

```bash
# View all active subscriptions
curl -X GET "http://localhost:3000/api/admin/subscriptions?status=active&page=1&limit=50" \
  -H "Authorization: Bearer $TOKEN"

# View subscriptions for specific customer
curl -X GET "http://localhost:3000/api/admin/subscriptions?customerId=CUSTOMER_UUID" \
  -H "Authorization: Bearer $TOKEN"
```

**Available Filters:**
- `status`: active, paused, cancelled, completed
- `customerId`: UUID of specific customer
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 50, max: 100)

---

## 3. Delivery Management

### List All Delivery Boys

```bash
curl -X GET http://localhost:3000/api/admin/delivery-boys \
  -H "Authorization: Bearer $TOKEN"
```

### List All Areas

```bash
curl -X GET http://localhost:3000/api/admin/areas \
  -H "Authorization: Bearer $TOKEN"
```

### Assign Delivery Boy to Area

```bash
curl -X POST http://localhost:3000/api/admin/areas/assign-delivery-boy \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "areaId": "AREA_UUID",
    "deliveryBoyId": "DELIVERY_BOY_UUID"
  }'
```

### Unassign Delivery Boy from Area

```bash
curl -X POST http://localhost:3000/api/admin/areas/assign-delivery-boy \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "areaId": "AREA_UUID",
    "deliveryBoyId": null
  }'
```

---

## 4. Invoice Generation

### Generate Invoice for One Customer

```bash
# Generate invoice for January 2024
curl -X POST http://localhost:3000/api/admin/invoices/generate-monthly \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "CUSTOMER_UUID",
    "year": 2024,
    "month": 1
  }'
```

### Generate Invoices for All Customers

```bash
# Generate invoices for all customers for January 2024
curl -X POST http://localhost:3000/api/admin/invoices/generate-all-monthly \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2024,
    "month": 1
  }'
```

**Note:** This is a long-running operation. The response will show:
- Total customers processed
- Number of successful generations
- Number of failures with error details

### View Customer Invoices

```bash
# View all invoices for a customer
curl -X GET http://localhost:3000/api/admin/customers/CUSTOMER_UUID/invoices \
  -H "Authorization: Bearer $TOKEN"

# Filter by payment status
curl -X GET "http://localhost:3000/api/admin/customers/CUSTOMER_UUID/invoices?paymentStatus=pending" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 5. Payment Management

### Mark Invoice as Paid

#### Record Full Payment

```bash
# Customer pays full amount
curl -X POST http://localhost:3000/api/admin/invoices/INVOICE_UUID/mark-paid \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "paidAmount": 1860
  }'
```

#### Record Partial Payment

```bash
# Customer pays partial amount
curl -X POST http://localhost:3000/api/admin/invoices/INVOICE_UUID/mark-paid \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "paidAmount": 500
  }'
```

**Payment Status:**
- `pending`: No payment received (paidAmount = 0)
- `partial`: Some payment received (0 < paidAmount < totalAmount)
- `paid`: Fully paid (paidAmount >= totalAmount)

### Carry Forward Dues

When a customer hasn't paid and you want to carry forward dues to next month:

```bash
# Carry forward all pending dues to February 2024
curl -X POST http://localhost:3000/api/admin/invoices/carry-forward-dues \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "CUSTOMER_UUID",
    "year": 2024,
    "month": 2
  }'
```

**What it does:**
1. Finds all pending/partial invoices for the customer
2. Calculates total outstanding amount
3. Creates new invoice for the specified month
4. Adds previous dues to current month's delivery charges
5. Returns detailed breakdown:
   - Previous dues amount
   - Current month amount
   - Total amount (dues + current)

---

## Common Workflows

### Workflow 1: New Product Launch

1. Create product with image
2. Verify product is visible in product list
3. Product is now available for customer subscriptions

### Workflow 2: Monthly Invoice Processing

1. Generate invoices for all customers at month-end
2. Review customer invoices
3. Mark invoices as paid when payment received
4. For unpaid customers, carry forward dues to next month

### Workflow 3: Delivery Boy Assignment

1. View list of areas
2. View list of delivery boys
3. Assign delivery boy to area
4. Verify assignment in area details

### Workflow 4: Subscription Monitoring

1. View all active subscriptions
2. Filter by customer if needed
3. Check estimated monthly amounts
4. Monitor subscription status

---

## Product Images

### Accessing Images

Product images are served as static files:

```
http://localhost:3000/uploads/products/product-1234567890-123456789.jpg
```

The `imageUrl` field in product response contains the relative path:
```json
{
  "imageUrl": "/uploads/products/product-1234567890-123456789.jpg"
}
```

### Image Requirements

- **Formats:** JPEG, PNG, GIF, WebP
- **Max Size:** 5MB
- **Recommended:** 800x800px for best display

---

## Error Handling

### Common Errors

**400 Bad Request**
- Invalid input data
- Validation errors
- Check error message for details

**404 Not Found**
- Customer/Product/Invoice/Area not found
- Verify UUID is correct

**409 Conflict**
- Duplicate product name
- Invoice already exists
- Delivery boy already assigned

**401 Unauthorized**
- Invalid or expired token
- Re-authenticate to get new token

---

## Tips & Best Practices

### Product Management
✅ Use descriptive product names
✅ Add high-quality product images
✅ Set appropriate categories for filtering
✅ Keep stock levels updated

### Invoice Management
✅ Generate invoices at beginning of next month
✅ Review failed generations and retry
✅ Mark payments promptly
✅ Carry forward dues at month-end for unpaid customers

### Subscription Management
✅ Regularly monitor active subscriptions
✅ Check for paused subscriptions that can be resumed
✅ Review estimated monthly amounts for accuracy

### Delivery Management
✅ Assign delivery boys to areas before customers subscribe
✅ Balance customer distribution across delivery boys
✅ Review area assignments regularly

---

## Support

For issues or questions:
1. Check error logs in `backend/logs/error.log`
2. Review API documentation in `API.md`
3. See detailed implementation guide in `ADMIN_FEATURES.md`
4. Verify requirements in `REQUIREMENTS_VERIFICATION.md`

---

## Quick Reference

| Feature | Endpoint | Method |
|---------|----------|--------|
| Create Product | `/api/admin/products` | POST |
| Update Product | `/api/admin/products/:id` | PUT |
| List Products | `/api/admin/products` | GET |
| View Subscriptions | `/api/admin/subscriptions` | GET |
| Assign Delivery Boy | `/api/admin/areas/assign-delivery-boy` | POST |
| Generate Invoice (One) | `/api/admin/invoices/generate-monthly` | POST |
| Generate Invoice (All) | `/api/admin/invoices/generate-all-monthly` | POST |
| View Invoices | `/api/admin/customers/:id/invoices` | GET |
| Mark Paid | `/api/admin/invoices/:id/mark-paid` | POST |
| Carry Forward Dues | `/api/admin/invoices/carry-forward-dues` | POST |

---

**All features are production-ready and fully functional!** 🚀
