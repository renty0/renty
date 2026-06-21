import os
import pickle
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from scipy.sparse import csr_matrix
from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import cosine_similarity

DB_URLS = [
    "postgresql://postgres:postgrespassword@localhost:5432/rentyDB",
    "postgresql://postgres:postgrespassword@localhost:5433/rentyDB",
    "postgresql://neondb_owner:npg_0hBeijOPT4cL@ep-sweet-shadow-ag0l2dna-pooler.c-2.eu-central-1.aws.neon.tech:5432/rentyDB?sslmode=require"
]

# Weights for different interaction types
ACTION_WEIGHTS = {
    0: 1.0,  # View
    1: 2.0,  # Click
    2: 3.0,  # Search
    3: 5.0,  # Favorite
    4: 10.0, # Rent
    5: 5.0   # Review
}

def load_data_from_db():
    last_err = None
    for url in DB_URLS:
        try:
            print(f"Connecting to database using: {url} ...")
            engine = create_engine(url)
            
            # Query interactions
            # Try lowercased snake_case table first, then fallback to PascalCase
            try:
                print("Trying new schema (lowercased/snake_case)...")
                query_interactions = 'SELECT "user_id" AS "UserId", "item_id" AS "ItemId", "action" AS "Action", "created_at" AS "CreatedAt" FROM "user_interactions"'
                df_interactions = pd.read_sql(query_interactions, engine)
                
                # In new schema, Action is a string ('View', 'Click', 'Favorite', 'Rent'). 
                # Let's map it to the integer Action values: View=0, Click=1, Search=2, Favorite=3, Rent=4
                action_map = {'View': 0, 'Click': 1, 'Search': 2, 'Favorite': 3, 'Rent': 4}
                df_interactions["Action"] = df_interactions["Action"].map(action_map).fillna(0).astype(int)
                
                query_items = 'SELECT "id" AS "ItemId", "category_id" AS "CategoryId", "title_en" AS "TitleEn" FROM "items"'
                df_items = pd.read_sql(query_items, engine)
            except Exception as e:
                print(f"New schema query failed: {e}. Trying legacy PascalCase schema...")
                query_interactions = 'SELECT "UserId", "ItemId", "Action", "CreatedAt" FROM "UserInteractions"'
                df_interactions = pd.read_sql(query_interactions, engine)
                
                query_items = 'SELECT "Id" AS "ItemId", "CategoryId", "TitleEn" FROM "Items"'
                df_items = pd.read_sql(query_items, engine)
            
            print(f"Successfully loaded {len(df_interactions)} interactions and {len(df_items)} items.")
            return df_interactions, df_items, engine
        except Exception as e:
            print(f"Failed to connect or query using {url}: {e}")
            last_err = e
            
    if last_err:
        raise last_err

def train_recommender():
    df_interactions, df_items, engine = load_data_from_db()
    
    if df_interactions.empty:
        print("No interactions found in the database. Creating fallback default artifacts...")
        # Save empty/fallback placeholder
        artifacts = {
            "fallback": True,
            "item_ids": df_items["ItemId"].tolist() if not df_items.empty else [],
            "item_categories": dict(zip(df_items["ItemId"], df_items["CategoryId"])) if not df_items.empty else {}
        }
        with open("renty_recommendation_artifacts.pkl", "wb") as f:
            pickle.dump(artifacts, f)
        print("Saved fallback artifacts successfully.")
        return

    # Map item IDs (UUID strings) and user IDs to index
    all_item_ids = list(set(df_items["ItemId"].unique()).union(set(df_interactions["ItemId"].dropna().unique())))
    item_to_idx = {item_id: idx for idx, item_id in enumerate(all_item_ids)}
    idx_to_item = {idx: item_id for idx, item_id in enumerate(all_item_ids)}
    
    all_user_ids = list(df_interactions["UserId"].unique())
    user_to_idx = {user_id: idx for idx, user_id in enumerate(all_user_ids)}
    idx_to_user = {idx: user_id for idx, user_id in enumerate(all_user_ids)}
    
    # Apply weights to interactions
    df_interactions["Weight"] = df_interactions["Action"].map(ACTION_WEIGHTS).fillna(1.0)
    
    # Aggregate duplicate interactions for the same user-item pair
    df_grouped = df_interactions.groupby(["UserId", "ItemId"])["Weight"].sum().reset_index()
    
    # Create sparse interaction matrix
    rows = df_grouped["UserId"].map(user_to_idx).values
    cols = df_grouped["ItemId"].map(item_to_idx).values
    data = df_grouped["Weight"].values
    
    n_users = len(all_user_ids)
    n_items = len(all_item_ids)
    
    interaction_matrix = csr_matrix((data, (rows, cols)), shape=(n_users, n_items))
    
    # Train Matrix Factorization Model (TruncatedSVD)
    n_components = min(32, n_items - 1) if n_items > 1 else 1
    print(f"Training TruncatedSVD with {n_components} components...")
    
    svd = TruncatedSVD(n_components=n_components, random_state=42)
    user_embeddings = svd.fit_transform(interaction_matrix)
    item_embeddings = svd.components_.T
    
    # Calculate Item-to-Item Cosine Similarity matrix (for content-based fallback & session boosting)
    print("Calculating item-item similarity matrix...")
    item_similarity = cosine_similarity(item_embeddings)
    
    # Save trained model and helper maps
    artifacts = {
        "fallback": False,
        "user_to_idx": user_to_idx,
        "idx_to_user": idx_to_user,
        "item_to_idx": item_to_idx,
        "idx_to_item": idx_to_item,
        "user_embeddings": user_embeddings,
        "item_embeddings": item_embeddings,
        "item_similarity": item_similarity,
        "item_categories": dict(zip(df_items["ItemId"], df_items["CategoryId"])),
        "item_titles": dict(zip(df_items["ItemId"], df_items["TitleEn"]))
    }
    
    # Ensure output folder or current directory is used
    filepath = "renty_recommendation_artifacts.pkl"
    with open(filepath, "wb") as f:
        pickle.dump(artifacts, f)
        
    print(f"Successfully saved recommendation model artifacts to {os.path.abspath(filepath)}")

if __name__ == "__main__":
    train_recommender()
