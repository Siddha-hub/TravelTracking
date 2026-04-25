const cds = require('@sap/cds');

module.exports = class TravelRequestService extends cds.ApplicationService {
    init() {
        const { TravelRequest } = this.entities;

        this.before(['CREATE', 'UPDATE'], TravelRequest, (req) => {
            const { travelFromDate, travelToDate, expenseAmount } = req.data;

            if (travelFromDate && travelToDate && travelFromDate > travelToDate) {
                req.error(400, 'Travel From Date must be before Travel To Date', 'travelToDate');
            }

            if (expenseAmount !== undefined && expenseAmount !== null && expenseAmount < 0) {
                req.error(400, 'Expense Amount must be a positive value', 'expenseAmount');
            }
        });

        return super.init();
    }
};