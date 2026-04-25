using TravelRequest as service from '../../srv/service';

// ---------- Field-level Annotations ----------
annotate service.TravelRequest with {
    ID @UI.Hidden;

    name @(
        Common.Text                     : name.fullName,
        Common.TextArrangement          : #TextOnly,
        Common.ValueListWithFixedValues : true,
        Common.ValueList                : {
            Label          : 'Employee Names',
            CollectionPath : 'Names',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : name_ID,
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

    customerName   @mandatory;
    travelFromDate @mandatory;
    travelToDate   @mandatory;
    expenseAmount  @mandatory @Measures.ISOCurrency: currency;
    currency       @title: 'Currency';
};

// ---------- Names entity: show fullName as text for ID ----------
annotate service.Names with {
    ID       @UI.Hidden  @Common.Text: fullName  @Common.TextArrangement: #TextOnly;
    fullName @title: 'Full Name';
};

// ---------- FiscalYears entity: show year as text for ID ----------
annotate service.FiscalYears with {
    ID   @UI.Hidden  @Common.Text: year  @Common.TextArrangement: #TextOnly;
    year @title: 'Fiscal Year';
};

// ---------- Header Info ----------
annotate service.TravelRequest with @(
    UI.HeaderInfo: {
        TypeName       : 'Travel Expense',
        TypeNamePlural : 'Travel Expenses',
        Title          : { $Type: 'UI.DataField', Value: name.fullName },
        Description    : { $Type: 'UI.DataField', Value: customerName }
    }
);

// ---------- Selection Fields (Filters) ----------
annotate service.TravelRequest with @(
    UI.SelectionFields: [
        name_ID,
        customerName,
        fiscalYear_ID,
        travelFromDate,
        travelToDate
    ]
);

// ---------- List Report (Table Columns) ----------
annotate service.TravelRequest with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name_ID,         Label: 'Employee Name',        ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: customerName,     Label: 'Customer Name',        ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: fiscalYear_ID,    Label: 'Fiscal Year',          ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: travelFromDate,   Label: 'Travel From Date',     ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: travelToDate,     Label: 'Travel To Date' },
        { $Type: 'UI.DataField', Value: expenseAmount,    Label: 'Appx Expense Amount' },
        { $Type: 'UI.DataField', Value: currency,         Label: 'Currency' }
    ]
);

// ---------- Object Page: Field Groups ----------
annotate service.TravelRequest with @(
    UI.FieldGroup #GeneralInfo: {
        $Type: 'UI.FieldGroupType',
        Label: 'General Information',
        Data : [
            { $Type: 'UI.DataField', Value: name_ID,        Label: 'Employee Name' },
            { $Type: 'UI.DataField', Value: customerName,    Label: 'Customer Name' },
            { $Type: 'UI.DataField', Value: fiscalYear_ID,   Label: 'Fiscal Year' }
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
            { $Type: 'UI.DataField', Value: expenseAmount, Label: 'Appx Expense Amount' },
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