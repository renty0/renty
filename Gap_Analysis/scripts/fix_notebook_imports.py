#!/usr/bin/env python3
"""
Script to fix import statements in all Jupyter notebooks after code reorganization.
"""

import json
import sys
from pathlib import Path

# Mapping of old imports to new imports
IMPORT_REPLACEMENTS = {
    # Old module names with underscores to new dotted paths
    "from data_loader import": "from data.loader import",
    "from data_quality import": "from data.quality import",
    "from data_db_model import": "from data.db_model import",
    
    # Old module paths to new reorganized paths
    "from supply.demand import": "from analysis.supply_demand import",
    "from gap.score import": "from analysis.gap_score import",
    "from gap.visualizer import": "from visualization.static.gap_visualizer import",
}


def fix_notebook_imports(notebook_path: Path) -> bool:
    """
    Fix import statements in a Jupyter notebook.
    
    Args:
        notebook_path: Path to the notebook file
        
    Returns:
        True if changes were made, False otherwise
    """
    print(f"\nProcessing: {notebook_path.name}")
    
    # Load notebook
    with open(notebook_path, 'r', encoding='utf-8') as f:
        notebook = json.load(f)
    
    changes_made = False
    cells_modified = 0
    
    # Process each cell
    for cell in notebook.get('cells', []):
        if cell.get('cell_type') == 'code':
            source = cell.get('source', [])
            
            # Convert source to string for easier processing
            if isinstance(source, list):
                source_str = ''.join(source)
            else:
                source_str = source
            
            # Apply replacements
            modified_source = source_str
            for old_import, new_import in IMPORT_REPLACEMENTS.items():
                if old_import in modified_source:
                    modified_source = modified_source.replace(old_import, new_import)
                    changes_made = True
            
            # If changes were made, update the cell
            if modified_source != source_str:
                cells_modified += 1
                # Convert back to list format (preserving line structure)
                if isinstance(source, list):
                    cell['source'] = modified_source.splitlines(keepends=True)
                else:
                    cell['source'] = modified_source
    
    # Save if changes were made
    if changes_made:
        # Backup original
        backup_path = notebook_path.with_suffix('.ipynb.backup')
        if not backup_path.exists():
            print(f"  📦 Creating backup: {backup_path.name}")
            with open(backup_path, 'w', encoding='utf-8') as f:
                json.dump(notebook, f, indent=1, ensure_ascii=False)
        
        # Save modified notebook
        with open(notebook_path, 'w', encoding='utf-8') as f:
            json.dump(notebook, f, indent=1, ensure_ascii=False)
        
        print(f"  ✅ Fixed {cells_modified} cell(s)")
        return True
    else:
        print(f"  ℹ️  No changes needed")
        return False


def main():
    # Get notebooks directory
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent
    notebooks_dir = project_dir / "notebooks"
    
    if not notebooks_dir.exists():
        print(f"❌ Notebooks directory not found: {notebooks_dir}")
        sys.exit(1)
    
    print(f"🔍 Scanning notebooks in: {notebooks_dir}")
    print(f"📝 Import replacements to apply:")
    for old, new in IMPORT_REPLACEMENTS.items():
        print(f"   {old} → {new}")
    
    # Find all notebooks
    notebooks = sorted(notebooks_dir.glob("*.ipynb"))
    
    if not notebooks:
        print(f"❌ No notebooks found in {notebooks_dir}")
        sys.exit(1)
    
    print(f"\n📚 Found {len(notebooks)} notebook(s)")
    
    # Process each notebook
    modified_count = 0
    for notebook_path in notebooks:
        if fix_notebook_imports(notebook_path):
            modified_count += 1
    
    print(f"\n" + "="*60)
    print(f"✨ Summary: Modified {modified_count} of {len(notebooks)} notebook(s)")
    print(f"📦 Backups saved with .ipynb.backup extension")
    print(f"="*60)


if __name__ == "__main__":
    main()
