import pandas as pd
import json
from pathlib import Path
from datetime import datetime


class ActionPlanner:
    
    def __init__(self, output_dir: Path = None):
        if output_dir is None:
            output_dir = Path(__file__).parent.parent.parent / "results" / "monitoring_reports"
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def generate_operational_actions(self, category: str, gap_score: float, 
                                    supply: int, demand: int) -> list:
        actions = []
        
        if gap_score > 5:
            actions.append(f"Launch supply recruitment campaign targeting lenders with {category} items")
            actions.append(f"Offer 3-month listing incentive (10% commission reduction) for {category}")
            actions.append(f"Create {category} category highlight page with featured rewards")
        
        if gap_score > 3:
            actions.append(f"Send targeted push notifications to active renters in {category}")
            actions.append(f"Feature trending {category} items in homepage recommendations")
            actions.append(f"Implement waitlist feature for out-of-stock {category} items")
        
        if supply < demand * 0.3:
            actions.append(f"Contact top lenders outside platform to list {category} items")
            actions.append(f"Establish partnerships with {category} retailers for consignment")
        
        return actions

    def generate_strategic_actions(self, category: str, gap_score: float,
                                  gap_change_pct: float) -> list:
        actions = []
        
        if gap_score > 5:
            actions.append(f"Develop supplier partnership strategy for {category} expansion")
            actions.append(f"Allocate marketing budget (15%) toward {category} category growth")
            actions.append(f"Create {category} category vertical with dedicated team")
        
        if gap_change_pct > 20:
            actions.append(f"Investigate root cause of {category} gap increase")
            actions.append(f"Conduct competitor analysis in {category} segment")
            actions.append(f"Review and adjust {category} pricing strategy")
        
        if gap_change_pct < -20:
            actions.append(f"Document successful {category} improvement strategy for other categories")
            actions.append(f"Accelerate similar initiatives based on {category} success model")
        
        return actions

    def generate_platform_actions(self, category: str, gap_score: float) -> list:
        actions = []
        
        if gap_score > 5:
            actions.append(f"Boost {category} SEO/search ranking priority")
            actions.append(f"Increase {category} items in recommendation algorithm weight")
            actions.append(f"Create dedicated {category} landing page with category-specific messaging")
        
        if gap_score > 3:
            actions.append(f"Add 'High-Demand' badge to all {category} listings")
            actions.append(f"Implement smart search suggestions for {category} terms")
            actions.append(f"Create {category} category widget on homepage")
        
        if gap_score < 1:
            actions.append(f"Reduce {category} visibility in recommendations (balanced supply)")
            actions.append(f"Redirect marketing focus to shortage categories")
        
        return actions

    def generate_user_engagement_actions(self, category: str, gap_score: float) -> list:
        actions = []
        
        if gap_score > 5:
            actions.append(f"Create referral rewards program specifically for {category} lenders")
            actions.append(f"Send personalized emails to inactive lenders about {category} opportunity")
            actions.append(f"Develop {category}-specific renter profiles for targeted outreach")
        
        if gap_score > 3:
            actions.append(f"Display 'Popular in {category}' social proof on item pages")
            actions.append(f"Create {category} community discussions and forums")
            actions.append(f"Implement {category} item pre-booking feature")
        
        actions.append(f"Reward users who first list {category} items with bonus credit")
        
        return actions

    def generate_category_action_plan(self, gap_df: pd.DataFrame, 
                                     week_number: int = None) -> dict:
        if week_number is None:
            week_number = datetime.now().isocalendar()[1]
        
        action_plans = []
        
        for _, row in gap_df.iterrows():
            category = row['category']
            gap_score = row['gap_score']
            supply = int(row['supply'])
            demand = int(row['demand'])
            gap_change_pct = row.get('gap_change_pct', 0)
            
            category_plan = {
                'category': category,
                'gap_score': gap_score,
                'gap_status': row['gap_status'],
                'supply': supply,
                'demand': demand,
                'gap_change_pct': gap_change_pct,
                'operational_actions': self.generate_operational_actions(
                    category, gap_score, supply, demand
                ),
                'strategic_actions': self.generate_strategic_actions(
                    category, gap_score, gap_change_pct
                ),
                'platform_actions': self.generate_platform_actions(category, gap_score),
                'user_engagement_actions': self.generate_user_engagement_actions(
                    category, gap_score
                )
            }
            action_plans.append(category_plan)
        
        return {
            'week': week_number,
            'date': datetime.now().strftime("%Y-%m-%d"),
            'total_categories': len(gap_df),
            'action_plans': action_plans
        }

    def export_action_plan_json(self, action_plan_dict: dict, 
                               week_number: int = None) -> str:
        if week_number is None:
            week_number = action_plan_dict.get('week', datetime.now().isocalendar()[1])
        
        json_path = self.output_dir / f"action_plan_week_{week_number}.json"
        with open(json_path, 'w') as f:
            json.dump(action_plan_dict, f, indent=2)
        
        return str(json_path)

    def export_action_plan_text(self, action_plan_dict: dict,
                               week_number: int = None) -> str:
        if week_number is None:
            week_number = action_plan_dict.get('week', datetime.now().isocalendar()[1])
        
        text_path = self.output_dir / f"action_plan_week_{week_number}.txt"
        
        with open(text_path, 'w') as f:
            f.write("=" * 100 + "\n")
            f.write(f"ACTION PLAN - WEEK {week_number} ({action_plan_dict['date']})\n")
            f.write("=" * 100 + "\n\n")
            
            f.write(f"Total Categories Monitored: {action_plan_dict['total_categories']}\n\n")
            
            for plan in action_plan_dict['action_plans']:
                f.write("-" * 100 + "\n")
                f.write(f"Category: {plan['category']}\n")
                f.write(f"Gap Score: {plan['gap_score']:.2f} | Status: {plan['gap_status']}\n")
                f.write(f"Supply: {plan['supply']:,} | Demand: {plan['demand']:,}\n")
                f.write(f"Gap Change: {plan['gap_change_pct']:+.1f}%\n\n")
                
                f.write("OPERATIONAL ACTIONS (Immediate):\n")
                for i, action in enumerate(plan['operational_actions'], 1):
                    f.write(f"  {i}. {action}\n")
                f.write("\n")
                
                f.write("STRATEGIC ACTIONS (Medium-term):\n")
                for i, action in enumerate(plan['strategic_actions'], 1):
                    f.write(f"  {i}. {action}\n")
                f.write("\n")
                
                f.write("PLATFORM OPTIMIZATION:\n")
                for i, action in enumerate(plan['platform_actions'], 1):
                    f.write(f"  {i}. {action}\n")
                f.write("\n")
                
                f.write("USER ENGAGEMENT:\n")
                for i, action in enumerate(plan['user_engagement_actions'], 1):
                    f.write(f"  {i}. {action}\n")
                f.write("\n")
        
        return str(text_path)
