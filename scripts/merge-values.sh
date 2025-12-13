#!/bin/bash

# merge-values.sh - Merge values from local Helm charts
# Usage: ./merge-values.sh <umbrella-chart-dir> <subchart1-path> <subchart2-path> [subchart3-path] ...

set -e

# Check arguments
if [ $# -lt 2 ]; then
    echo "Error: Need umbrella chart directory and at least one subchart" >&2
    echo "Usage: $0 <umbrella-chart-dir> <subchart1> <subchart2> [subchart3] ..." >&2
    exit 1
fi

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is required but not installed." >&2
    exit 1
fi

# First argument is the umbrella chart
umbrella_chart="$1"
shift

# Check if umbrella Chart.yaml exists
umbrella_chart_yaml="${umbrella_chart}/Chart.yaml"
if [ ! -f "$umbrella_chart_yaml" ]; then
    echo "Error: Chart.yaml not found in umbrella chart: $umbrella_chart_yaml" >&2
    exit 1
fi

# Print header
cat << 'EOF'
# This file is auto-generated. Do not edit manually.

EOF

# Collect all global values in a variable
global_sections=""

# Process each subchart
for chart_path in "$@"; do
    chart_basename=$(basename "$chart_path")

    # Check if chart directory exists
    if [ ! -d "$chart_path" ]; then
        echo "Error: Chart directory $chart_path not found" >&2
        exit 1
    fi

    # Find the alias/name for this subchart in the umbrella Chart.yaml
    chart_key=$(yq eval ".dependencies[] | select(.name == \"$chart_basename\" or .repository == \"file://../$chart_basename\") | .alias // .name" "$umbrella_chart_yaml")

    if [ -z "$chart_key" ] || [ "$chart_key" = "null" ]; then
        echo "Error: Could not find $chart_basename in umbrella chart dependencies" >&2
        exit 1
    fi

    # Check if values.yaml exists
    values_file="${chart_path}/values.yaml"
    if [ ! -f "$values_file" ]; then
        echo "Warning: No values.yaml found for $chart_basename, skipping" >&2
        continue
    fi

    if [ ! -s "$values_file" ]; then
        echo "Warning: values.yaml is empty for $chart_basename, skipping" >&2
        continue
    fi

    # Add section header and chart values
    echo ""
    echo "# Values for $chart_key subchart"
    echo "${chart_key}:"

    # Indent the values, but extract global section separately
    yq eval 'del(.global)' "$values_file" | sed 's/^/  /'

    # Collect global values if they exist
    global_values=$(yq eval '.global' "$values_file" 2>/dev/null)
    if [ "$global_values" != "null" ] && [ -n "$global_values" ]; then
        global_sections="${global_sections}${global_values}"$'\n'
    fi

    echo "Processed $chart_basename as $chart_key" >&2
done

# Merge all global sections if any exist
if [ -n "$global_sections" ]; then
    echo ""
    echo "# Global values shared across all subcharts"
    echo "global:"
    echo "$global_sections" | yq eval-all '. as $item ireduce ({}; . * $item)' - | sed 's/^/  /'
fi
