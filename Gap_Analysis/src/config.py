from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent

DATA_DIR = PROJECT_ROOT / "data"
PROCESSED_DATA_DIR = DATA_DIR / "processed"
RESULTS_DIR = PROJECT_ROOT / "results"

DEFAULT_EXCEL_FILE = PROCESSED_DATA_DIR / "Project Data.xlsx"

for directory in [DATA_DIR, PROCESSED_DATA_DIR, RESULTS_DIR]:
    directory.mkdir(parents=True, exist_ok=True)
