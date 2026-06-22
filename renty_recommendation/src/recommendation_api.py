import os
import pickle
import numpy as np
import pandas as pd
from fastapi import FastAPI, Query, HTTPException
from sqlalchemy import create_engine, text

DB_URLS = [
    "postgresql://postgres:postgrespassword@localhost:5432/rentyDB",
    "postgresql://postgres:postgrespassword@localhost:5433/rentyDB",
    "postgresql://dev-db-168548:AVNS_IVH87ja0r9i9TEnRzZn@app-dd4f79c4-c164-43f2-8618-0430cfe31cb8-do-user-29117682-0.g.db.ondigitalocean.com:25060/dev-db-168548?sslmode=require"
]
MODEL_PATH = "renty_recommendation_artifacts.pkl"

app = FastAPI(title="Renty Recommender API")

engine = None
for url in DB_URLS:
    try:
        temp_engine = create_engine(url)
        with temp_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        engine = temp_engine
        print(f"FastAPI connected to database on: {url}")
        break
    except Exception as e:
        print(f"Database connection attempt failed for {url}: {e}")

if engine is None:
    print("WARNING: Could not connect to database on any port. Using fallback default URL.")
    engine = create_engine(DB_URLS[0])


# Global variables to hold model artifacts
artifacts = None

def load_artifacts():
    global artifacts
    if os.path.exists(MODEL_PATH):
        try:
            with open(MODEL_PATH, "rb") as f:
                artifacts = pickle.load(f)
            print(f"Loaded recommendation artifacts successfully from {MODEL_PATH}")
        except Exception as e:
            print(f"Error loading artifacts: {e}")
            artifacts = None
    else:
        print(f"Artifacts file {MODEL_PATH} not found. Running in fallback mode.")
        artifacts = None

@app.on_event("startup")
def startup_event():
    load_artifacts()

@app.get("/reload")
def reload_model():
    """Reloads the trained model from the file system without restarting the server."""
    load_artifacts()
    if artifacts is None:
        return {"status": "Error", "message": "Failed to load model or file not found."}
    return {"status": "Success", "message": "Model reloaded successfully."}

def get_recent_user_interactions(user_id: int, limit: int = 5):
    """Queries the database for the user's most recent interactions to perform session boosting."""
    # Try new schema first (user_interactions table)
    try:
        query = text('''
            SELECT "item_id" AS "ItemId", "action" AS "Action" 
            FROM "user_interactions" 
            WHERE "user_id" = :user_id AND "item_id" IS NOT NULL
            ORDER BY "created_at" DESC 
            LIMIT :limit
        ''')
        with engine.connect() as conn:
            result = conn.execute(query, {"user_id": user_id, "limit": limit})
            action_map = {'View': 0, 'Click': 1, 'Search': 2, 'Favorite': 3, 'Rent': 4}
            interactions = []
            for row in result:
                action_str = row[1]
                action_int = action_map.get(action_str, 0)
                interactions.append((str(row[0]), action_int))
            return interactions
    except Exception as e:
        print(f"Error querying user_interactions (new schema): {e}")

    # Fallback to legacy schema
    query = text('''
        SELECT "ItemId", "Action" 
        FROM "UserInteractions" 
        WHERE "UserId" = :user_id AND "ItemId" IS NOT NULL
        ORDER BY "CreatedAt" DESC 
        LIMIT :limit
    ''')
    try:
        with engine.connect() as conn:
            result = conn.execute(query, {"user_id": user_id, "limit": limit})
            return [(str(row[0]), row[1]) for row in result]
    except Exception as e:
        print(f"Error querying recent interactions: {e}")
        return []

def get_trending_items(limit: int = 10):
    """Retrieves most viewed/popular items from the database."""
    # Try using user_interactions to count Views
    try:
        query = text('''
            SELECT "item_id" AS "Id", COUNT(*) as "cnt"
            FROM "user_interactions"
            WHERE "action" = 'View' AND "item_id" IS NOT NULL
            GROUP BY "item_id"
            ORDER BY "cnt" DESC
            LIMIT :limit
        ''')
        with engine.connect() as conn:
            result = conn.execute(query, {"limit": limit})
            items = [str(row[0]) for row in result]
            if items:
                return items
    except Exception as e:
        print(f"Error querying trending from user_interactions: {e}")

    # Fallback: query items table directly (filtering by status Available/Rented)
    try:
        query = text('''
            SELECT "id" AS "Id"
            FROM "items"
            WHERE "status" = 'Available' OR "status" = 'Rented'
            LIMIT :limit
        ''')
        with engine.connect() as conn:
            result = conn.execute(query, {"limit": limit})
            items = [str(row[0]) for row in result]
            if items:
                return items
    except Exception as e:
        print(f"Error querying fallback items from items table: {e}")
        
    # Fallback to legacy Items table if that fails
    try:
        query = text('''
            SELECT "Id" 
            FROM "Items" 
            WHERE "Status" = 0 OR "Status" = 1 
            ORDER BY "ViewCount" DESC 
            LIMIT :limit
        ''')
        with engine.connect() as conn:
            result = conn.execute(query, {"limit": limit})
            return [str(row[0]) for row in result]
    except Exception as e:
        print(f"Error querying legacy Items: {e}")
        return []

