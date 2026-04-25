namespace traveltracking;

using { cuid, managed } from '@sap/cds/common';

entity Names : cuid {
    fullName : String(200) @title: 'Full Name';
}


entity FiscalYears : cuid {
    year : String(4) @title: 'Fiscal Year';
}

entity TravelRequest : cuid, managed {
    name            : Association to Names       @title: 'Employee Name';
    customerName    : String(150)                @title: 'Customer Name';
    fiscalYear      : Association to FiscalYears @title: 'Fiscal Year';
    travelFromDate  : Date                       @title: 'Travel From Date';
    travelToDate    : Date                       @title: 'Travel To Date';
    expenseAmount   : Decimal(15,2)              @title: 'Appx Expense Amount';
    currency        : String(3) default 'INR'    @title: 'Currency'  @readonly;
}

entity TravelBudget : cuid, managed {
    employee        : Association to Names       @title: 'Employee Name';
    fiscalYear      : Association to FiscalYears @title: 'Fiscal Year';
    budgetAmount    : Decimal(15,2)              @title: 'Budget Amount';
    currency        : String(3) default 'INR'    @title: 'Currency'  @readonly;
    remarks         : String(500)                @title: 'Remarks';
}