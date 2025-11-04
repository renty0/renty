from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent

DATA_DIR = PROJECT_ROOT / "data"
PROCESSED_DATA_DIR = DATA_DIR / "processed"
RESULTS_DIR = PROJECT_ROOT / "results"

DEFAULT_EXCEL_FILE = PROCESSED_DATA_DIR / "Project Data.xlsx"

for directory in [DATA_DIR, PROCESSED_DATA_DIR, RESULTS_DIR]:
    directory.mkdir(parents=True, exist_ok=True)


TARGET_MULTIPLIERS = {
    "Total Revenue": 1.10,
    "Average Order Value": 1.08,
    "Average Product Price": 1.05,
    "Average Discount Rate": 0.95,
    "High Income Customer Ratio": 1.10,
    "Homeowner Percentage": 1.10,
    "Total Orders": 1.05,
    "Total Customers": 1.05,
    "Orders per Customer": 1.05,
    "Revenue per Customer": 1.08,
    "Profit Margin": 1.05
}
