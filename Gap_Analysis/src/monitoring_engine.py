import pandas as pd
import json
from pathlib import Path
from datetime import datetime
import numpy as np


class MonitoringSnapshot:
    def __init__(self, snapshot_dir: Path = None):
        if snapshot_dir is None:
            snapshot_dir = Path(__file__).parent.parent / "results" / "monitoring_reports"
        self.snapshot_dir = Path(snapshot_dir)
        self.snapshot_dir.mkdir(parents=True, exist_ok=True)

    def save_snapshot(self, gap_df: pd.DataFrame, week_number: int = None, 
                     snapshot_date: str = None) -> tuple:
        if snapshot_date is None:
            snapshot_date = datetime.now().strftime("%Y-%m-%d")
        
        if week_number is None:
            week_number = datetime.now().isocalendar()[1]

        snapshot_data = []
        for _, row in gap_df.iterrows():
            snapshot_data.append({
                "date": snapshot_date,
                "week": week_number,
                "category": row['category'],
                "supply": int(row['supply']),
                "demand": int(row['demand']),
                "gap_score": float(row['gap_score']),
                "gap_status": row['gap_status'],
                "normalized_gap": float(row.get('normalized_gap', 0))
            })

        json_path = self.snapshot_dir / f"snapshot_week_{week_number}_{snapshot_date}.json"
        with open(json_path, 'w') as f:
            json.dump(snapshot_data, f, indent=2)

        csv_path = self.snapshot_dir / f"snapshot_week_{week_number}_{snapshot_date}.csv"
        snapshot_df = pd.DataFrame(snapshot_data)
        snapshot_df.to_csv(csv_path, index=False)

        return str(json_path), str(csv_path)

    def load_latest_snapshot(self) -> pd.DataFrame:
        json_files = sorted(self.snapshot_dir.glob("snapshot_*.json"), reverse=True)
        if not json_files:
            return None
        
        with open(json_files[0], 'r') as f:
            data = json.load(f)
        return pd.DataFrame(data)

    def load_snapshot_by_date(self, snapshot_date: str) -> pd.DataFrame:
        json_file = list(self.snapshot_dir.glob(f"snapshot_*_{snapshot_date}.json"))
        if not json_file:
            return None
        
        with open(json_file[0], 'r') as f:
            data = json.load(f)
        return pd.DataFrame(data)


class GapChangeAnalyzer:
    
    @staticmethod
    def compute_gap_change(current_gap_df: pd.DataFrame, 
                          previous_gap_df: pd.DataFrame = None) -> pd.DataFrame:
        result = current_gap_df.copy()
        
        if previous_gap_df is not None:
            previous_gap_df = previous_gap_df.set_index('category')
            
            result['previous_gap_score'] = result['category'].map(
                previous_gap_df['gap_score']
            )
            result['gap_change_pct'] = (
                (result['gap_score'] - result['previous_gap_score']) / 
                (result['previous_gap_score'] + 1) * 100
            ).round(2)
            
            result['previous_supply'] = result['category'].map(
                previous_gap_df['supply']
            )
            result['supply_change_pct'] = (
                (result['supply'] - result['previous_supply']) / 
                (result['previous_supply'] + 1) * 100
            ).round(2)
            
            result['previous_demand'] = result['category'].map(
                previous_gap_df['demand']
            )
            result['demand_change_pct'] = (
                (result['demand'] - result['previous_demand']) / 
                (result['previous_demand'] + 1) * 100
            ).round(2)
        else:
            result['gap_change_pct'] = 0.0
            result['supply_change_pct'] = 0.0
            result['demand_change_pct'] = 0.0
        
        return result

    @staticmethod
    def identify_categories_needing_attention(gap_df: pd.DataFrame) -> pd.DataFrame:
        flags = []
        
        for _, row in gap_df.iterrows():
            flag_list = []
            
            if row['gap_score'] > 5:
                flag_list.append('Critical Alert')
            
            if pd.notna(row.get('gap_change_pct', None)) and row.get('gap_change_pct', 0) > 20:
                flag_list.append('Gap Increasing')
            
            if pd.notna(row.get('gap_change_pct', None)) and row.get('gap_change_pct', 0) < -20:
                flag_list.append('Gap Improving')
            
            if pd.notna(row.get('supply_change_pct', None)) and row.get('supply_change_pct', 0) < -10:
                flag_list.append('Supply Drop')
            
            if pd.notna(row.get('demand_change_pct', None)) and row.get('demand_change_pct', 0) > 20:
                flag_list.append('Demand Spike')
            
            priority = 'Normal'
            if 'Critical Alert' in flag_list or 'Gap Increasing' in flag_list:
                priority = 'High'
            elif 'Supply Drop' in flag_list or 'Demand Spike' in flag_list:
                priority = 'Medium'
            elif 'Gap Improving' in flag_list:
                priority = 'Low'
            
            flags.append({
                'category': row['category'],
                'gap_score': row['gap_score'],
                'gap_change_pct': row.get('gap_change_pct', 0),
                'alerts': '; '.join(flag_list) if flag_list else 'None',
                'priority': priority
            })
        
        return pd.DataFrame(flags).sort_values('gap_score', ascending=False)


def compute_kpis(gap_df: pd.DataFrame) -> dict:
    critical_count = len(gap_df[gap_df['gap_status'].isin(['Critical Gap', 'High Gap'])])
    
    kpis = {
        'total_categories': len(gap_df),
        'avg_gap_score': round(gap_df['gap_score'].mean(), 2),
        'median_gap_score': round(gap_df['gap_score'].median(), 2),
        'max_gap_score': round(gap_df['gap_score'].max(), 2),
        'critical_categories': critical_count,
        'critical_pct': round(critical_count / len(gap_df) * 100, 1),
        'total_supply': int(gap_df['supply'].sum()),
        'total_demand': int(gap_df['demand'].sum()),
    }
    
    return kpis
