# Installation Guide

## Quick Start

### Option 1: Using Installation Script (Recommended)

**Linux/Mac:**
```bash
cd /path/to/Gap_Analysis
chmod +x scripts/install_requirements.sh
./scripts/install_requirements.sh
```

**Windows:**
```cmd
cd \path\to\Gap_Analysis
scripts\install_requirements.bat
```

### Option 2: Manual Virtual Environment Setup

1. Create virtual environment:
```bash
python3 -m venv venv
```

2. Activate it:
```bash
# Linux/Mac
source venv/bin/activate

# Windows
venv\Scripts\activate
```

3. Install packages:
```bash
pip install -r requirements.txt
```

4. Register Jupyter kernel:
```bash
python -m ipykernel install --user --name=gap_analysis --display-name="Python (Gap Analysis)"
```

### Option 3: User Installation (No Virtual Environment)

```bash
pip install --user -r requirements.txt
```

## Using the Notebooks

1. Open VSCode or Jupyter
2. Select kernel: **Python (Gap Analysis)**
3. Run the notebooks

## Troubleshooting

**Error: externally-managed-environment**
- Use Option 1 or Option 2 (virtual environment)
- Avoid system-wide pip installation

**Error: kaleido not found**
- PNG export will fallback to HTML
- Install kaleido separately: `pip install --user kaleido`

**Kernel not found**
- Run: `python -m ipykernel install --user --name=gap_analysis`
- Restart VSCode/Jupyter

## Verification

Run this in a Python cell:
```python
import plotly
import kaleido
import pandas
import numpy

print("All packages installed successfully!")
```
