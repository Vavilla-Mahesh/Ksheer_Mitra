const db = require('../config/db');
const logger = require('../utils/logger');
const mapsService = require('../services/maps.service');
const invoiceService = require('../services/invoice.service');
const path = require('path');
const fs = require('fs');

class AdminController {
  async getCustomers(req, res, next) {
    try {
      const { page = 1, limit = 50, search } = req.query;
      const offset = (page - 1) * limit;

      const whereClause = {
        role: 'customer'
      };

      if (search) {
        whereClause[db.Sequelize.Op.or] = [
          { name: { [db.Sequelize.Op.iLike]: `%${search}%` } },
          { phone: { [db.Sequelize.Op.iLike]: `%${search}%` } }
        ];
      }

      const { count, rows } = await db.User.findAndCountAll({
        where: whereClause,
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area',
          include: [{
            model: db.User,
            as: 'deliveryBoy',
            attributes: ['id', 'name', 'phone']
          }]
        }],
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['name', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: {
          customers: rows,
          pagination: {
            total: count,
            page: parseInt(page),
            limit: parseInt(limit),
            totalPages: Math.ceil(count / limit)
          }
        }
      });
    } catch (error) {
      logger.error('Error getting customers:', error);
      next(error);
    }
  }

  async getCustomersWithLocations(req, res, next) {
    try {
      const customers = await db.User.findAll({
        where: {
          role: 'customer',
          latitude: { [db.Sequelize.Op.ne]: null },
          longitude: { [db.Sequelize.Op.ne]: null }
        },
        attributes: ['id', 'name', 'phone', 'address', 'latitude', 'longitude', 'areaId'],
        include: [{
          model: db.Area,
          as: 'area',
          attributes: ['id', 'name']
        }]
      });

      res.status(200).json({
        success: true,
        data: customers
      });
    } catch (error) {
      logger.error('Error getting customers with locations:', error);
      next(error);
    }
  }

  async getDeliveryBoys(req, res, next) {
    try {
      const deliveryBoys = await db.User.findAll({
        where: {
          role: 'delivery_boy',
          isActive: true
        },
        attributes: { exclude: ['passwordHash'] },
        include: [{
          model: db.Area,
          as: 'area',
          foreignKey: 'deliveryBoyId'
        }]
      });

      res.status(200).json({
        success: true,
        data: deliveryBoys
      });
    } catch (error) {
      logger.error('Error getting delivery boys:', error);
      next(error);
    }
  }

  async createDeliveryBoy(req, res, next) {
    try {
      const { name, phone, email, address, latitude, longitude } = req.body;

      const existingUser = await db.User.findOne({ where: { phone } });
      
      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: 'Phone number already registered'
        });
      }

      const deliveryBoy = await db.User.create({
        name,
        phone,
        email,
        address,
        latitude,
        longitude,
        role: 'delivery_boy',
        isActive: true
      });

      res.status(201).json({
        success: true,
        message: 'Delivery boy created successfully',
        data: deliveryBoy
      });
    } catch (error) {
      logger.error('Error creating delivery boy:', error);
      next(error);
    }
  }

  async assignArea(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerId, areaId } = req.body;

      const customer = await db.User.findByPk(customerId, { transaction });
      
      if (!customer || customer.role !== 'customer') {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Customer not found'
        });
      }

      const area = await db.Area.findByPk(areaId, { transaction });
      
      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      await customer.update({ areaId }, { transaction });

      await transaction.commit();

      logger.info(`Assigned customer ${customerId} to area ${areaId}`);

      res.status(200).json({
        success: true,
        message: 'Area assigned successfully',
        data: customer
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error assigning area:', error);
      next(error);
    }
  }

  async bulkAssignArea(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerIds, areaId } = req.body;

      const area = await db.Area.findByPk(areaId, { transaction });
      
      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      await db.User.update(
        { areaId },
        {
          where: {
            id: { [db.Sequelize.Op.in]: customerIds },
            role: 'customer'
          },
          transaction
        }
      );

      await transaction.commit();

      logger.info(`Bulk assigned ${customerIds.length} customers to area ${areaId}`);

      res.status(200).json({
        success: true,
        message: `${customerIds.length} customers assigned successfully`
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error in bulk assign area:', error);
      next(error);
    }
  }

  async getAreas(req, res, next) {
    try {
      const areas = await db.Area.findAll({
        include: [
          {
            model: db.User,
            as: 'deliveryBoy',
            attributes: ['id', 'name', 'phone']
          },
          {
            model: db.User,
            as: 'customers',
            attributes: ['id', 'name', 'phone']
          }
        ],
        order: [['name', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: areas
      });
    } catch (error) {
      logger.error('Error getting areas:', error);
      next(error);
    }
  }

  async createArea(req, res, next) {
    try {
      const { name, description, deliveryBoyId } = req.body;

      const area = await db.Area.create({
        name,
        description,
        deliveryBoyId,
        isActive: true
      });

      res.status(201).json({
        success: true,
        message: 'Area created successfully',
        data: area
      });
    } catch (error) {
      logger.error('Error creating area:', error);
      next(error);
    }
  }

  async updateArea(req, res, next) {
    try {
      const { id } = req.params;
      const { name, description, deliveryBoyId, isActive } = req.body;

      const area = await db.Area.findByPk(id);
      
      if (!area) {
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      const updates = {};
      if (name !== undefined) updates.name = name;
      if (description !== undefined) updates.description = description;
      if (deliveryBoyId !== undefined) updates.deliveryBoyId = deliveryBoyId;
      if (isActive !== undefined) updates.isActive = isActive;

      await area.update(updates);

      res.status(200).json({
        success: true,
        message: 'Area updated successfully',
        data: area
      });
    } catch (error) {
      logger.error('Error updating area:', error);
      next(error);
    }
  }

  async getDailyInvoices(req, res, next) {
    try {
      const { startDate, endDate, deliveryBoyId } = req.query;

      const whereClause = {
        type: 'daily'
      };

      if (startDate && endDate) {
        whereClause.invoiceDate = {
          [db.Sequelize.Op.between]: [startDate, endDate]
        };
      }

      if (deliveryBoyId) {
        whereClause.deliveryBoyId = deliveryBoyId;
      }

      const invoices = await db.Invoice.findAll({
        where: whereClause,
        include: [{
          model: db.User,
          as: 'deliveryBoy',
          attributes: ['id', 'name', 'phone']
        }],
        order: [['invoiceDate', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: invoices
      });
    } catch (error) {
      logger.error('Error getting daily invoices:', error);
      next(error);
    }
  }

  async getProducts(req, res, next) {
    try {
      const products = await db.Product.findAll({
        order: [['name', 'ASC']]
      });

      res.status(200).json({
        success: true,
        data: products
      });
    } catch (error) {
      logger.error('Error getting products:', error);
      next(error);
    }
  }

  async createProduct(req, res, next) {
    try {
      const { name, description, category, unit, pricePerUnit, stock } = req.body;
      
      let imageUrl = null;
      if (req.file) {
        imageUrl = `/uploads/products/${req.file.filename}`;
      }

      const product = await db.Product.create({
        name,
        description,
        category,
        unit,
        pricePerUnit,
        stock: stock || 0,
        imageUrl,
        isActive: true
      });

      res.status(201).json({
        success: true,
        message: 'Product created successfully',
        data: product
      });
    } catch (error) {
      if (req.file) {
        const filePath = path.join(__dirname, '../../uploads/products', req.file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
      logger.error('Error creating product:', error);
      next(error);
    }
  }

  async updateProduct(req, res, next) {
    try {
      const { id } = req.params;
      const { name, description, category, unit, pricePerUnit, stock, isActive } = req.body;

      const product = await db.Product.findByPk(id);
      
      if (!product) {
        if (req.file) {
          const filePath = path.join(__dirname, '../../uploads/products', req.file.filename);
          if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
          }
        }
        return res.status(404).json({
          success: false,
          message: 'Product not found'
        });
      }

      const updates = {};
      if (name !== undefined) updates.name = name;
      if (description !== undefined) updates.description = description;
      if (category !== undefined) updates.category = category;
      if (unit !== undefined) updates.unit = unit;
      if (pricePerUnit !== undefined) updates.pricePerUnit = pricePerUnit;
      if (stock !== undefined) updates.stock = stock;
      if (isActive !== undefined) updates.isActive = isActive;
      
      if (req.file) {
        if (product.imageUrl) {
          const oldImagePath = path.join(__dirname, '../..', product.imageUrl);
          if (fs.existsSync(oldImagePath)) {
            fs.unlinkSync(oldImagePath);
          }
        }
        updates.imageUrl = `/uploads/products/${req.file.filename}`;
      }

      await product.update(updates);

      res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        data: product
      });
    } catch (error) {
      if (req.file) {
        const filePath = path.join(__dirname, '../../uploads/products', req.file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
      logger.error('Error updating product:', error);
      next(error);
    }
  }

  async getAllSubscriptions(req, res, next) {
    try {
      const { page = 1, limit = 50, status, customerId } = req.query;
      const offset = (page - 1) * limit;

      const whereClause = {};
      
      if (status) {
        whereClause.status = status;
      }
      
      if (customerId) {
        whereClause.customerId = customerId;
      }

      const { count, rows } = await db.Subscription.findAndCountAll({
        where: whereClause,
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone', 'email', 'address']
          },
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit', 'pricePerUnit', 'category', 'imageUrl']
          }
        ],
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['createdAt', 'DESC']]
      });

      const subscriptionsWithDetails = rows.map(subscription => {
        const pricePerUnit = parseFloat(subscription.product.pricePerUnit);
        const quantity = parseFloat(subscription.quantity);
        const estimatedMonthlyAmount = pricePerUnit * quantity * 30;

        return {
          id: subscription.id,
          customer: subscription.customer,
          product: subscription.product,
          quantity: subscription.quantity,
          frequency: subscription.frequency,
          selectedDays: subscription.selectedDays,
          startDate: subscription.startDate,
          endDate: subscription.endDate,
          status: subscription.status,
          pauseStartDate: subscription.pauseStartDate,
          pauseEndDate: subscription.pauseEndDate,
          estimatedMonthlyAmount,
          createdAt: subscription.createdAt,
          updatedAt: subscription.updatedAt
        };
      });

      res.status(200).json({
        success: true,
        data: {
          subscriptions: subscriptionsWithDetails,
          pagination: {
            total: count,
            page: parseInt(page),
            limit: parseInt(limit),
            totalPages: Math.ceil(count / limit)
          }
        }
      });
    } catch (error) {
      logger.error('Error getting all subscriptions:', error);
      next(error);
    }
  }

  async generateCustomerMonthlyInvoice(req, res, next) {
    try {
      const { customerId, year, month } = req.body;

      const customer = await db.User.findByPk(customerId);
      
      if (!customer || customer.role !== 'customer') {
        return res.status(404).json({
          success: false,
          message: 'Customer not found'
        });
      }

      const invoice = await invoiceService.generateMonthlyInvoice(customerId, year, month);

      if (!invoice) {
        return res.status(400).json({
          success: false,
          message: 'No deliveries found for the specified period'
        });
      }

      res.status(200).json({
        success: true,
        message: 'Monthly invoice generated successfully',
        data: invoice
      });
    } catch (error) {
      logger.error('Error generating customer monthly invoice:', error);
      next(error);
    }
  }

  async generateAllMonthlyInvoices(req, res, next) {
    try {
      const { year, month } = req.body;

      const customers = await db.User.findAll({
        where: {
          role: 'customer',
          isActive: true
        }
      });

      const results = {
        total: customers.length,
        generated: 0,
        failed: 0,
        errors: []
      };

      for (const customer of customers) {
        try {
          const invoice = await invoiceService.generateMonthlyInvoice(customer.id, year, month);
          if (invoice) {
            results.generated++;
          }
          
          await new Promise(resolve => setTimeout(resolve, 2000));
        } catch (error) {
          results.failed++;
          results.errors.push({
            customerId: customer.id,
            customerName: customer.name,
            error: error.message
          });
          logger.error(`Error generating invoice for customer ${customer.id}:`, error);
        }
      }

      res.status(200).json({
        success: true,
        message: 'Monthly invoice generation completed',
        data: results
      });
    } catch (error) {
      logger.error('Error generating all monthly invoices:', error);
      next(error);
    }
  }

  async getCustomerInvoices(req, res, next) {
    try {
      const { customerId } = req.params;
      const { type, paymentStatus } = req.query;

      const whereClause = { customerId };
      
      if (type) {
        whereClause.type = type;
      }
      
      if (paymentStatus) {
        whereClause.paymentStatus = paymentStatus;
      }

      const invoices = await db.Invoice.findAll({
        where: whereClause,
        include: [
          {
            model: db.User,
            as: 'customer',
            attributes: ['id', 'name', 'phone', 'email', 'address']
          }
        ],
        order: [['invoiceDate', 'DESC']]
      });

      res.status(200).json({
        success: true,
        data: invoices
      });
    } catch (error) {
      logger.error('Error getting customer invoices:', error);
      next(error);
    }
  }

  async markInvoiceAsPaid(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { invoiceId } = req.params;
      const { paidAmount } = req.body;

      const invoice = await db.Invoice.findByPk(invoiceId, { transaction });
      
      if (!invoice) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Invoice not found'
        });
      }

      const newPaidAmount = parseFloat(invoice.paidAmount) + parseFloat(paidAmount);
      const totalAmount = parseFloat(invoice.totalAmount);

      let paymentStatus = 'pending';
      if (newPaidAmount >= totalAmount) {
        paymentStatus = 'paid';
      } else if (newPaidAmount > 0) {
        paymentStatus = 'partial';
      }

      await invoice.update({
        paidAmount: newPaidAmount,
        paymentStatus
      }, { transaction });

      await transaction.commit();

      logger.info(`Payment marked for invoice ${invoiceId}: paid ${paidAmount}`);

      res.status(200).json({
        success: true,
        message: 'Payment recorded successfully',
        data: invoice
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error marking invoice as paid:', error);
      next(error);
    }
  }

  async carryForwardDues(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { customerId, year, month } = req.body;

      const customer = await db.User.findByPk(customerId, { transaction });
      
      if (!customer || customer.role !== 'customer') {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Customer not found'
        });
      }

      const previousInvoices = await db.Invoice.findAll({
        where: {
          customerId,
          type: 'monthly',
          paymentStatus: {
            [db.Sequelize.Op.in]: ['pending', 'partial']
          }
        },
        order: [['invoiceDate', 'ASC']],
        transaction
      });

      const totalDue = previousInvoices.reduce((sum, inv) => {
        return sum + (parseFloat(inv.totalAmount) - parseFloat(inv.paidAmount));
      }, 0);

      if (totalDue === 0) {
        await transaction.rollback();
        return res.status(400).json({
          success: false,
          message: 'No pending dues to carry forward'
        });
      }

      const periodStart = `${year}-${month.toString().padStart(2, '0')}-01`;
      const moment = require('moment');
      const periodEnd = moment(periodStart).endOf('month').format('YYYY-MM-DD');

      const deliveries = await db.Delivery.findAll({
        where: {
          customerId,
          deliveryDate: {
            [db.Sequelize.Op.between]: [periodStart, periodEnd]
          },
          status: 'delivered'
        },
        include: [
          {
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit']
          }
        ],
        order: [['deliveryDate', 'ASC']],
        transaction
      });

      const currentMonthAmount = deliveries.reduce((sum, d) => sum + parseFloat(d.amount), 0);
      const totalAmountWithDues = currentMonthAmount + totalDue;

      const invoiceNumber = `INV-M-${year}${month.toString().padStart(2, '0')}-${customerId.substring(0, 8)}`;

      const existingInvoice = await db.Invoice.findOne({
        where: { invoiceNumber },
        transaction
      });

      if (existingInvoice) {
        await transaction.rollback();
        return res.status(409).json({
          success: false,
          message: 'Invoice already exists for this period'
        });
      }

      const deliveryDetails = deliveries.map(d => ({
        date: moment(d.deliveryDate).format('DD-MM-YYYY'),
        productName: d.product.name,
        quantity: d.quantity,
        unit: d.product.unit,
        amount: d.amount
      }));

      const invoice = await db.Invoice.create({
        invoiceNumber,
        customerId,
        type: 'monthly',
        invoiceDate: moment().format('YYYY-MM-DD'),
        periodStart,
        periodEnd,
        totalAmount: totalAmountWithDues,
        paidAmount: 0,
        paymentStatus: 'pending',
        deliveryDetails: {
          deliveries: deliveryDetails,
          currentMonthAmount,
          previousDues: totalDue,
          totalAmount: totalAmountWithDues
        }
      }, { transaction });

      await transaction.commit();

      logger.info(`Carried forward dues for customer ${customerId}: ₹${totalDue}`);

      res.status(200).json({
        success: true,
        message: 'Dues carried forward successfully',
        data: {
          invoice,
          previousDues: totalDue,
          currentMonthAmount,
          totalAmount: totalAmountWithDues
        }
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error carrying forward dues:', error);
      next(error);
    }
  }

  async assignDeliveryBoyToArea(req, res, next) {
    const transaction = await db.sequelize.transaction();
    
    try {
      const { areaId, deliveryBoyId } = req.body;

      const area = await db.Area.findByPk(areaId, { transaction });
      
      if (!area) {
        await transaction.rollback();
        return res.status(404).json({
          success: false,
          message: 'Area not found'
        });
      }

      if (deliveryBoyId) {
        const deliveryBoy = await db.User.findByPk(deliveryBoyId, { transaction });
        
        if (!deliveryBoy || deliveryBoy.role !== 'delivery_boy') {
          await transaction.rollback();
          return res.status(404).json({
            success: false,
            message: 'Delivery boy not found'
          });
        }

        const existingAssignment = await db.Area.findOne({
          where: {
            deliveryBoyId,
            id: { [db.Sequelize.Op.ne]: areaId }
          },
          transaction
        });

        if (existingAssignment) {
          await transaction.rollback();
          return res.status(409).json({
            success: false,
            message: 'Delivery boy is already assigned to another area'
          });
        }
      }

      await area.update({ deliveryBoyId }, { transaction });

      await transaction.commit();

      logger.info(`Assigned delivery boy ${deliveryBoyId} to area ${areaId}`);

      res.status(200).json({
        success: true,
        message: 'Delivery boy assigned to area successfully',
        data: area
      });
    } catch (error) {
      await transaction.rollback();
      logger.error('Error assigning delivery boy to area:', error);
      next(error);
    }
  }
}

module.exports = new AdminController();
