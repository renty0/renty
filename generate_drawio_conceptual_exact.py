
import os

# Helper to create Draw.io XML
header = """<mxfile host="Electron" modified="2024-01-17T00:00:00.000Z" agent="5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/21.0.0" version="21.0.0" type="device">
  <diagram id="RentlyChenExact" name="Conceptual">
    <mxGraphModel dx="2000" dy="2000" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1100" pageHeight="850" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />"""

footer = """
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>"""

elements = []
edges = []

# Styles
# Entity: Rectangle with attributes
style_entity_sw = "swimlane;fontStyle=0;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;html=1;whiteSpace=wrap;fillColor=#ffffff;strokeColor=#000000;"
# Relationship: Diamond
style_rel = "rhombus;whiteSpace=wrap;html=1;fillColor=#ffffff;strokeColor=#000000;fontStyle=1;"
# Edge: Simple Line
style_edge = "endArrow=none;html=1;rounded=0;entryX=0.5;entryY=0.5;exitX=0.5;exitY=0.5;"

def add_entity(id, name, x, y, columns):
    width = 140
    height = 26 + (len(columns) * 20)
    
    # Outer Swimlane
    xml = f"""
        <mxCell id="{id}" value="{name}" style="{style_entity_sw}" vertex="1" parent="1">
          <mxGeometry x="{x}" y="{y}" width="{width}" height="{height}" as="geometry" />
        </mxCell>"""
    
    # Attributes
    for i, col in enumerate(columns):
        col_id = f"{id}_c{i}"
        xml += f"""
        <mxCell id="{col_id}" value="{col}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;rotatable=0;whiteSpace=wrap;html=1;" vertex="1" parent="{id}">
          <mxGeometry y="{26 + (i*26)}" width="{width}" height="26" as="geometry" />
        </mxCell>"""
    return xml

def add_diamond(id, label, x, y):
    # Diamond shape
    return f"""
        <mxCell id="{id}" value="{label}" style="{style_rel}" vertex="1" parent="1">
          <mxGeometry x="{x}" y="{y}" width="100" height="60" as="geometry" />
        </mxCell>"""

def add_conn(source, target, label_start="", label_end=""):
    # Connects center to center roughly
    return f"""
        <mxCell id="edge_{source}_{target}" value="" style="{style_edge}" edge="1" parent="1" source="{source}" target="{target}">
          <mxGeometry relative="1" as="geometry">
            <mxPoint as="sourcePoint" />
            <mxPoint as="targetPoint" />
          </mxGeometry>
        </mxCell>"""

# --- Layout Nodes based on Image ---

# 1. Territory (Top Center)
elements.append(add_entity("terr", "Territory", 400, 50, ["territory_key", "region", "country", "continent"]))

# 2. Calendar (Top Right-ish)
elements.append(add_entity("cal", "Calendar", 700, 50, ["date", "day_name", "month", "year"]))

# 3. Sales_Transaction (Center)
elements.append(add_entity("sale", "Sales_Transaction", 400, 300, ["id", "order_number", "quantity", "amount"]))

# 4. Customer (Left)
elements.append(add_entity("cust", "Customer", 50, 250, ["customer_key", "name", "email", "gender", "income"]))

# 5. Returns_Transaction (Center Right)
elements.append(add_entity("ret", "Returns_Transaction", 650, 300, ["id", "reason", "quantity"]))

# 6. Product (Right)
elements.append(add_entity("prod", "Product", 900, 300, ["product_key", "name", "sku", "price", "cost"]))

# 7. Product_Subcategory (Right Top of product)
elements.append(add_entity("sub", "Product_Subcategory", 900, 100, ["subcategory_key", "name"]))

# 8. Product_Category (Right Top of sub)
elements.append(add_entity("cat", "Product_Category", 900, -100, ["category_key", "name"]))

# 9. Rentable_Item (Bottom Left)
elements.append(add_entity("item", "Rentable_Item", 50, 600, ["id", "title", "price_per_day", "description"]))

# 10. Rent_Request (Bottom Center-Left)
elements.append(add_entity("req", "Rent_Request", 300, 600, ["id", "start_date", "end_date", "status"]))

# 11. Gap_Snapshot (Bottom Center-Right)
elements.append(add_entity("gap", "Gap_Snapshot", 600, 600, ["id", "snapshot_date", "supply", "demand"]))

# 12. Media_File (Far Right)
elements.append(add_entity("media", "Media_File", 1000, 500, ["id", "file_name", "path"]))

# 13. Product_Image (Right, below Product)
elements.append(add_entity("img", "Product_Image", 900, 500, ["id", "image_url", "is_primary"]))


# --- Relationships (Diamonds) ---

# Customer - Makes - Sale
elements.append(add_diamond("rel_makes", "Makes", 250, 280))
edges.append(add_conn("cust", "rel_makes"))
edges.append(add_conn("rel_makes", "sale"))

# Territory - In - Sale
elements.append(add_diamond("rel_terr", "Has_Territory", 420, 200))
edges.append(add_conn("terr", "rel_terr"))
edges.append(add_conn("rel_terr", "sale"))

# Calendar - Has - Sale
elements.append(add_diamond("rel_date", "Ord_Date", 550, 200))
edges.append(add_conn("cal", "rel_date"))
edges.append(add_conn("rel_date", "sale"))

# Product - Contains - Sale
elements.append(add_diamond("rel_prod_sale", "Contains", 650, 250)) # Actually image connects Product to Sale directly? Let's use diamond
edges.append(add_conn("prod", "rel_prod_sale"))
edges.append(add_conn("rel_prod_sale", "sale"))

# Product - Contains - Return
elements.append(add_diamond("rel_prod_ret", "Contains", 800, 320))
edges.append(add_conn("prod", "rel_prod_ret"))
edges.append(add_conn("rel_prod_ret", "ret"))

# Category Hierarchy
elements.append(add_diamond("rel_sub", "Categorizes", 920, 220))
edges.append(add_conn("sub", "rel_sub"))
edges.append(add_conn("rel_sub", "prod"))

elements.append(add_diamond("rel_cat", "Categorizes", 920, 20))
edges.append(add_conn("cat", "rel_cat"))
edges.append(add_conn("rel_cat", "sub"))

# Rental
elements.append(add_diamond("rel_owner", "Has_Owner", 100, 500))
edges.append(add_conn("cust", "rel_owner"))
edges.append(add_conn("rel_owner", "item"))

elements.append(add_diamond("rel_renter", "Has_Renter", 200, 450))
edges.append(add_conn("cust", "rel_renter"))
edges.append(add_conn("rel_renter", "req"))

elements.append(add_diamond("rel_req_item", "Has_Item", 180, 620))
edges.append(add_conn("item", "rel_req_item"))
edges.append(add_conn("rel_req_item", "req"))

# Analytics
elements.append(add_diamond("rel_gap", "Category_Gap", 750, 700)) # Gap usually links to Category
edges.append(add_conn("cat", "rel_gap"))
edges.append(add_conn("rel_gap", "gap"))


# Write File
final_xml = header + "".join(elements) + "".join(edges) + footer

with open("e:\\Courses\\Work\\renty\\RentlyConceptualExact.drawio", "w", encoding="utf-8") as f:
    f.write(final_xml)

print("RentlyConceptualExact.drawio generated.")
