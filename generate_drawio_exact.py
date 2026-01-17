
import os

# Helper to create basic Draw.io XML structure
header = """<mxfile host="Electron" modified="2024-01-17T00:00:00.000Z" agent="5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/21.0.0" version="21.0.0" type="device">
  <diagram id="RentlyExact" name="Schema">
    <mxGraphModel dx="2000" dy="2000" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100" math="0" shadow="0">
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

# Style for Table Header (Blue background)
style_header = "rounded=0;whiteSpace=wrap;html=1;fillColor=#1ba1e2;fontColor=#ffffff;strokeColor=#006EAF;fontStyle=1;align=left;spacingLeft=5;"
# Style for Columns (White background)
style_row = "rounded=0;whiteSpace=wrap;html=1;fillColor=#ffffff;strokeColor=#000000;align=left;spacingLeft=5;strokeWidth=0;"
# Style for Container
style_swimlane = "swimlane;fontStyle=0;childLayout=stackLayout;horizontal=1;startSize=26;horizontalStack=0;resizeParent=1;resizeParentMax=0;resizeLast=0;collapsible=1;marginBottom=0;html=1;"

def add_table(id, name, x, y, columns):
    width = 180
    height = 26 + (len(columns) * 20)
    
    # Table Container (Swimlane)
    xml = f"""
        <mxCell id="{id}" value="{name}" style="{style_swimlane}" vertex="1" parent="1">
          <mxGeometry x="{x}" y="{y}" width="{width}" height="{height}" as="geometry" />
        </mxCell>"""
    
    # Columns
    for i, col in enumerate(columns):
        col_id = f"{id}_c{i}"
        col_name = col.split(' ')[0]
        col_type = col.split(' ')[1] if len(col.split(' ')) > 1 else ''
        
        # Row content: Name (left) and Type (right aligned logic simulated by spacing or just text)
        label = f"{col_name}"
        
        xml += f"""
        <mxCell id="{col_id}" value="{label}" style="text;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;spacingLeft=4;spacingRight=4;overflow=hidden;points=[[0,0.5],[1,0.5]];portConstraint=eastwest;rotatable=0;whiteSpace=wrap;html=1;" vertex="1" parent="{id}">
          <mxGeometry y="{26 + (i*26)}" width="{width}" height="26" as="geometry" />
        </mxCell>"""
        
    return xml

def add_rel(source_id, target_id):
    return f"""
        <mxCell id="edge_{source_id}_{target_id}" style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;entryX=0;entryY=0.5;entryDx=0;entryDy=0;" edge="1" parent="1" source="{source_id}" target="{target_id}">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>"""

# --- Define Tables based on Image ---

# Sales Data (Fact)
cols_sales = [
    "id long", "order_date int", "stock_date int", "order_number varchar", 
    "product_key int", "customer_key int", "territory_key int", 
    "order_line_item int", "order_quantity int"
]
elements.append(add_table("sales", "sales_data", 800, 100, cols_sales))

# Customer Lookup
cols_cust = [
    "customer_key int", "prefix varchar", "first_name varchar", "last_name varchar",
    "birth_date date", "marital_status varchar", "gender varchar", "email_address varchar",
    "annual_income int", "total_children int", "education_level varchar", "occupation varchar",
    "home_owner varchar", "full_name varchar", "domain_name varchar"
]
elements.append(add_table("cust", "customer_lookup", 1100, 150, cols_cust))

# Territory Lookup
cols_terr = [
    "sales_territory_key int", "region varchar", "country varchar", "continent varchar"
]
elements.append(add_table("terr", "territory_lookup", 500, 100, cols_terr))

# Calendar Lookup
cols_cal = [
    "date int", "day_name varchar", "start_of_week int", "start_of_month int",
    "start_of_quarter int", "month_name varchar", "month int", "start_of_year int", "year int"
]
elements.append(add_table("cal", "calendar_lookup", 800, 400, cols_cal))

# Returns Data
cols_ret = [
    "id long", "return_date int", "territory_key int", "product_key int",
    "return_quantity int", "return_reason text"
]
elements.append(add_table("ret", "returns_data", 200, 150, cols_ret))

# Product Lookup
cols_prod = [
    "product_key int", "product_subcategory_key int", "product_sku varchar",
    "product_name varchar", "model_name varchar", "product_description varchar",
    "product_color varchar", "product_style varchar", "product_cost float",
    "product_price float", "sku_type varchar", "discount_price float"
]
elements.append(add_table("prod", "product_lookup", 500, 300, cols_prod))

# Product Images
cols_img = [
    "id long", "product_key int", "image_url varchar", "is_primary bool", "display_order int"
]
elements.append(add_table("img", "product_images", 500, 650, cols_img))

# Product Subcategories
cols_sub = [
    "product_subcategory_key int", "subcategory_name varchar", "description text",
    "product_category_key int", "logo_id guid"
]
elements.append(add_table("sub", "product_subcategories", 200, 500, cols_sub))

# Product Categories
cols_cat = [
    "product_category_key int", "category_name varchar", "description text", "logo_id guid"
]
elements.append(add_table("cat", "product_categories", 200, 700, cols_cat))

# Media Files
cols_media = [
    "id guid", "file_name varchar", "file_path varchar", "file_type varchar",
    "file_size_bytes long", "created_at datetime"
]
elements.append(add_table("media", "media_files", 50, 650, cols_media))

# Rentable Items
cols_rent = [
    "id long", "title varchar", "description text", "price_per_day float",
    "owner_id long", "category_id int", "subcategory_id int", "status varchar"
]
elements.append(add_table("rent", "rentable_items", 500, 900, cols_rent))

# Rent Requests
cols_req = [
    "id long", "item_id int", "renter_id long", "start_date datetime",
    "end_date datetime", "total_amount float", "status varchar"
]
elements.append(add_table("req", "rent_requests", 800, 900, cols_req))

# Gap Snapshots
cols_gap = [
    "id int", "category_key int", "snapshot_date datetime", "supply_count int",
    "demand_count int", "gap_score float"
]
elements.append(add_table("gap", "gap_snapshots", 200, 900, cols_gap))


# --- Relationships ---
# Note: Manually linking row indices based on assumptions of Key locations
# Connecting Table/Header boxes for simplicity in this script
edges.append(add_rel("cust", "sales"))
edges.append(add_rel("terr", "sales"))
edges.append(add_rel("prod", "sales"))
edges.append(add_rel("cal", "sales"))

edges.append(add_rel("terr", "ret"))
edges.append(add_rel("prod", "ret"))

edges.append(add_rel("sub", "prod"))
edges.append(add_rel("prod", "img"))
edges.append(add_rel("cat", "sub"))

edges.append(add_rel("media", "cat"))
edges.append(add_rel("media", "sub"))

edges.append(add_rel("rent", "req"))
edges.append(add_rel("cat", "gap"))
edges.append(add_rel("cat", "rent"))
edges.append(add_rel("sub", "rent"))


# Generate
content = header + "".join(elements) + "".join(edges) + footer

with open("e:\\Courses\\Work\\renty\\RentlyExact.drawio", "w", encoding="utf-8") as f:
    f.write(content)

print("RentlyExact.drawio generated.")
