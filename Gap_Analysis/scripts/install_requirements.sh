#!/bin/bash

echo "Installing required packages for Gap Analysis project..."
echo "=========================================="

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing required packages..."
pip install plotly kaleido pandas numpy openpyxl matplotlib seaborn jupyter ipykernel

# Register kernel for Jupyter
echo "Registering kernel for Jupyter..."
python -m ipykernel install --user --name=gap_analysis --display-name="Python (Gap Analysis)"

echo ""
echo "=========================================="
echo "✓ Installation complete!"
echo ""
echo "To use the environment:"
echo "1. Select 'Python (Gap Analysis)' as your kernel in Jupyter/VSCode"
echo "2. Or activate manually: source venv/bin/activate"
echo "=========================================="
