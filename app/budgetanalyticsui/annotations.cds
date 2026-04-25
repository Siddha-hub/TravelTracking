using TravelRequest as service from '../../srv/service';

// ---------- Aggregation Support ----------
annotate service.BudgetAnalytics with @(
    Aggregation.ApplySupported: {
        Transformations       : ['aggregate', 'topcount', 'bottomcount', 'identity', 'concat', 'groupby', 'filter', 'expand', 'search'],
        GroupableProperties   : [employeeName, fiscalYear],
        AggregatableProperties: [
            { Property: budgetAmount    },
            { Property: consumedAmount  },
            { Property: remainingAmount },
            { Property: consumedPercent }
        ]
    }
);

// ---------- Field-level Annotations ----------
annotate service.BudgetAnalytics with {
    ID              @UI.Hidden;
    employeeName    @title: 'Employee Name'
                    @(Common: {
                        ValueList: {
                            Label: 'Employee Names',
                            CollectionPath: 'Names',
                            Parameters: [
                                {
                                    $Type: 'Common.ValueListParameterInOut',
                                    LocalDataProperty: employeeName,
                                    ValueListProperty: 'fullName'
                                }
                            ]
                        },
                        ValueListWithFixedValues: true
                    })
                    @Analytics.Dimension;
    fiscalYear      @title: 'Fiscal Year'
                    @(Common: {
                        ValueList: {
                            Label: 'Fiscal Years',
                            CollectionPath: 'FiscalYears',
                            Parameters: [
                                {
                                    $Type: 'Common.ValueListParameterInOut',
                                    LocalDataProperty: fiscalYear,
                                    ValueListProperty: 'year'
                                }
                            ]
                        },
                        ValueListWithFixedValues: true
                    })
                    @Analytics.Dimension;
    budgetAmount    @title: 'Total Budget'       @Measures.ISOCurrency: currency  @Analytics.Measure;
    consumedAmount  @title: 'Consumed Amount'    @Measures.ISOCurrency: currency  @Analytics.Measure;
    remainingAmount @title: 'Remaining Budget'   @Measures.ISOCurrency: currency  @Analytics.Measure;
    consumedPercent @title: 'Consumed %'                                          @Analytics.Measure;
    currency        @title: 'Currency';
};

// Note: Names and FiscalYears entity annotations (Common.Text, UI.Hidden)
// are defined in traveltrackingui/annotations.cds to avoid duplicates

// ---------- Header Info ----------
annotate service.BudgetAnalytics with @(
    UI.HeaderInfo: {
        TypeName       : 'Budget Analysis',
        TypeNamePlural : 'Budget Analytics',
        Title          : { $Type: 'UI.DataField', Value: employeeName },
        Description    : { $Type: 'UI.DataField', Value: fiscalYear }
    }
);

// ---------- Selection Fields (Filters) ----------
annotate service.BudgetAnalytics with @(
    UI.SelectionFields: [
        employeeName,
        fiscalYear
    ]
);

// ---------- Chart: Bar Chart - Budget vs Consumed by Employee ----------
annotate service.BudgetAnalytics with @(
    UI.Chart #BudgetOverview: {
        $Type              : 'UI.ChartDefinitionType',
        Title              : 'Budget vs Consumed by Employee',
        ChartType          : #Bar,
        Dimensions         : [employeeName],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: employeeName,
            Role     : #Category
        }],
        Measures           : [budgetAmount, consumedAmount],
        MeasureAttributes  : [
            {
                $Type  : 'UI.ChartMeasureAttributeType',
                Measure: budgetAmount,
                Role   : #Axis1
            },
            {
                $Type  : 'UI.ChartMeasureAttributeType',
                Measure: consumedAmount,
                Role   : #Axis1
            }
        ]
    }
);

