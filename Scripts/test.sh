#!/bin/bash

# JKLoger Test Script
# This script runs all tests for the JKLoger project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$PROJECT_ROOT/test_results"
WORKSPACE="JKLoger.xcworkspace"
SCHEME="JKLoger"

echo -e "${BLUE}🧪 JKLoger Test Suite${NC}"
echo "=================================================="
echo "Project Root: $PROJECT_ROOT"
echo "Test Results: $TEST_DIR"
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

# Clean test results directory
echo -e "${BLUE}🧹 Preparing Test Environment${NC}"
echo "--------------------------------------------------"
if [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
    print_status "OK" "Removed existing test results"
fi
mkdir -p "$TEST_DIR"
print_status "OK" "Created test results directory"

# Run unit tests
echo ""
echo -e "${BLUE}🧪 Running Unit Tests${NC}"
echo "--------------------------------------------------"
xcodebuild test \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,OS=17.0,name=iPhone 15 Pro' \
    -derivedDataPath "$TEST_DIR/DerivedData" \
    -resultBundlePath "$TEST_DIR/TestResults.xcresult" \
    -enableCodeCoverage YES \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    PROVISIONING_PROFILE="" \
    | xcpretty --report junit --output "$TEST_DIR/junit.xml"

UNIT_TEST_EXIT_CODE=$?

if [ $UNIT_TEST_EXIT_CODE -eq 0 ]; then
    print_status "OK" "Unit tests passed"
else
    print_status "ERROR" "Unit tests failed"
fi

# Run performance tests
echo ""
echo -e "${BLUE}⚡ Running Performance Tests${NC}"
echo "--------------------------------------------------"

# Compile performance test
cd "$PROJECT_ROOT"
clang -framework Foundation -o "$TEST_DIR/performance_test" \
    comprehensive_test.m \
    JKLoger/*.m \
    JKLoger/*/*.m \
    -I JKLoger \
    -I JKLoger/Destinations \
    -I JKLoger/Formatters

if [ $? -eq 0 ]; then
    print_status "OK" "Performance test compiled successfully"
    
    # Run performance test
    "$TEST_DIR/performance_test" > "$TEST_DIR/performance_results.txt" 2>&1
    PERF_EXIT_CODE=$?
    
    if [ $PERF_EXIT_CODE -eq 0 ]; then
        print_status "OK" "Performance tests completed"
        
        # Extract key metrics
        if [ -f "$TEST_DIR/performance_results.txt" ]; then
            echo "Performance Results:"
            grep -E "(messages took|Memory usage|Test completed)" "$TEST_DIR/performance_results.txt" | head -10
        fi
    else
        print_status "WARNING" "Performance tests had issues (exit code: $PERF_EXIT_CODE)"
    fi
else
    print_status "ERROR" "Performance test compilation failed"
    PERF_EXIT_CODE=1
fi

# Run static analysis
echo ""
echo -e "${BLUE}🔍 Running Static Analysis${NC}"
echo "--------------------------------------------------"
xcodebuild analyze \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,OS=17.0,name=iPhone 15 Pro' \
    -derivedDataPath "$TEST_DIR/AnalyzeDerivedData" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    PROVISIONING_PROFILE="" \
    | xcpretty

STATIC_ANALYSIS_EXIT_CODE=$?

if [ $STATIC_ANALYSIS_EXIT_CODE -eq 0 ]; then
    print_status "OK" "Static analysis passed"
else
    print_status "WARNING" "Static analysis found issues"
fi

# Test CocoaPods integration
echo ""
echo -e "${BLUE}🍫 Testing CocoaPods Integration${NC}"
echo "--------------------------------------------------"
if command -v pod >/dev/null 2>&1; then
    pod lib lint JKLoger.podspec --allow-warnings --quick > "$TEST_DIR/cocoapods_lint.log" 2>&1
    COCOAPODS_EXIT_CODE=$?
    
    if [ $COCOAPODS_EXIT_CODE -eq 0 ]; then
        print_status "OK" "CocoaPods lint passed"
    else
        print_status "WARNING" "CocoaPods lint failed"
        echo "See $TEST_DIR/cocoapods_lint.log for details"
    fi
else
    print_status "WARNING" "CocoaPods not installed, skipping lint"
    COCOAPODS_EXIT_CODE=0
fi

# Test Swift Package Manager
echo ""
echo -e "${BLUE}📦 Testing Swift Package Manager${NC}"
echo "--------------------------------------------------"
swift build > "$TEST_DIR/spm_build.log" 2>&1
SPM_EXIT_CODE=$?

if [ $SPM_EXIT_CODE -eq 0 ]; then
    print_status "OK" "Swift Package Manager build passed"
else
    print_status "WARNING" "Swift Package Manager build failed"
    echo "See $TEST_DIR/spm_build.log for details"
fi

# Test documentation
echo ""
echo -e "${BLUE}📚 Testing Documentation${NC}"
echo "--------------------------------------------------"
chmod +x Scripts/generate_docs.sh
./Scripts/generate_docs.sh > "$TEST_DIR/docs_validation.log" 2>&1
DOCS_EXIT_CODE=$?

if [ $DOCS_EXIT_CODE -eq 0 ]; then
    print_status "OK" "Documentation validation passed"
else
    print_status "WARNING" "Documentation validation failed"
    echo "See $TEST_DIR/docs_validation.log for details"
fi

# Test example project
echo ""
echo -e "${BLUE}📱 Testing Example Project${NC}"
echo "--------------------------------------------------"
cd "$PROJECT_ROOT/Example"
xcodebuild build \
    -workspace JKLogerExample.xcworkspace \
    -scheme JKLogerExample \
    -destination 'platform=iOS Simulator,OS=17.0,name=iPhone 15 Pro' \
    -derivedDataPath "$TEST_DIR/ExampleDerivedData" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    PROVISIONING_PROFILE="" \
    > "$TEST_DIR/example_build.log" 2>&1

EXAMPLE_EXIT_CODE=$?

if [ $EXAMPLE_EXIT_CODE -eq 0 ]; then
    print_status "OK" "Example project build passed"
else
    print_status "ERROR" "Example project build failed"
    echo "See $TEST_DIR/example_build.log for details"
fi

# Generate test report
echo ""
echo -e "${BLUE}📊 Test Report${NC}"
echo "=================================================="

# Count test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

if [ -f "$TEST_DIR/junit.xml" ]; then
    TOTAL_TESTS=$(grep -o 'tests="[0-9]*"' "$TEST_DIR/junit.xml" | grep -o '[0-9]*' | head -1)
    FAILED_TESTS=$(grep -o 'failures="[0-9]*"' "$TEST_DIR/junit.xml" | grep -o '[0-9]*' | head -1)
    PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS))
