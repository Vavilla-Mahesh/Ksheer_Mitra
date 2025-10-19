const authService = require('../services/auth.service');
const logger = require('../utils/logger');

class AuthController {
  async sendOTP(req, res, next) {
    try {
      const { phone } = req.body;
      const ipAddress = req.ip || req.connection.remoteAddress;

      const result = await authService.sendOTP(phone, ipAddress);

      res.status(200).json(result);
    } catch (error) {
      logger.error('Error in sendOTP controller:', error);
      next(error);
    }
  }

  async verifyOTP(req, res, next) {
    try {
      const { phone, otp } = req.body;
      const ipAddress = req.ip || req.connection.remoteAddress;

      const result = await authService.verifyOTP(phone, otp, ipAddress);

      res.status(200).json(result);
    } catch (error) {
      logger.error('Error in verifyOTP controller:', error);
      next(error);
    }
  }

  async refreshToken(req, res, next) {
    try {
      const { refreshToken } = req.body;

      const result = await authService.refreshAccessToken(refreshToken);

      res.status(200).json(result);
    } catch (error) {
      logger.error('Error in refreshToken controller:', error);
      next(error);
    }
  }

  async logout(req, res, next) {
    try {
      res.status(200).json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      logger.error('Error in logout controller:', error);
      next(error);
    }
  }
}

module.exports = new AuthController();
