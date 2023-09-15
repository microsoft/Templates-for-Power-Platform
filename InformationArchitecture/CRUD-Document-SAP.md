# CRUD with a document in SAP

## Create or update data in SAP

Sometimes you'll need to create or update data in SAP. To do this, you'll need to find a BAPI/FM (Business Application Programming Interfaces/Function Module) that performs the function that you want.

If you cannot find a standard SAP BAPI/FM, a custom ABAP (Advanced Business Application Programming) function module can be created.

If the custom program is set up as a RFM (Remote Enabled Function Module), it can be called via the SAP ERP connector.

Learn more: [ABAP Development Tools](https://help.sap.com/docs/btp/sap-business-technology-platform/abap-development-user-guides)

## Determine which BAPI/FM to use

Use TCode: BAPI. You can then drill down the hierarchy and find a specific action you want to take. You then select that action and find the specific function module to call.

Here is an example of how you can find the function module BAPI_PO_CREATE1.
![Screenshot of BAPI Explorer]

## Test the function module

Here is how you can test the function module.

- Use Purchase Order as an example of a standard SAP document that has a header and at least one set of line-item tables. You will only concern yourself with the Header and Line Items table (EKKO/EKPO in this example) and will not cover any connected tables for statuses or pricing conditions.
- You know when each of the 4 CRUD (create, read, update, delete) operations will be called, and you call the corresponding Power Automate flow. Creating a new Purchase Order happens when the Create button is selected. Reading an existing Purchase Order happens when an existing Purchase Order number is entered in the Purchase Order number field, or the previous Purchase Order number drop down list is selected. You can only update a Purchase Order after it has been read and the edit button is selected. A Purchase Order cannot be deleted, but individual line items of the purchase order can be deleted. When this occurs, it is treated like an update, and the appropriate values are sent to SAP to indicate the specific line(s) to be deleted.
- SAP has a similar set of BAPI/FM calls for many of the standard document types within SAP:
  - Purchase Requisition
  - Purchase Order
  - Material Document
  - Vendor Invoice
  - Vendor Payment
  - Quote
  - Sales Order
  - Delivery
  - Customer Invoice  
