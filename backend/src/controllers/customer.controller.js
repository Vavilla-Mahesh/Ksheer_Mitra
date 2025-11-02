const subscriptionService = require('../services/subscription.service');
const deliveryService = require('../services/delivery.service');
const invoiceService = require('../services/invoice.service');
const db = require('../config/db');
const logger = require('../utils/logger');

class CustomerController {
  async getProfile(req, res, next) {
    try {
      const userId = req.user.id;

      const user = await db.User.findByPk(userId, {
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area'
        }]
      });

      res.status(200).json({
        success: true,
        data: user
      });
    } catch (error) {
      logger.error('Error getting profile:', error);
      next(error);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const userId = req.user.id;
      const { name, email, address, latitude, longitude } = req.body;

      const user = await db.User.findByPk(userId);
      
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found'
        });
      }

      const updates = {};
      if (name !== undefined) updates.name = name;
      if (email !== undefined) updates.email = email;
      if (address !== undefined) updates.address = address;
      if (latitude !== undefined) updates.latitude = latitude;
      if (longitude !== undefined) updates.longitude = longitude;

      await user.update(updates);

      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: user
      });
    } catch (error) {
      logger.error('Error updating profile:', error);
      next(error);
    }
  }

  async createSubscription(req, res, next) {
    try {
      const customerId = req.user.id;
      const subscriptionData = {
        customerId,
        ...req.body
      };

      const subscription = await subscriptionService.createSubscription(subscriptionData);

      res.status(201).json({
        success: true,
        message: 'Subscription created successfully',
        data: subscription
      });
    } catch (error) {
      logger.error('Error creating subscription:', error);
      next(error);
    }
  }

  async getSubscriptions(req, res, next) {
    try {
      const customerId = req.user.id;

      const subscriptions = await subscriptionService.getActiveSubscriptions(customerId);

      res.status(200).json({
        success: true,
        data: subscriptions
      });
    } catch (error) {
      logger.error('Error getting subscriptions:', error);
      next(error);
    }
  }

  async updateSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);
      
      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const updatedSubscription = await subscriptionService.updateSubscription(id, req.body);

      res.status(200).json({
        success: true,
        message: 'Subscription updated successfully',
        data: updatedSubscription
      });
    } catch (error) {
      logger.error('Error updating subscription:', error);
      next(error);
    }
  }

  async pauseSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;
      const { pauseStartDate, pauseEndDate } = req.body;

      const subscription = await db.Subscription.findByPk(id);
      
      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const pausedSubscription = await subscriptionService.pauseSubscription(id, pauseStartDate, pauseEndDate);

      res.status(200).json({
        success: true,
        message: 'Subscription paused successfully',
        data: pausedSubscription
      });
    } catch (error) {
      logger.error('Error pausing subscription:', error);
      next(error);
    }
  }

  async resumeSubscription(req, res, next) {
    try {
      const { id } = req.params;
      const customerId = req.user.id;

      const subscription = await db.Subscription.findByPk(id);
      
      if (!subscription) {
        return res.status(404).json({
          success: false,
          message: 'Subscription not found'
        });
      }

      if (subscription.customerId !== customerId) {
        return res.status(403).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const resumedSubscription = await subscriptionService.resumeSubscription(id);

      res.status(200).json({
        success: true,
        message: 'Subscription resumed successfully',
        data: resumedSubscription
      });
    } catch (error) {
      logger.error('Error resuming subscription:', error);
      next(error);
    }
  }

  async getDeliveryHistory(req, res, next) {
    try {
      const customerId = req.user.id;
      const { startDate, endDate } = req.query;

      const deliveries = await deliveryService.getCustomerDeliveryHistory(customerId, startDate, endDate);

      res.status(200).json({
        success: true,
        data: deliveries
      });
    } catch (error) {
      logger.error('Error getting delivery history:', error);
      next(error);
    }
  }

  async getInvoices(req, res, next) {
    try {
      const customerId = req.user.id;

      const invoices = await invoiceService.getCustomerInvoices(customerId);

      res.status(200).json({
        success: true,
        data: invoices
      });
    } catch (error) {
      logger.error('Error getting invoices:', error);
      next(error);
    }
  }

  async getMonthlyBreakdown(req, res, next) {
    try {
      const customerId = req.user.id;
      const { year, month } = req.query;
      
      const currentDate = new Date();
      const targetYear = year ? parseInt(year) : currentDate.getFullYear();
      const targetMonth = month ? parseInt(month) : currentDate.getMonth() + 1;

      const moment = require('moment');
      const periodStart = moment({ year: targetYear, month: targetMonth - 1, day: 1 }).format('YYYY-MM-DD');
      const periodEnd = moment(periodStart).endOf('month').format('YYYY-MM-DD');

      // Get all deliveries for the month (both delivered and pending)
      const deliveries = await db.Delivery.findAll({
        where: {
          customerId,
          deliveryDate: {
            [db.Sequelize.Op.between]: [periodStart, periodEnd]
          },
          status: {
            [db.Sequelize.Op.in]: ['delivered', 'pending']
          }
        },
        include: [
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit', 'pricePerUnit']
          }
        ],
        order: [['deliveryDate', 'ASC']]
      });

      const breakdown = {
        year: targetYear,
        month: targetMonth,
        periodStart,
        periodEnd,
        deliveredAmount: 0,
        pendingAmount: 0,
        totalAmount: 0,
        deliveredCount: 0,
        pendingCount: 0,
        deliveries: []
      };

      deliveries.forEach(delivery => {
        const amount = parseFloat(delivery.amount);
        breakdown.deliveries.push({
          date: delivery.deliveryDate,
          productName: delivery.product.name,
          quantity: delivery.quantity,
          unit: delivery.product.unit,
          amount: amount,
          status: delivery.status
        });

        if (delivery.status === 'delivered') {
          breakdown.deliveredAmount += amount;
          breakdown.deliveredCount++;
        } else if (delivery.status === 'pending') {
          breakdown.pendingAmount += amount;
          breakdown.pendingCount++;
        }
      });

      breakdown.totalAmount = breakdown.deliveredAmount + breakdown.pendingAmount;

      res.status(200).json({
        success: true,
        data: breakdown
      });
    } catch (error) {
      logger.error('Error getting monthly breakdown:', error);
      next(error);
    }
  }
}

module.exports = new CustomerController();
