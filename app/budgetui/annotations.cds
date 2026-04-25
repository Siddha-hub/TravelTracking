using TravelRequest as service from '../../srv/service';

// =========================================================================
// Tab SelectionVariants for IconTabBar views in combined Budget UI
// All other annotations (LineItem, FieldGroup, ValueList, etc.) are provided
// by budgetmanagerui/annotations.cds and budgetanalyticsui/annotations.cds
// =========================================================================

// Tab 1: Budget Maintenance
annotate service.TravelBudget with @(
    UI.SelectionVariant #BudgetMaintenance: {
        Text         : 'Budget Maintenance',
        SelectOptions: []
    }
);

// Tab 2: Budget Analytics
annotate service.BudgetAnalytics with @(
    UI.SelectionVariant #BudgetAnalytics: {
        Text         : 'Budget Analytics',
        SelectOptions: []
    }
);