fi

echo "Test Results Summary:"
echo "  🧪 Unit Tests: $PASSED_TESTS/$TOTAL_TESTS passed"
echo "  ⚡ Performance Tests: $([ $PERF_EXIT_CODE -eq 0 ] && echo "✅ Passed" || echo "❌ Failed")"
echo "  🔍 Static Analysis: $([ $STATIC_ANALYSIS_EXIT_CODE -eq 0 ] && echo "✅ Passed" || echo "⚠️  Issues Found")"
echo "  🍫 CocoaPods Lint: $([ $COCOAPODS_EXIT_CODE -eq 0 ] && echo "✅ Passed" || echo "⚠️  Issues Found")"
echo "  📦 SPM Build: $([ $SPM_EXIT_CODE -eq 0 ] && echo "✅ Passed" || echo "⚠️  Failed")"
echo "  📚 Documentation: $([ $DOCS_EXIT_CODE -eq 0 ] && echo "✅ Passed" || echo "⚠️  Issues Found")"
echo "  📱 Example Project: $([ $EXAMPLE_EXIT_CODE -eq 0 ] && echo "✅ Passed" || echo "❌ Failed")"

# Calculate overall status
OVERALL_EXIT_CODE=0
if [ $UNIT_TEST_EXIT_CODE -ne 0 ] || [ $EXAMPLE_EXIT_CODE -ne 0 ]; then
    OVERALL_EXIT_CODE=1
fi

echo ""
echo "Test Artifacts:"
echo "  📄 JUnit Report: $TEST_DIR/junit.xml"
echo "  📊 Test Results: $TEST_DIR/TestResults.xcresult"
echo "  ⚡ Performance Results: $TEST_DIR/performance_results.txt"
echo "  📋 All Logs: $TEST_DIR/"

echo ""
if [ $OVERALL_EXIT_CODE -eq 0 ]; then
    print_status "OK" "All critical tests passed!"
    echo ""
    echo "🎉 Test suite completed successfully!"
    echo ""
    echo "Next steps:"
    echo "  1. Review test coverage in Xcode"
    echo "  2. Check performance results for regressions"
    echo "  3. Address any warnings from static analysis"
    echo "  4. Ready for release if all tests pass"
else
    print_status "ERROR" "Some critical tests failed!"
    echo ""
    echo "❌ Test suite completed with failures!"
    echo ""
    echo "Required actions:"
    echo "  1. Fix failing unit tests"
    echo "  2. Resolve example project build issues"
    echo "  3. Re-run test suite"
fi

exit $OVERALL_EXIT_CODE