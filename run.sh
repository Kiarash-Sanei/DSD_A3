#!/bin/bash

# Make all shell scripts executable
echo "Making all shell scripts executable..."
find . -type f -name "*.sh" -exec chmod +x {} \;

# Find and run all shell scripts (excluding this script itself)
echo "Running all shell scripts..."
failed_scripts=()

for script in $(find . -type f -name "*.sh" | grep -v "^\./run\.sh$" | sort); do
    echo "=========================================="
    echo "Running: $script"
    echo "=========================================="
    
    # Get the directory of the script
    script_dir=$(dirname "$script")
    script_name=$(basename "$script")
    
    # Change to the script's directory and run it
    cd "$script_dir"
    if "./$script_name"; then
        echo "✅ $script completed successfully"
    else
        echo "❌ $script failed with exit code $?"
        failed_scripts+=("$script")
    fi
    cd - > /dev/null  # Return to original directory
    echo ""
done

# Clean up generated text files (only in current directory)
echo "Cleaning up generated text files..."
rm -f *.txt

# Summary
echo "=========================================="
echo "SUMMARY"
echo "=========================================="

if [ ${#failed_scripts[@]} -eq 0 ]; then
    echo "✅ All scripts completed successfully!"
    exit 0
else
    echo "❌ The following scripts failed:"
    for script in "${failed_scripts[@]}"; do
        echo "  - $script"
    done
    exit 1
fi