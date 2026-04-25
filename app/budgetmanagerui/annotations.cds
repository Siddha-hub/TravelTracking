using TravelRequest as service from '../../srv/service';

// ---------- Field-level Annotations ----------
annotate service.TravelBudget with {
    ID @UI.Hidden;

    employee @(
        Common.Text                     : employee.fullName,
        Common.TextArrangement          : #TextOnly,
        Common.ValueListWithFixedValues : true,
        Common.ValueList                : {
            Label          : 'Employee Names',
            CollectionPath : 'Names',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : employee_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'fullName'
                }
            ]
        }
    );

    fiscalYear @(
        Common.Text                     : fiscalYear.year,
        Common.TextArrangement          : #TextOnly,
        Common.ValueListWithFixedValues : true,
        Common.ValueList                : {
            Label          : 'Fiscal Years',
            CollectionPath : 'FiscalYears',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : fiscalYear_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'year'
                }
            ]
        }
    );

    budgetAmount @mandatory @Measures.ISOCurrency: currency;
    currency     @title: 'Currency';
    remarks      @UI.MultiLineText;
};

// ---------- Header Info ----------
annotate service.TravelBudget with @(
    UI.HeaderInfo: {
        TypeName       : 'Travel Budget',
        TypeNamePlural : 'Travel Budgets',
        Title          : { $Type: 'UI.DataField', Value: employee.fullName },
        Description    : { $Type: 'UI.DataField', Value: fiscalYear.year }
    }
);

// ---------- Selection Fields (Filters) ----------
annotate service.TravelBudget with @(
    UI.SelectionFields: [
        employee_ID,
        fiscalYear_ID
    ]
);

// ---------- List Report (Table Columns) ----------
annotate service.TravelBudget with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: employee_ID,     Label: 'Employee Name',  ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: fiscalYear_ID,    Label: 'Fiscal Year',    ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: budgetAmount,     Label: 'Budget Amount',  ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: currency,         Label: 'Currency' },
        { $Type: 'UI.DataField', Value: remarks,          Label: 'Remarks' }
    ]
);

// ---------- Object Page: Field Groups ----------
annotate service.TravelBudget with @(
    UI.FieldGroup #EmployeeInfo: {
        $Type: 'UI.FieldGroupType',
        Label: 'Employee Information',
        Data : [
            { $Type: 'UI.DataField', Value: employee_ID,   Label: 'Employee Name' },
            { $Type: 'UI.DataField', Value: fiscalYear_ID,  Label: 'Fiscal Year' }
        ]
    },

    UI.FieldGroup #BudgetDetails: {
        $Type: 'UI.FieldGroupType',
        Label: 'Budget Details',
        Data : [
            { $Type: 'UI.DataField', Value: budgetAmount, Label: 'Budget Amount' },
            { $Type: 'UI.DataField', Value: currency,     Label: 'Currency' },
            { $Type: 'UI.DataField', Value: remarks,      Label: 'Remarks' }
        ]
    }
);

// ---------- Object Page: Facets (Layout) ----------
annotate service.TravelBudget with @(
    UI.Facets: [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'EmployeeInfoFacet',
            Label  : 'Employee Information',
            Target : '@UI.FieldGroup#EmployeeInfo'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'BudgetDetailsFacet',
            Label  : 'Budget Details',
            Target : '@UI.FieldGroup#BudgetDetails'
        }
    ]
);