// ---------- Chart: Donut Chart - Consumed vs Remaining (Header) ----------
annotate service.BudgetAnalytics with @(
    UI.Chart #ConsumedVsRemaining: {
        $Type              : 'UI.ChartDefinitionType',
        Title              : 'Consumed vs Remaining',
        ChartType          : #Donut,
        Dimensions         : [employeeName],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: employeeName,
            Role     : #Category
        }],
        Measures           : [consumedAmount, remainingAmount],
        MeasureAttributes  : [
            {
                $Type  : 'UI.ChartMeasureAttributeType',
                Measure: consumedAmount,
                Role   : #Axis1
            },
            {
                $Type  : 'UI.ChartMeasureAttributeType',
                Measure: remainingAmount,
                Role   : #Axis2
            }
        ]
    }
);

// ---------- Data Points ----------
annotate service.BudgetAnalytics with @(
    UI.DataPoint #BudgetAmount: {
        Value        : budgetAmount,
        Title        : 'Total Budget',
        Criticality  : #Neutral
    },
    UI.DataPoint #ConsumedAmount: {
        Value        : consumedAmount,
        Title        : 'Consumed Amount',
        Criticality  : #Critical
    },
    UI.DataPoint #RemainingAmount: {
        Value        : remainingAmount,
        Title        : 'Remaining Budget',
        Criticality  : #Positive
    },
    UI.DataPoint #ConsumedPercent: {
        Value        : consumedPercent,
        Title        : 'Consumed %',
        TargetValue  : 100,
        Visualization: #Progress
    }
);

// ---------- KPI Tags (Header) ----------
annotate service.BudgetAnalytics with @(
    UI.HeaderFacets: [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'BudgetAmountFacet',
            Target : '@UI.DataPoint#BudgetAmount'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'ConsumedAmountFacet',
            Target : '@UI.DataPoint#ConsumedAmount'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'RemainingAmountFacet',
            Target : '@UI.DataPoint#RemainingAmount'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'ConsumedPercentFacet',
            Target : '@UI.DataPoint#ConsumedPercent'
        }
    ]
);

// ---------- List Report (Table Columns) ----------
annotate service.BudgetAnalytics with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: employeeName,    Label: 'Employee Name',    ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: fiscalYear,       Label: 'Fiscal Year',      ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: budgetAmount,     Label: 'Total Budget',     ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: consumedAmount,   Label: 'Consumed Amount',  ![@UI.Importance]: #High },
        { $Type: 'UI.DataField', Value: remainingAmount,  Label: 'Remaining Budget',  ![@UI.Importance]: #High },
        {
            $Type: 'UI.DataFieldForAnnotation',
            Target: '@UI.DataPoint#ConsumedPercent',
            Label : 'Consumed %'
        },
        { $Type: 'UI.DataField', Value: currency,         Label: 'Currency' }
    ]
);

// ---------- Object Page: Field Groups ----------
annotate service.BudgetAnalytics with @(
    UI.FieldGroup #Overview: {
        $Type: 'UI.FieldGroupType',
        Label: 'Budget Overview',
        Data : [
            { $Type: 'UI.DataField', Value: employeeName,    Label: 'Employee Name' },
            { $Type: 'UI.DataField', Value: fiscalYear,       Label: 'Fiscal Year' },
            { $Type: 'UI.DataField', Value: budgetAmount,     Label: 'Total Budget' },
            { $Type: 'UI.DataField', Value: consumedAmount,   Label: 'Consumed Amount' },
            { $Type: 'UI.DataField', Value: remainingAmount,  Label: 'Remaining Budget' },
            { $Type: 'UI.DataField', Value: consumedPercent,  Label: 'Consumed %' },
            { $Type: 'UI.DataField', Value: currency,         Label: 'Currency' }
        ]
    }
);

// ---------- Object Page: Facets ----------
annotate service.BudgetAnalytics with @(
    UI.Facets: [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'ChartFacet',
            Label  : 'Budget Breakdown',
            Target : '@UI.Chart#ConsumedVsRemaining'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'OverviewFacet',
            Label  : 'Budget Overview',
            Target : '@UI.FieldGroup#Overview'
        }
    ]
);

// ---------- Presentation Variant ----------
annotate service.BudgetAnalytics with @(
    UI.PresentationVariant: {
        Text          : 'Default',
        Visualizations: ['@UI.LineItem', '@UI.Chart#BudgetOverview'],
        SortOrder     : [{
            Property  : employeeName,
            Descending: false
        }]
    }
);