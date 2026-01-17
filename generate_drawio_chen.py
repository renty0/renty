
import os

# Helper to create basic Draw.io XML structure
header = """<mxfile host="Electron" modified="2024-01-17T00:00:00.000Z" agent="5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/21.0.0" version="21.0.0" type="device">
  <diagram id="RentlyChen" name="Conceptual">
    <mxGraphModel dx="1422" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="1100" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />"""

footer = """
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>"""

# Elements storage
elements = []
edges = []

# Styles
style_entity = "rounded=0;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;"
style_rel = "rhombus;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;"
style_edge = "endArrow=none;html=1;rounded=0;"

def add_node(id, label, x, y, width, height, style):
    return f"""
        <mxCell id="{id}" value="{label}" style="{style}" vertex="1" parent="1">
          <mxGeometry x="{x}" y="{y}" width="{width}" height="{height}" as="geometry" />
        </mxCell>"""

def add_edge(id, source, target):
    return f"""
        <mxCell id="{id}" style="{style_edge}" edge="1" parent="1" source="{source}" target="{target}">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>"""

# --- Define Nodes (Entities) ---
# Central Fact Table
elements.append(add_node("sale", "Sales_Transaction", 400, 300, 140, 60, style_entity))

# Dimensions
elements.append(add_node("cust", "Customer", 100, 300, 120, 50, style_entity))
elements.append(add_node("terr", "Territory", 400, 100, 120, 50, style_entity))
elements.append(add_node("date", "Calendar", 700, 300, 120, 50, style_entity))
elements.append(add_node("prod", "Product", 400, 550, 120, 50, style_entity))

# Hierarchy
elements.append(add_node("sub", "Product_Subcategory", 400, 700, 140, 50, style_entity))
elements.append(add_node("cat", "Product_Category", 400, 850, 140, 50, style_entity))

# --- Define Relationships (Diamonds) ---
elements.append(add_node("rel_makes", "Makes", 250, 305, 100, 50, style_rel))
elements.append(add_node("rel_has_terr", "In_Territory", 420, 200, 100, 50, style_rel))
elements.append(add_node("rel_has_date", "Has_Date", 570, 305, 100, 50, style_rel))
elements.append(add_node("rel_contains", "Contains_Item", 420, 420, 100, 50, style_rel))
elements.append(add_node("rel_cat1", "Is_In", 435, 625, 50, 50, style_rel))
elements.append(add_node("rel_cat2", "Belongs_To", 435, 775, 80, 50, style_rel))

# --- Define Connections ---
# Customer - Sale
edges.append(add_edge("e1", "cust", "rel_makes"))
edges.append(add_edge("e2", "rel_makes", "sale"))

# Territory - Sale
edges.append(add_edge("e3", "terr", "rel_has_terr"))
edges.append(add_edge("e4", "rel_has_terr", "sale"))

# Calendar - Sale
edges.append(add_edge("e5", "date", "rel_has_date"))
edges.append(add_edge("e6", "rel_has_date", "sale"))

# Product - Sale
edges.append(add_edge("e7", "prod", "rel_contains"))
edges.append(add_edge("e8", "rel_contains", "sale"))

# Product Hierarchy
edges.append(add_edge("e9", "prod", "rel_cat1"))
edges.append(add_edge("e10", "rel_cat1", "sub"))

edges.append(add_edge("e11", "sub", "rel_cat2"))
edges.append(add_edge("e12", "rel_cat2", "cat"))


# Write File
final_xml = header + "".join(elements) + "".join(edges) + footer

with open("e:\\Courses\\Work\\renty\\RentlyConceptual.drawio", "w", encoding="utf-8") as f:
    f.write(final_xml)

print("RentlyConceptual.drawio generated.")
