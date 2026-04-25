using TravelRequest as service from '../../srv/service';

// ---------- Field-level Annotations ----------
annotate service.TravelRequest with {
    ID              @UI.Hidden;
    name            @mandatory;
    customerName    @mandatory;
    travelFromDate  @mandatory;
    travelToDate    @mandatory;
    expenseAmount   @mandatory  @Measures.ISOCurrency: currency;
    currency        @title: 'Currency';
};

// ---------- Header Info ----------
annotate service.TravelRequest with @(
    UI.HeaderInfo: {
        TypeName       : 'Travel Expense',
        TypeNamePlural : 'Travel Expenses',
        Title          : { $Type: 'UI.DataField', Value: name },
        Description    : { $Type: 'UI.DataField', Value: customerName }
    }
);

// ---------- Selection Fields (Filters) ----------
annotate service.TravelRequest with @(
    UI.SelectionFields: [
        name,
        customerName,
        travelFromDate,
        travelToDate
    ]
);

// ---------- List Report (Table Columns) ----------
annotate service.TravelRequest with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name,           Label: 'Employee Name',     ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: customerName,   Label: 'Customer Name',     ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: travelFromDate, Label: 'Travel From Date',  ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: travelToDate,   Label: 'Travel To Date' },
        { $Type: 'UI.DataField', Value: expenseAmount,  Label: 'Expense Amount' },
        { $Type: 'UI.DataField', Value: currency,       Label: 'Currency' }
    ]
);

// ---------- Object Page: Field Groups ----------
annotate service.TravelRequest with @(
    UI.FieldGroup #GeneralInfo: {
        $Type: 'UI.FieldGroupType',
        Label: 'General Information',
        Data : [
            { $Type: 'UI.DataField', Value: name,         Label: 'Employee Name' },
            { $Type: 'UI.DataField', Value: customerName,  Label: 'Customer Name' }
        ]
    },

    UI.FieldGroup #TravelDates: {
        $Type: 'UI.FieldGroupType',
        Label: 'Travel Dates',
        Data : [
            { $Type: 'UI.DataField', Value: travelFromDate, Label: 'Travel From Date' },
            { $Type: 'UI.DataField', Value: travelToDate,   Label: 'Travel To Date' }
        ]
    },

    UI.FieldGroup #ExpenseDetails: {
        $Type: 'UI.FieldGroupType',
        Label: 'Expense Details',
        Data : [
            { $Type: 'UI.DataField', Value: expenseAmount, Label: 'Expense Amount' },
            { $Type: 'UI.DataField', Value: currency,      Label: 'Currency' }
        ]
    }
);

// ---------- Object Page: Facets (Layout) ----------
annotate service.TravelRequest with @(
    UI.Facets: [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GeneralInfoFacet',
            Label  : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'TravelDatesFacet',
            Label  : 'Travel Dates',
            Target : '@UI.FieldGroup#TravelDates'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'ExpenseDetailsFacet',
            Label  : 'Expense Details',
            Target : '@UI.FieldGroup#ExpenseDetails'
        }
    ]
);