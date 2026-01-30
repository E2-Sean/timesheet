<cfset json = 
{
  "Invoices": [
    {
      "Type": "ACCREC",
      "Contact": {
        "ContactID": "f4076f40-e387-4a2a-8e29-1543a717a6ce"
      },
      "LineItems": [
        {
          "Description": "Solution Design",
          "Quantity": 3,
          "UnitAmount": 200,
          "AccountCode": "200",
          "TaxType": "OUTPUT",
          "LineAmount": 600
        },
        {
          "Description": "Programming",
          "Quantity": 3,
          "UnitAmount": 150,
          "AccountCode": "200",
          "TaxType": "OUTPUT",
          "LineAmount": 450
        },
        {
          "Description": "Testing",
          "Quantity": 2,
          "UnitAmount": 100,
          "AccountCode": "200",
          "TaxType": "OUTPUT",
          "LineAmount": 200
        },
        {
          "Description": "Consulting",
          "Quantity": 4,
          "UnitAmount": 250,
          "AccountCode": "200",
          "TaxType": "OUTPUT",
          "LineAmount": 1000
        }
      ],
      "Date": "2022-07-01",
      "DueDate": "2022-08-01",
      "Reference": "API Development Phase 2",
      "Status": "DRAFT"
    }
  ]
}
>

<cfoutput>#serializeJSON(json)#</cfoutput>