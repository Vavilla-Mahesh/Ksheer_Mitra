# Ksheermitra - Smart Milk Delivery System

A comprehensive milk delivery management system that automates daily operations including customer subscriptions, delivery tracking, WhatsApp notifications, and automated invoicing.

## Features

### Core Functionality
- **WhatsApp OTP Authentication** - Passwordless authentication for all users
- **Subscription Management** - Flexible scheduling (daily, weekly, monthly, custom)
- **Delivery Tracking** - Real-time status updates with customer notifications
- **Route Optimization** - Google Maps integration for optimal delivery routes
- **Automated Invoicing** - Daily invoices for delivery boys, monthly for customers
- **Role-Based Access** - Admin, Customer, and Delivery Boy interfaces

### User Roles

#### Admin
- Manage products, customers, and delivery boys
- Assign delivery areas to delivery boys
- View all customers on an interactive map
- Receive daily delivery invoices via WhatsApp
- Send monthly invoices to customers
- Monitor delivery operations

#### Customer
- Register/login using WhatsApp OTP
- Create and manage milk subscriptions
- View delivery history
- Receive WhatsApp notifications for deliveries
- Access monthly invoices

#### Delivery Boy
- Login via WhatsApp OTP
- View assigned customers and optimized routes
- Mark deliveries as delivered or missed
- Automatic customer notifications on status update
- Generate daily invoice summaries

## Tech Stack

### Backend
- **Framework**: Node.js + Express.js
- **Database**: PostgreSQL with Sequelize ORM
- **Messaging**: WhatsApp automation using `whatsapp-web.js`
- **Maps**: Google Maps API (Geocoding + Directions)
- **PDF**: pdfkit for invoice generation
- **Scheduling**: node-cron for automated tasks
- **Security**: JWT authentication, bcrypt, helmet, rate limiting

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: dio
- **Maps**: google_maps_flutter
- **Local Storage**: shared_preferences

## Project Structure

```
Ksheer_Mitra/
├── backend/
│   ├── src/
│   │   ├── config/         # Database and app configuration
│   │   ├── models/         # Sequelize models
│   │   ├── controllers/    # Request handlers
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic services
│   │   ├── middleware/     # Auth, validation, error handling
│   │   └── utils/          # Utility functions
│   ├── logs/               # Application logs
│   ├── invoices/           # Generated PDF invoices
│   └── package.json
│
└── frontend/
    ├── lib/
    │   ├── config/         # App configuration
    │   ├── models/         # Data models
    │   ├── screens/        # UI screens
    │   ├── providers/      # State management
    │   ├── services/       # API services
    │   └── widgets/        # Reusable widgets
    └── pubspec.yaml
```

## Installation & Setup

### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Configure environment variables:
   - Database credentials (PostgreSQL)
   - JWT secrets
   - Google Maps API key
   - Company information

5. Create database:
```bash
createdb ksheermitra
```

6. Start the server:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

7. On first run, scan the WhatsApp QR code in the console to authenticate

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API configuration in `lib/config/app_config.dart`

4. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run

# For Web
flutter run -d chrome
```

## API Documentation

See [backend/README.md](backend/README.md) for detailed API documentation.

## WhatsApp Integration

The system uses WhatsApp for:
1. **OTP Delivery** - Passwordless authentication
2. **Delivery Notifications** - Delivered/missed status updates
3. **Invoice Delivery** - PDF invoices sent to customers and admin

### Setup
1. Install WhatsApp on your phone
2. Run the backend server
3. Scan the QR code displayed in console
4. WhatsApp session will be saved for future use

## Automated Tasks

### Monthly Invoice Generation
- **Schedule**: 1st of every month at 7:00 AM
- **Action**: Generates invoices for all customers
- **Delivery**: Sent via WhatsApp
- **Configuration**: `MONTHLY_INVOICE_CRON` in .env

## Database Schema

### Main Tables
- **Users** - Admin, customers, delivery boys
- **Products** - Milk products and pricing
- **Areas** - Delivery zones
- **Subscriptions** - Customer subscriptions
- **Deliveries** - Daily delivery records
- **Invoices** - Daily and monthly invoices
- **OTPLogs** - OTP verification tracking

## Security Features

- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting on all endpoints
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- CORS configuration
- Environment variable protection

## Production Deployment

### Backend
1. Set `NODE_ENV=production`
2. Configure production database
3. Set strong JWT secrets
4. Enable SSL for database if required
5. Configure WhatsApp session persistence
6. Set up process manager (PM2)
7. Configure reverse proxy (Nginx)

### Frontend
1. Build for production: `flutter build apk` or `flutter build ios`
2. Update API base URL to production
3. Configure Google Maps API key
4. Sign the app for release

## Monitoring & Logs

- Application logs: `backend/logs/`
- Error logs: `backend/logs/error.log`
- Combined logs: `backend/logs/combined.log`
- WhatsApp session: `backend/whatsapp-session/`

## Support

For issues and questions:
- Check logs in `backend/logs/`
- Verify environment variables
- Ensure database is running
- Check WhatsApp connection status: `/health` endpoint

## License

ISC

## Contributors

Built for Ksheermitra - Smart Milk Delivery System