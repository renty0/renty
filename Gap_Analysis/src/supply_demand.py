import pandas as pd
from typing import Tuple


def compute_category_supply(sales_data: pd.DataFrame, products_full: pd.DataFrame) -> pd.DataFrame:
    """
    Compute supply metrics (number of products available) per category.
    
    Args:
        sales_data: DataFrame containing sales transactions
        products_full: DataFrame containing product information with categories
    
    Returns:
        DataFrame with category-level supply metrics
    """
    supply = products_full.groupby('CategoryName').agg({
        'ProductKey': 'nunique'
    }).reset_index()
    
    supply.columns = ['CategoryName', 'UniqueProducts']
    
    return supply


def compute_subcategory_supply(sales_data: pd.DataFrame, products_full: pd.DataFrame) -> pd.DataFrame:
    """
    Compute supply metrics at subcategory level.
    
    Args:
        sales_data: DataFrame containing sales transactions
        products_full: DataFrame containing product information with subcategories
    
    Returns:
        DataFrame with subcategory-level supply metrics
    """
    supply = products_full.groupby(['CategoryName', 'SubcategoryName']).agg({
        'ProductKey': 'nunique'
    }).reset_index()
    
    supply.columns = ['CategoryName', 'SubcategoryName', 'UniqueProducts']
    
    return supply


def compute_category_demand(sales_data: pd.DataFrame) -> pd.DataFrame:
    """
    Compute demand metrics (searches, orders, quantity) per category.
    
    Args:
        sales_data: DataFrame containing sales transactions with CategoryName
    
    Returns:
        DataFrame with category-level demand metrics
    """
    demand = sales_data.groupby('CategoryName').agg({
        'OrderNumber': 'nunique',
        'OrderQuantity': 'sum',
        'CustomerKey': 'nunique'
    }).reset_index()
    
    demand.columns = ['CategoryName', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    
    return demand


def compute_subcategory_demand(sales_data: pd.DataFrame) -> pd.DataFrame:
    """
    Compute demand metrics at subcategory level.
    
    Args:
        sales_data: DataFrame containing sales transactions with SubcategoryName
    
    Returns:
        DataFrame with subcategory-level demand metrics
    """
    demand = sales_data.groupby(['CategoryName', 'SubcategoryName']).agg({
        'OrderNumber': 'nunique',
        'OrderQuantity': 'sum',
        'CustomerKey': 'nunique'
    }).reset_index()
    
    demand.columns = ['CategoryName', 'SubcategoryName', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    
    return demand


def compute_territory_demand(sales_data: pd.DataFrame, territory_lookup: pd.DataFrame) -> pd.DataFrame:
    """
    Compute demand metrics by territory.
    
    Args:
        sales_data: DataFrame containing sales transactions with TerritoryKey
        territory_lookup: DataFrame containing territory information with SalesTerritoryKey
    
    Returns:
        DataFrame with territory-level demand metrics
    """
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
    """
    Compute demand metrics by subcategory and territory.
    
    Args:
        sales_data: DataFrame containing sales transactions with TerritoryKey
        territory_lookup: DataFrame containing territory information with SalesTerritoryKey
    
    Returns:
        DataFrame with subcategory and territory-level demand metrics
    """
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
    """
    Merge supply and demand DataFrames.
    
    Args:
        supply: DataFrame with supply metrics
        demand: DataFrame with demand metrics
    
    Returns:
        Merged DataFrame with both supply and demand metrics
    """
    supply_cols = [col for col in supply.columns if col not in ['UniqueProducts']]
    demand_cols = [col for col in demand.columns if col not in ['UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']]
    
    merge_on = list(set(supply_cols) & set(demand_cols))
    
    merged = pd.merge(demand, supply, on=merge_on, how='outer').fillna(0)
    
    int_columns = ['UniqueProducts', 'UniqueOrders', 'TotalQuantitySold', 'UniqueCustomers']
    for col in int_columns:
        if col in merged.columns:
            merged[col] = merged[col].astype(int)
    
    return merged
