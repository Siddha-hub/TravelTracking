namespace traveltracking;

using { cuid, managed } from '@sap/cds/common';

entity TravelRequest : cuid, managed {
    name            : String(100)   @title: 'Employee Name';
    customerName    : String(150)   @title: 'Customer Name';
    travelFromDate  : Date          @title: 'Travel From Date';
    travelToDate    : Date          @title: 'Travel To Date';
    expenseAmount   : Decimal(15,2) @title: 'Expense Amount';
    currency        : String(3)     @title: 'Currency';
}