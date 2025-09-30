#!/bin/bash

# JKLoger Documentation Generation Script
# This script validates and generates documentation for the JKLoger project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/Docs"
EXAMPLE_DIR="$PROJECT_ROOT/Example"

echo -e "${BLUE}🚀 JKLoger Documentation Generator${NC}"
echo "=================================================="
echo "Project Root: $PROJECT_ROOT"
echo "Documentation: $DOCS_DIR"
echo ""

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Function to check if file exists and is not empty
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        if [ -s "$file" ]; then
            print_status "OK" "$description exists and has content"
            return 0
        else
            print_status "ERROR" "$description exists but is empty"
            return 1
        fi
    else
        print_status "ERROR" "$description is missing"
        return 1
    fi
}

# Function to count lines in file
count_lines() {
    local file=$1
    if [ -f "$file" ]; then
        wc -l < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# Function to count code examples in file
count_examples() {
    local file=$1
    if [ -f "$file" ]; then
        grep -c '```objc\|```swift\|```ruby\|```bash' "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

echo -e "${BLUE}📋 Checking Documentation Files${NC}"
echo "--------------------------------------------------"

# Check core documentation files
DOCS_STATUS=0

# Required documentation files
REQUIRED_DOCS=(
    "$DOCS_DIR/README.md:Documentation Index"
    "$DOCS_DIR/GettingStarted.md:Getting Started Guide"
    "$DOCS_DIR/API.md:API Reference"
    "$DOCS_DIR/Usage.md:Usage Guide"
    "$DOCS_DIR/AdvancedFeatures.md:Advanced Features"
    "$DOCS_DIR/Performance.md:Performance Guide"
    "$DOCS_DIR/FAQ.md:FAQ"
    "$DOCS_DIR/Troubleshooting.md:Troubleshooting Guide"
)

for entry in "${REQUIRED_DOCS[@]}"; do
    file="${entry%:*}"
    description="${entry#*:}"
    if ! check_file "$file" "$description"; then
        DOCS_STATUS=1
    fi
done

# Check project files
echo ""
echo -e "${BLUE}📋 Checking Project Files${NC}"
echo "--------------------------------------------------"

PROJECT_STATUS=0

PROJECT_FILES=(
    "$PROJECT_ROOT/README.md:Main README"
    "$PROJECT_ROOT/CHANGELOG.md:Changelog"
    "$PROJECT_ROOT/CONTRIBUTING.md:Contributing Guide"
    "$PROJECT_ROOT/LICENSE:License File"
    "$PROJECT_ROOT/JKLoger.podspec:CocoaPods Spec"
    "$PROJECT_ROOT/Package.swift:Swift Package Manager"
    "$PROJECT_ROOT/PROJECT_STATUS.md:Project Status"
)

for entry in "${PROJECT_FILES[@]}"; do
    file="${entry%:*}"
    description="${entry#*:}"
    if ! check_file "$file" "$description"; then
        PROJECT_STATUS=1
    fi
done

# Generate documentation statistics
echo ""
echo -e "${BLUE}📊 Documentation Statistics${NC}"
echo "--------------------------------------------------"

TOTAL_LINES=0
TOTAL_EXAMPLES=0

for entry in "${REQUIRED_DOCS[@]}"; do
    file="${entry%:*}"
    if [ -f "$file" ]; then
        lines=$(count_lines "$file")
        examples=$(count_examples "$file")
        TOTAL_LINES=$((TOTAL_LINES + lines))
        TOTAL_EXAMPLES=$((TOTAL_EXAMPLES + examples))
        
        filename=$(basename "$file")
        printf "%-25s %5d lines, %2d examples\n" "$filename" "$lines" "$examples"
    fi
done

echo "--------------------------------------------------"
printf "%-25s %5d lines, %2d examples\n" "TOTAL DOCUMENTATION" "$TOTAL_LINES" "$TOTAL_EXAMPLES"

# Check example project
echo ""
echo -e "${BLUE}📱 Checking Example Project${NC}"
echo "--------------------------------------------------"

EXAMPLE_STATUS=0

if [ -d "$EXAMPLE_DIR" ]; then
    print_status "OK" "Example directory exists"
    
    # Check for key example files
    if [ -f "$EXAMPLE_DIR/README.md" ]; then
        print_status "OK" "Example README exists"
    else
        print_status "ERROR" "Example README missing"
        EXAMPLE_STATUS=1
    fi
    
    if [ -f "$EXAMPLE_DIR/JKLogerExample.xcodeproj/project.pbxproj" ]; then
        print_status "OK" "Example Xcode project exists"
    else
        print_status "ERROR" "Example Xcode project missing"
        EXAMPLE_STATUS=1
    fi
else
    print_status "ERROR" "Example directory missing"
    EXAMPLE_STATUS=1
fi

# Validate documentation links
echo ""
echo -e "${BLUE}🔗 Validating Documentation Links${NC}"
echo "--------------------------------------------------"

LINK_STATUS=0

# Function to check internal links
check_internal_links() {
    local file=$1
    local filename=$(basename "$file")
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Extract markdown links [text](path) - only .md files without anchors
    local links=$(grep -o '\[.*\]([^)#]*\.md)' "$file" 2>/dev/null || true)
    local broken_links=0
    
    while IFS= read -r link; do
        if [ -n "$link" ]; then
            # Extract the path from [text](path)
            local path=$(echo "$link" | sed 's/.*(\([^)]*\)).*/\1/')
            
            # Handle relative paths
            if [[ "$path" == ../* ]]; then
                local full_path="$PROJECT_ROOT/${path#../}"
            elif [[ "$path" == ./* ]]; then
                local full_path="$DOCS_DIR/${path#./}"
            else
                local full_path="$DOCS_DIR/$path"
            fi
            
            if [ ! -f "$full_path" ]; then
                print_status "ERROR" "Broken link in $filename: $path"
                broken_links=$((broken_links + 1))
                LINK_STATUS=1
            fi
        fi
    done <<< "$links"
    
    if [ $broken_links -eq 0 ]; then
        print_status "OK" "$filename - All internal links valid"
    fi
}

# Check links in all documentation files
for entry in "${REQUIRED_DOCS[@]}"; do
    file="${entry%:*}"
    check_internal_links "$file"
done

# Generate final report
echo ""
echo -e "${BLUE}📋 Final Report${NC}"
echo "=================================================="

OVERALL_STATUS=0

if [ $DOCS_STATUS -eq 0 ]; then
    print_status "OK" "All documentation files present"
else
    print_status "ERROR" "Some documentation files missing"
    OVERALL_STATUS=1
fi

if [ $PROJECT_STATUS -eq 0 ]; then
    print_status "OK" "All project files present"
else
    print_status "ERROR" "Some project files missing"
    OVERALL_STATUS=1
fi

if [ $EXAMPLE_STATUS -eq 0 ]; then
    print_status "OK" "Example project complete"
else
    print_status "ERROR" "Example project incomplete"
    OVERALL_STATUS=1
fi

if [ $LINK_STATUS -eq 0 ]; then
    print_status "OK" "All documentation links valid"
else
    print_status "ERROR" "Some documentation links broken"
    OVERALL_STATUS=1
fi

echo ""
echo "Documentation Statistics:"
echo "  📄 Total Files: ${#REQUIRED_DOCS[@]}"
echo "  📝 Total Lines: $TOTAL_LINES"
echo "  💻 Code Examples: $TOTAL_EXAMPLES"
echo "  🔗 Link Validation: $([ $LINK_STATUS -eq 0 ] && echo "✅ Passed" || echo "❌ Failed")"

echo ""
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e "${GREEN}🎉 Documentation Generation Complete!${NC}"
    echo -e "${GREEN}✅ All documentation files are present and valid.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review the generated documentation"
    echo "  2. Test the example project"
    echo "  3. Validate all links work correctly"
    echo "  4. Consider generating HTML documentation if needed"
else
    echo -e "${RED}❌ Documentation Generation Failed!${NC}"
    echo -e "${RED}Please fix the issues above and run again.${NC}"
fi

echo ""
echo "Documentation available at: $DOCS_DIR"
echo "Example project available at: $EXAMPLE_DIR"

exit $OVERALL_STATUS