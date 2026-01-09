import pandas as pd


def compute_category_supply(sales_data: pd.DataFrame, products_full: pd.DataFrame) -> pd.DataFrame:
    """Calculate number of unique products available per category."""
    supply = products_full.groupby('CategoryName').agg({
        'ProductKey': 'nunique'
    }).reset_index()
    
    supply.columns = ['CategoryName', 'UniqueProducts']
    return supply


def compute_subcategory_supply(sales_data: pd.DataFrame, products_full: pd.DataFrame) -> pd.DataFrame:
    """Calculate number of unique products per subcategory."""
    supply = products_full.groupby(['CategoryName', 'SubcategoryName']).agg({
        'ProductKey': 'nunique'
    }).reset_index()
    
    supply.columns = ['CategoryName', 'SubcategoryName', 'UniqueProducts']
    return supply


def compute_category_demand(sales_data: pd.DataFrame) -> pd.DataFrame:
    """Calculate order metrics per category."""
    demand = sales_data.groupby('CategoryName').agg({
        'OrderNumber': 'nunique',
        'OrderQuantity': 'sum',
        'CustomerKey': 'nunique'
    }).reset_index()
    
    demand.columns = ['CategoryName', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    return demand


def compute_subcategory_demand(sales_data: pd.DataFrame) -> pd.DataFrame:
    """Calculate order metrics per subcategory."""
    demand = sales_data.groupby(['CategoryName', 'SubcategoryName']).agg({
        'OrderNumber': 'nunique',
        'OrderQuantity': 'sum',
        'CustomerKey': 'nunique'
    }).reset_index()
    
    demand.columns = ['CategoryName', 'SubcategoryName', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    return demand


def compute_territory_demand(sales_data: pd.DataFrame, territory_lookup: pd.DataFrame) -> pd.DataFrame:
    """Calculate order metrics by geographic territory."""
    territory_renamed = territory_lookup.rename(columns={'SalesTerritoryKey': 'TerritoryKey'})
    
    sales_with_territory = sales_data.merge(
        territory_renamed[['TerritoryKey', 'Region', 'Country']],
        on='TerritoryKey',
        how='left'
    )
    
    demand = sales_with_territory.groupby(['Region', 'Country', 'CategoryName']).agg({
        'OrderNumber': 'nunique',
        'OrderQuantity': 'sum',
        'CustomerKey': 'nunique'
    }).reset_index()
    
    demand.columns = ['Region', 'Country', 'CategoryName', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    return demand


def compute_subcategory_territory_demand(sales_data: pd.DataFrame, territory_lookup: pd.DataFrame) -> pd.DataFrame:
    """Calculate order metrics by subcategory and territory."""
    territory_renamed = territory_lookup.rename(columns={'SalesTerritoryKey': 'TerritoryKey'})
    
    sales_with_territory = sales_data.merge(
        territory_renamed[['TerritoryKey', 'Region', 'Country']],
        on='TerritoryKey',
        how='left'
    )
    
    demand = sales_with_territory.groupby(['Region', 'Country', 'CategoryName', 'SubcategoryName']).agg({
        'OrderNumber': 'nunique',
        'OrderQuantity': 'sum',
        'CustomerKey': 'nunique'
    }).reset_index()
    
    demand.columns = ['Region', 'Country', 'CategoryName', 'SubcategoryName', 
                     'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    return demand


def merge_supply_demand(supply: pd.DataFrame, demand: pd.DataFrame) -> pd.DataFrame:
    """Merge supply and demand dataframes on common columns."""
    supply_cols = [col for col in supply.columns if col not in ['UniqueProducts']]
    demand_cols = [col for col in demand.columns if col not in ['UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']]
    
    merge_on = list(set(supply_cols) & set(demand_cols))
    
    merged = pd.merge(demand, supply, on=merge_on, how='outer').fillna(0)
    
    int_columns = ['UniqueProducts', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    for col in int_columns:
        if col in merged.columns:
            merged[col] = merged[col].astype(int)
    
    return merged
