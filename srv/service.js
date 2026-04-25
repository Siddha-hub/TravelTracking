const cds = require('@sap/cds');

module.exports = class TravelRequestService extends cds.ApplicationService {
    init() {
        const { TravelRequest, TravelBudget, BudgetAnalytics } = this.entities;

        // --- TravelRequest validations ---
        this.before(['CREATE', 'UPDATE'], TravelRequest, (req) => {
            const { travelFromDate, travelToDate, expenseAmount } = req.data;

            // Always set currency to INR
            req.data.currency = 'INR';

            if (travelFromDate && travelToDate && travelFromDate > travelToDate) {
                req.error(400, 'Travel From Date must be before Travel To Date', 'travelToDate');
            }

            if (expenseAmount !== undefined && expenseAmount !== null && expenseAmount < 0) {
                req.error(400, 'Expense Amount must be a positive value', 'expenseAmount');
            }
        });

        // --- TravelBudget validations ---
        this.before(['CREATE', 'UPDATE'], TravelBudget, (req) => {
            const { budgetAmount } = req.data;

            // Always set currency to INR
            req.data.currency = 'INR';

            if (budgetAmount !== undefined && budgetAmount !== null && budgetAmount < 0) {
                req.error(400, 'Budget Amount must be a positive value', 'budgetAmount');
            }
        });

        // --- BudgetAnalytics: computed read ---
        this.on('READ', BudgetAnalytics, async (req) => {
            const db = cds.db || await cds.connect.to('db');

            // Get all budgets
            const budgets = await db.run(
                SELECT.from('traveltracking.TravelBudget')
                    .columns('ID', 'employee_ID', 'fiscalYear_ID', 'budgetAmount', 'currency')
            );

            // Get all names
            const names = await db.run(
                SELECT.from('traveltracking.Names').columns('ID', 'fullName')
            );
            const nameMap = {};
            for (const n of names) {
                nameMap[n.ID] = n.fullName;
            }

            // Get all fiscal years
            const fiscalYears = await db.run(
                SELECT.from('traveltracking.FiscalYears').columns('ID', 'year')
            );
            const fyMap = {};
            for (const fy of fiscalYears) {
                fyMap[fy.ID] = fy.year;
            }

            // Get all travel requests
            const travelRequests = await db.run(
                SELECT.from('traveltracking.TravelRequest')
                    .columns('name_ID', 'fiscalYear_ID', 'expenseAmount')
            );

            // Aggregate expenses per employee per fiscal year
            const expenseMap = {};
            for (const tr of travelRequests) {
                if (tr.name_ID && tr.fiscalYear_ID && tr.expenseAmount) {
                    const key = `${tr.name_ID}_${tr.fiscalYear_ID}`;
                    expenseMap[key] = (expenseMap[key] || 0) + parseFloat(tr.expenseAmount);
                }
            }

            // Compute analytics
            let results = budgets.map(b => {
                const key = `${b.employee_ID}_${b.fiscalYear_ID}`;
                const budget = parseFloat(b.budgetAmount) || 0;
                const consumed = expenseMap[key] || 0;
                const remaining = budget - consumed;
                const consumedPct = budget > 0 ? ((consumed / budget) * 100) : 0;

                return {
                    ID: b.ID,
                    employeeName: nameMap[b.employee_ID] || 'Unknown',
                    fiscalYear: fyMap[b.fiscalYear_ID] || 'N/A',
                    budgetAmount: budget,
                    consumedAmount: consumed,
                    remainingAmount: remaining,
                    consumedPercent: Math.round(consumedPct * 100) / 100,
                    currency: b.currency || 'INR'
                };
            });

            // Apply $filter from request
            if (req.query.SELECT && req.query.SELECT.where) {
                results = this._applyWhereFilter(results, req.query.SELECT.where);
            }

            // Handle $search
            if (req.query.SELECT && req.query.SELECT.search) {
                const searchTerm = req.query.SELECT.search[0] && req.query.SELECT.search[0].val
                    ? req.query.SELECT.search[0].val.toLowerCase()
                    : (typeof req.query.SELECT.search === 'string' ? req.query.SELECT.search.toLowerCase() : '');
                if (searchTerm) {
                    results = results.filter(r =>
                        (r.employeeName && r.employeeName.toLowerCase().includes(searchTerm)) ||
                        (r.fiscalYear && r.fiscalYear.toLowerCase().includes(searchTerm))
                    );
                }
            }

            // Handle $orderby
            if (req.query.SELECT && req.query.SELECT.orderBy) {
                const orderBy = req.query.SELECT.orderBy;
                results.sort((a, b) => {
                    for (const o of orderBy) {
                        const prop = o.ref ? o.ref[0] : o;
                        const dir = o.sort === 'desc' ? -1 : 1;
                        if (a[prop] < b[prop]) return -1 * dir;
                        if (a[prop] > b[prop]) return 1 * dir;
                    }
                    return 0;
                });
            }

            // Handle $count
            if (req.query.SELECT.count) {
                results.$count = results.length;
            }

            // Handle $top and $skip
            const top = req.query.SELECT.limit && req.query.SELECT.limit.rows && req.query.SELECT.limit.rows.val;
            const skip = req.query.SELECT.limit && req.query.SELECT.limit.offset && req.query.SELECT.limit.offset.val;

            if (skip) {
                results = results.slice(skip);
            }
            if (top) {
                results = results.slice(0, top);
            }

            return results;
        });

        return super.init();
    }

    /**
     * Apply OData $filter (CDS where clause) to in-memory results
     */
    _applyWhereFilter(results, where) {
        return results.filter(row => this._evaluateWhere(row, where));
    }

    _evaluateWhere(row, where) {
        if (!where || where.length === 0) return true;

        let result = true;
        let currentOp = 'and';

        for (let i = 0; i < where.length; i++) {
            const token = where[i];

            // Logical operators
            if (token === 'and' || token === 'or') {
                currentOp = token;
                continue;
            }

            // Nested expression in parentheses (array of arrays)
            if (Array.isArray(token) && !token.ref && !token.val) {
                const nestedResult = this._evaluateWhere(row, token);
                result = currentOp === 'and' ? (result && nestedResult) : (result || nestedResult);
                continue;
            }

            // Comparison: ref op val pattern
            if (token.ref) {
                const field = token.ref[0];
                const op = where[i + 1];
                const valToken = where[i + 2];
                i += 2;

                if (!valToken) continue;
                const val = valToken.val !== undefined ? valToken.val : valToken;
                const rowVal = row[field];

                let compResult = false;
                switch (op) {
                    case '=':
                    case 'eq':
                        compResult = rowVal == val;
                        break;
                    case '!=':
                    case 'ne':
                        compResult = rowVal != val;
                        break;
                    case '>':
                    case 'gt':
                        compResult = rowVal > val;
                        break;
                    case '<':
                    case 'lt':
                        compResult = rowVal < val;
                        break;
                    case '>=':
                    case 'ge':
                        compResult = rowVal >= val;
                        break;
                    case '<=':
                    case 'le':
                        compResult = rowVal <= val;
                        break;
                    case 'like':
                    case 'contains':
                        compResult = rowVal && String(rowVal).toLowerCase().includes(String(val).toLowerCase().replace(/%/g, ''));
                        break;
                    default:
                        compResult = true;
                }

                result = currentOp === 'and' ? (result && compResult) : (result || compResult);
            }
        }

        return result;
    }
};