const express = require('express');
const router = express.Router();
const { body, param, query } = require('express-validator');
const adminController = require('../controllers/admin.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');
const { upload, handleUploadError } = require('../middleware/upload.middleware');

router.use(authenticate);
router.use(authorize('admin'));

router.get('/customers', adminController.getCustomers);

router.get('/customers/map', adminController.getCustomersWithLocations);

router.get('/delivery-boys', adminController.getDeliveryBoys);

router.post(
  '/delivery-boys',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('phone').notEmpty().matches(/^\+?[1-9]\d{1,14}$/).withMessage('Invalid phone number format'),
    body('email').optional().isEmail().withMessage('Invalid email format'),
    body('address').optional().isString(),
    body('latitude').optional().isDecimal().withMessage('Invalid latitude'),
    body('longitude').optional().isDecimal().withMessage('Invalid longitude'),
    validate
  ],
  adminController.createDeliveryBoy
);

router.post(
  '/assign-area',
  [
    body('customerId').notEmpty().isUUID().withMessage('Valid customer ID is required'),
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    validate
  ],
  adminController.assignArea
);

router.post(
  '/bulk-assign-area',
  [
    body('customerIds').notEmpty().isArray({ min: 1 }).withMessage('Customer IDs must be a non-empty array'),
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    validate
  ],
  adminController.bulkAssignArea
);

router.get('/areas', adminController.getAreas);

router.post(
  '/areas',
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('deliveryBoyId').optional().isUUID().withMessage('Invalid delivery boy ID'),
    validate
  ],
  adminController.createArea
);

router.put(
  '/areas/:id',
  [
    param('id').isUUID().withMessage('Invalid area ID'),
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('deliveryBoyId').optional().isUUID().withMessage('Invalid delivery boy ID'),
    body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
    validate
  ],
  adminController.updateArea
);

router.get('/invoices/daily', adminController.getDailyInvoices);

router.get('/products', adminController.getProducts);

router.post(
  '/products',
  upload.single('image'),
  handleUploadError,
  [
    body('name').notEmpty().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('category').optional().isLength({ min: 2, max: 100 }).withMessage('Category must be between 2 and 100 characters'),
    body('unit').notEmpty().isIn(['liter', 'ml', 'kg', 'gm', 'piece']).withMessage('Invalid unit'),
    body('pricePerUnit').notEmpty().isFloat({ min: 0 }).withMessage('Price per unit must be greater than 0'),
    body('stock').optional().isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
    validate
  ],
  adminController.createProduct
);

router.put(
  '/products/:id',
  upload.single('image'),
  handleUploadError,
  [
    param('id').isUUID().withMessage('Invalid product ID'),
    body('name').optional().isLength({ min: 2, max: 100 }).withMessage('Name must be between 2 and 100 characters'),
    body('description').optional().isString(),
    body('category').optional().isLength({ min: 2, max: 100 }).withMessage('Category must be between 2 and 100 characters'),
    body('unit').optional().isIn(['liter', 'ml', 'kg', 'gm', 'piece']).withMessage('Invalid unit'),
    body('pricePerUnit').optional().isFloat({ min: 0 }).withMessage('Price per unit must be greater than 0'),
    body('stock').optional().isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
    body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
    validate
  ],
  adminController.updateProduct
);

router.get(
  '/subscriptions',
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
    query('status').optional().isIn(['active', 'paused', 'cancelled', 'completed']).withMessage('Invalid status'),
    query('customerId').optional().isUUID().withMessage('Invalid customer ID'),
    validate
  ],
  adminController.getAllSubscriptions
);

router.post(
  '/invoices/generate-monthly',
  [
    body('customerId').notEmpty().isUUID().withMessage('Valid customer ID is required'),
    body('year').notEmpty().isInt({ min: 2020, max: 2100 }).withMessage('Valid year is required'),
    body('month').notEmpty().isInt({ min: 1, max: 12 }).withMessage('Valid month (1-12) is required'),
    validate
  ],
  adminController.generateCustomerMonthlyInvoice
);

router.post(
  '/invoices/generate-all-monthly',
  [
    body('year').notEmpty().isInt({ min: 2020, max: 2100 }).withMessage('Valid year is required'),
    body('month').notEmpty().isInt({ min: 1, max: 12 }).withMessage('Valid month (1-12) is required'),
    validate
  ],
  adminController.generateAllMonthlyInvoices
);

router.get(
  '/customers/:customerId/invoices',
  [
    param('customerId').isUUID().withMessage('Invalid customer ID'),
    query('type').optional().isIn(['daily', 'monthly']).withMessage('Invalid invoice type'),
    query('paymentStatus').optional().isIn(['pending', 'partial', 'paid']).withMessage('Invalid payment status'),
    validate
  ],
  adminController.getCustomerInvoices
);

router.post(
  '/invoices/:invoiceId/mark-paid',
  [
    param('invoiceId').isUUID().withMessage('Invalid invoice ID'),
    body('paidAmount').notEmpty().isFloat({ min: 0 }).withMessage('Paid amount must be a positive number'),
    validate
  ],
  adminController.markInvoiceAsPaid
);

router.post(
  '/invoices/carry-forward-dues',
  [
    body('customerId').notEmpty().isUUID().withMessage('Valid customer ID is required'),
    body('year').notEmpty().isInt({ min: 2020, max: 2100 }).withMessage('Valid year is required'),
    body('month').notEmpty().isInt({ min: 1, max: 12 }).withMessage('Valid month (1-12) is required'),
    validate
  ],
  adminController.carryForwardDues
);

router.post(
  '/areas/assign-delivery-boy',
  [
    body('areaId').notEmpty().isUUID().withMessage('Valid area ID is required'),
    body('deliveryBoyId').optional().isUUID().withMessage('Invalid delivery boy ID'),
    validate
  ],
  adminController.assignDeliveryBoyToArea
);

module.exports = router;
