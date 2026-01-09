import pandas as pd
import re

def to_snake_case(name):
    name = re.sub(r'[\s\-]+', '_', name)
    name = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', name)
    return name.lower()

def infer_columns(df):
    columns = []
    for col, dtype in zip(df.columns, df.dtypes):
        db_type = "varchar"
        if "int" in str(dtype):
            db_type = "int"
        elif "float" in str(dtype):
            db_type = "float"
        col_snake = to_snake_case(col)
        columns.append(f"  {col_snake} {db_type}")
    return columns

def find_relationships(parent_mapping):
    relationships = []
    seen = set()
    for child_col, parent_col in parent_mapping.items():
        ref_line = f"Ref: {child_col} > {parent_col}"
        if ref_line not in seen:
            relationships.append(ref_line)
            seen.add(ref_line)
    return relationships

def generate_dbml(datasets, parent_mapping, output_file="../results/db/output.dbml"):
    from pathlib import Path
    
    lines = []
    for table_name, df in datasets.items():
        table_snake = to_snake_case(table_name)
        lines.append(f"Table {table_snake} {{")
        cols = infer_columns(df)
        lines.extend(cols)
        lines.append("}\n")

    refs = find_relationships(parent_mapping)
    lines.extend(refs)

    # Create directory if it doesn't exist
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, "w") as f:
        f.write("\n".join(lines))


parent_mapping = {
    "_product_lookup.product_subcategory_key": "product_subcateg.product_subcategory_key",
    "product_subcateg.product_category_key": "product_categori.product_category_key",
    "sales_data.product_key": "_product_lookup.product_key",
    "sales_data.customer_key": "customer_lookup.customer_key",
    "sales_data.territory_key": "territory_lookup.sales_territory_key",
    "returns_data.product_key": "_product_lookup.product_key",
    "returns_data.territory_key": "territory_lookup.sales_territory_key",
    "sales_data.order_date": "calendar_lookup.date",
    "returns_data.return_date": "calendar_lookup.date",
}
