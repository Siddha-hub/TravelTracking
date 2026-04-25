using { traveltracking as tt } from '../db/schema';

service TravelRequest @(path: '/service/TravelRequest') {
    entity TravelRequest as projection on tt.TravelRequest;
    entity TravelBudget as projection on tt.TravelBudget;
    @readonly entity Names as projection on tt.Names;
    @readonly entity FiscalYears as projection on tt.FiscalYears;

    @readonly entity BudgetAnalytics {
        key ID            : UUID          @title: 'ID';
            employeeName  : String(200)   @title: 'Employee Name';
            fiscalYear    : String(4)     @title: 'Fiscal Year';
            budgetAmount  : Decimal(15,2) @title: 'Total Budget';
            consumedAmount: Decimal(15,2) @title: 'Consumed Amount';
            remainingAmount: Decimal(15,2)@title: 'Remaining Budget';
            consumedPercent: Decimal(5,2) @title: 'Consumed %';
            currency      : String(3)     @title: 'Currency';
    };

    annotate TravelRequest with @odata.draft.enabled;
    annotate TravelBudget with @odata.draft.enabled;
}