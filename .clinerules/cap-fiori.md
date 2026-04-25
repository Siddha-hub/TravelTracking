- for SAP CAP (Cloud Application Programming) applications, refer the @cap docs for better information.
 
Some Additional Information for CAP App
- If you are using cuid aspect, a default coulmn ID is added and usually has UUIDs.

- always use cds init and dont' use "cds init projectname"

- always a nodejs cap based application (don't add --add, just init is fine)

- always add cds lint after genering the application

- Always CAP application should be draft enabled.

- Prefer composition over assocation SAP CAP for child entities.

- cds managed aspect should be used whereever it is neccessary and should be added to entity then only it will work.

- Don't use enums, prefer associated tables and with preload configuraiton data

- To generate a fiori application, following steps are required
    a. First step is to generate a json config file like shown below
```
{
    "version": "0.2",
    "floorplan": "FE_LROP",
    "project": {
        "name": "sales-order-headers-management1",
        "targetFolder": "/home/user/projects/vibecoding",
        "title": "Sales Order Headers",
        "description": "Manage sales order headers efficiently",
        "ui5Version": "1.132.1",
        "localUI5Version": "1.82.2",
        "sapux": true
    },
    "service": {
        "servicePath": "/service/vibecoding/",
        "capService": {
            "projectPath": "/home/user/projects/vibecoding",
            "serviceName": "vibecodingSrv",
            "serviceCdsPath": "srv/service.cds"
        }
    },
    "entityConfig": {
        "mainEntity": {
            "entityName": "SalesOrderHeaders"
        },
        "generateFormAnnotations": true
    },
    "projectType": "FORM_ENTRY_OBJECT_PAGE",
    "telemetryData": {
        "generationSourceName": "AI Headless",
        "generationSourceVersion": "1.18.1"
    }
}
```
    note: use always this version of ui5: "ui5Version": "1.132.1", "localUI5Version": "1.82.2".

    b. run the below command to generate the fiori application -headless way

```
/Users/I537743/Coding/travelTracking/.fiori-ai/generator-config.json is path to the json config file
yo @sap/fiori:headless "/Users/I537743/Coding/travelTracking/.fiori-ai/generator-config.json" --force

``` 
    c. add neccessary annotations in the generated fiori application usually in annotations.cds file. check https://github.com/SAP-samples/fiori-elements-feature-showcase for any guidance. [Tables for compositions, labels for all fields, valuehelps, etc., - ensure the ui is complete]



- "don't add random samples using cds add sample"

- For value helps 

- before testing use cds build to find any annotations errors and fix them, for more details about annotaitons check https://github.com/SAP-samples/fiori-elements-feature-showcase

- for cds views use #TextOnly

- for smaller set of data, prefer fixed values (dropdown) instead of popup help - ValueListWithFixedValues: true

- cds watch to test locally, use browswer testing mcp to confirm if it's working fine and UI looks good.

- always use node package "yo" with version 4.3.1 and before installing check if yo is already there and @sap/generator-fiori -> for fiori app generation.

- after cds watch, don't call `sleep 5 or 3`, it will stop cds watch.

- If cuid is added to entity, then ID will be uuid, so ensure sample data will have ID type uuid.

- use https://ui5.sap.com/1.146.0/resources/sap-ui-core.js for bootstrapping UI5 version

- Fundamental UI Architecture
Metadata-Driven UI: Never suggest custom UI5 XML views unless explicitly asked. Always use Fiori Elements (LROP - List Report Object Page).

Draft & Side Effects: Since the app is draft-enabled, ensure @Common.SideEffects are considered when a field change (like Quantity) should update another field (like Total Price).

CUID Masking: Never display the raw ID (UUID) field on the UI. Use @Common.Text to show a human-readable field (e.g., Name or Title) instead.

- Header & Global Annotations
Header Info: Every main entity must have @(UI.HeaderInfo) defined:

TypeName: Singular name (e.g., 'Book').

TypeNamePlural: Plural name (e.g., 'Books').

Title: Should point to the main identifying property (e.g., title).

Description: A sub-title property (e.g., author).

- List Report (The Main Table)
Selection Fields: Define @(UI.SelectionFields) for the top 3-5 most important filterable fields.

Line Items: Define @(UI.LineItem) for table columns.

Use Criticality for status-based coloring (1: Red, 2: Yellow, 3: Green).

Use @UI.Importance: #High for the first 3 columns to ensure mobile responsiveness.

- Object Page (The Detail View)
Facets (Layout): Use @(UI.Facets) to organize the page into sections:

ReferenceFacet: Points to a FieldGroup for general information.

CollectionFacet: To group multiple ReferenceFacets.

ReferenceFacet (Table): For child compositions (e.g., Items in a Header), target the @UI.LineItem of the child entity.

Field Groups: Group related fields together using @(UI.FieldGroup #GroupName).

- Value Helps & Input Validation
Searchable: Add @Search.defaultSearchElement: true to the primary text fields in the entity.

Value Lists: - For associations, always generate @Common.ValueList.

Use Parameters to map LocalDataProperty to ValueListProperty.

Dropdown vs Popup: If the associated entity is a "Type" or "Status" table (small dataset), use @Common.ValueListWithFixedValues: true.

Text Only: For IDs used in Value Helps, always use @Common.TextArrangement: #TextOnly.
