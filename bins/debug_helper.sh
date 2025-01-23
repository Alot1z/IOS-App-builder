#!/bin/bash

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to inspect binary
inspect_binary() {
    local binary="$1"
    local output_file="$2"

    echo "=== Binary Info ===" >> "${output_file}"
    # Use ldid to get binary info
    "$TOOLS_DIR/ldid" -e "${binary}" >> "${output_file}"
    
    echo "" >> "${output_file}"
    echo "=== Code Signature ===" >> "${output_file}"
    "$TOOLS_DIR/ldid" -S "${binary}" >> "${output_file}"
    
    echo "" >> "${output_file}"
    echo "=== Binary Patches ===" >> "${output_file}"
    # Check choma patches
    "$TOOLS_DIR/choma" --check "${binary}" >> "${output_file}"
}

# Main execution
if [ $# -lt 2 ]; then
    echo "Usage: $0 <binary_path> <output_file>"
    exit 1
fi

binary="$1"
output_file="$2"

if [ ! -f "$binary" ]; then
    echo "Error: Binary not found at $binary"
    exit 1
fi

inspect_binary "$binary" "$output_file"
echo "Debug info written to $output_file"