@app.get("/recommend")
def recommend(user_id: int = Query(..., description="ID of the user"), count: int = Query(4, description="Number of recommendations")):
    global artifacts
    
    # 1. Check if model artifacts are loaded
    if artifacts is None or artifacts.get("fallback", True):
        # Fallback to popular trending items from the database
        print("Model is in fallback mode. Fetching trending items...")
        trending = get_trending_items(limit=count)
        return {"recommendations": trending, "algorithm": "Trending (Fallback)"}

    # Extract mappings and embeddings
    user_to_idx = artifacts["user_to_idx"]
    idx_to_item = artifacts["idx_to_item"]
    item_to_idx = artifacts["item_to_idx"]
    user_embeddings = artifacts["user_embeddings"]
    item_embeddings = artifacts["item_embeddings"]
    item_similarity = artifacts["item_similarity"]
    item_categories = artifacts["item_categories"]

    n_items = len(idx_to_item)
    scores = np.zeros(n_items)
    algorithm = "Collaborative Filtering + Session Boost"

    # 2. Collaborative Filtering prediction (if user exists in training set)
    user_idx = user_to_idx.get(user_id)
    if user_idx is not None:
        # Base scores using matrix factorization dot product
        user_vec = user_embeddings[user_idx]
        scores = user_vec @ item_embeddings.T
    else:
        algorithm = "Session-Based Sim Boosting (Cold Start)"

    # 3. Real-Time Session Boosting (Implicit Feedback)
    # Query database for the user's latest 5 interactions
    recent_interactions = get_recent_user_interactions(user_id, limit=5)
    
    if recent_interactions:
        boost = np.zeros(n_items)
        for item_id, action_type in recent_interactions:
            # Map action type to weights
            # Action weights: View=1.0, Click=2.0, Search=3.0, Favorite=5.0, Rent=10.0
            weight = 1.0
            if action_type == 1: # Click
                weight = 2.0
            elif action_type == 2: # Search
                weight = 3.0
            elif action_type == 3: # Favorite
                weight = 5.0
            elif action_type == 4: # Rent
                weight = 10.0
                
            # If the item exists in our model index, boost similar items
            if item_id in item_to_idx:
                item_idx = item_to_idx[item_id]
                # Add similarity scaled by interaction weight
                boost += item_similarity[item_idx] * weight * 0.5
                
                # Also directly boost same category items
                recent_category = item_categories.get(item_id)
                if recent_category:
                    for i_idx, i_id in idx_to_item.items():
                        if item_categories.get(i_id) == recent_category:
                            boost[i_idx] += 0.2 * weight

        scores += boost

    # 4. Filter out recently rented/purchased items (if any)
    # Fetch user's rented items to avoid repeating them immediately
    rented_ids = []
    try:
        # Try new schema first (rentals table)
        query_rented = text('SELECT DISTINCT "item_id" AS "ItemId" FROM "rentals" WHERE "user_id" = :user_id')
        with engine.connect() as conn:
            rented_ids = [str(row[0]) for row in conn.execute(query_rented, {"user_id": user_id})]
    except Exception as e:
        print(f"Error querying rentals (new schema): {e}")
        # Fallback to legacy RentRequests
        try:
            query_rented = text('SELECT DISTINCT "ItemId" FROM "RentRequests" WHERE "RenterId" = :user_id')
            with engine.connect() as conn:
                rented_ids = [str(row[0]) for row in conn.execute(query_rented, {"user_id": user_id})]
        except Exception as e_legacy:
            print(f"Error querying legacy RentRequests: {e_legacy}")

    for r_id in rented_ids:
        if r_id in item_to_idx:
            scores[item_to_idx[r_id]] = -np.inf

    # If scores are all zeros (cold start user with no interactions), fallback to trending
    if np.all(scores == 0):
        print(f"User {user_id} has no historical or recent interactions. Returning trending items.")
        trending = get_trending_items(limit=count)
        return {"recommendations": trending, "algorithm": "Trending (Cold Start)"}

    # 5. Get top-N item IDs
    top_indices = np.argsort(-scores)[:count]
    recommended_ids = []
    for idx in top_indices:
        # Don't return filtered out items
        if scores[idx] > -np.inf:
            recommended_ids.append(idx_to_item[idx])

    # If we need more items to satisfy the requested count
    if len(recommended_ids) < count:
        trending = get_trending_items(limit=count * 2)
        for t_id in trending:
            if t_id not in recommended_ids and len(recommended_ids) < count:
                recommended_ids.append(t_id)

    return {"recommendations": recommended_ids, "algorithm": algorithm}
