
import os

tables = [
    {
        "name": "Product",
        "columns": ["Id (PK)", "ProductName", "ProductSku", "ProductSubcategoryId (FK)", "ProductCost", "ProductPrice"]
    },
    {
        "name": "ProductCategory",
        "columns": ["Id (PK)", "CategoryName", "Description", "LogoId"]
    },
    {
        "name": "ProductSubcategory",
        "columns": ["Id (PK)", "SubcategoryName", "ProductCategoryId (FK)", "Description"]
    },
    {
        "name": "Customer",
        "columns": ["Id (PK)", "FirstName", "LastName", "EmailAddress", "MaritalStatus", "Gender", "AnnualIncome"]
    },
    {
        "name": "Territory",
        "columns": ["Id (PK)", "Region", "Country", "Continent"]
    },
    {
        "name": "Sale",
        "columns": ["Id (PK)", "OrderDate", "OrderNumber", "OrderQuantity", "ProductId (FK)", "CustomerId (FK)", "TerritoryId (FK)"]
    },
    {
        "name": "RentableItem",
        "columns": ["Id (PK)", "Title", "Description", "PricePerDay", "OwnerId (FK)", "CategoryId", "SubcategoryId"]
    },
    {
        "name": "RentRequest",
        "columns": ["Id (PK)", "RentableItemId (FK)", "RenterId (FK)", "StartDate", "EndDate", "TotalAmount", "Status"]
    },
    {
        "name": "Return",
        "columns": ["Id (PK)", "ReturnDate", "ReturnQuantity", "ProductId (FK)", "TerritoryId (FK)"]
    }
]

xml_header = """<mxfile host="Electron" modified="2024-01-17T00:00:00.000Z" agent="5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/21.0.0 Chrome/100.0.0.0 Electron/20.0.0 Safari/537.36" etag="random" version="21.0.0" type="device">
  <diagram id="RentlyERD" name="Page-1">
    <mxGraphModel dx="1422" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />"""

xml_footer = """
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>"""

content = xml_header

x_start = 40
y_start = 40
x_spacing = 250
y_spacing = 300
items_per_row = 3

for i, table in enumerate(tables):
    row = i // items_per_row
    col = i % items_per_row
    
    x = x_start + (col * x_spacing)
    y = y_start + (row * y_spacing)
    
    # Calculate height based on columns
    height = 40 + (len(table["columns"]) * 20)
    
    # Build HTML label
    label = f"<b>{table['name']}</b><br><hr>"
    label += "<br>".join(table["columns"])
    
    # XML chunk for the vertex
    chunk = f"""
        <mxCell id="tbl_{i}" value="{label}" style="rounded=0;whiteSpace=wrap;html=1;align=left;spacingLeft=10;verticalAlign=top;spacingTop=10;" vertex="1" parent="1">
          <mxGeometry x="{x}" y="{y}" width="200" height="{height}" as="geometry" />
        </mxCell>"""
    content += chunk

content += xml_footer

with open("e:\\Courses\\Work\\renty\\Rently.drawio", "w", encoding="utf-8") as f:
    f.write(content)

print("Rently.drawio generated successfully.")
