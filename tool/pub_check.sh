#!/bin/bash
# pub_check.sh - Validate packages meet 160/160 pub.dev points using pana
#
# This script validates each package in the monorepo to ensure it meets
# pub.dev publication standards. It runs the full validation flow:
# 1. Required files check (LICENSE, README.md, CHANGELOG.md)
# 2. Dart analysis (dart analyze --fatal-infos)
# 3. Formatting check (dart format --set-exit-if-changed)
# 4. Dependency freshness check (dart pub outdated)
# 5. Tests (dart test or flutter test, depending on package type)
# 6. Pana validation for 160/160 pub points

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
if ! source "$SCRIPT_DIR/_common.sh"; then
    echo "Error: Failed to source _common.sh from $SCRIPT_DIR" >&2
    exit 1
fi

# Resolve package directory to an absolute path so repeated `cd "$PACKAGE_DIR"` works
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
raw_dir="${MELOS_PACKAGE_PATH:-.}"
if [ "$raw_dir" = '.' ]; then
	PACKAGE_DIR="$(pwd)"
elif [ "${raw_dir#/}" = "$raw_dir" ]; then
	PACKAGE_DIR="$REPO_ROOT/$raw_dir"
else
	PACKAGE_DIR="$raw_dir"
fi
PACKAGE_NAME=$(get_package_name "$PACKAGE_DIR")

# Validate package directory
if ! validate_package_dir "$PACKAGE_DIR"; then
    exit 1
fi

log_step "Checking $PACKAGE_NAME..."

# Step 1: Check required files (Dart conventions - 30 points)
log_step "  Checking required files..."
if ! check_required_files "$PACKAGE_DIR"; then
    echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:missing_files" >&2
    exit 1
fi

# Step 2: Run Dart analysis
log_step "  Running dart analyze..."
cd "$PACKAGE_DIR"
ANALYZE_OUTPUT=""
if ! ANALYZE_OUTPUT=$(dart analyze --fatal-infos 2>&1); then
    log_error "$PACKAGE_NAME has analysis errors or warnings"
    echo "$ANALYZE_OUTPUT" | head -20 >&2
    if [ "$(echo "$ANALYZE_OUTPUT" | wc -l)" -gt 20 ]; then
        log_info "... (truncated, run 'dart analyze' in $PACKAGE_DIR for full output)"
    fi
    echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:analysis_errors" >&2
    exit 1
fi

# Step 3: Check formatting
log_step "  Checking formatting..."
cd "$PACKAGE_DIR"
FORMAT_OUTPUT=""
if ! FORMAT_OUTPUT=$(dart format --set-exit-if-changed . 2>&1); then
    log_error "$PACKAGE_NAME has formatting issues"
    echo "$FORMAT_OUTPUT" | head -10 >&2
    log_info "Run 'dart format .' in $PACKAGE_DIR to fix"
    echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:formatting_issues" >&2
    exit 1
fi

# Step 4: Check dependency freshness
check_dependency_freshness "$PACKAGE_DIR"

# Step 5: Run tests (if test directory has test files)
if [ -d "$PACKAGE_DIR/test" ]; then
    test_files_found=$(find "$PACKAGE_DIR/test" -type f -name "*_test.dart" -print -quit 2>/dev/null || true)
    if [ -n "$test_files_found" ]; then
        log_step "  Running tests..."
        cd "$PACKAGE_DIR"
        TEST_CMD=$(get_test_command "$PACKAGE_DIR")
        TEST_OUTPUT=""
        if ! TEST_OUTPUT=$($TEST_CMD 2>&1); then
            log_error "$PACKAGE_NAME has failing tests"
            echo "$TEST_OUTPUT" | tail -30 >&2
            log_info "Run '$TEST_CMD' in $PACKAGE_DIR for details"
            echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:test_failures" >&2
            exit 1
        fi
    else
        log_info "  No test files found, skipping tests..."
    fi
fi

# Step 6: Run pana for 160/160 pub points validation
log_step "  Running pana analysis (this may take 30-60 seconds)..."
if ! ensure_pana; then
    exit 1
fi

# Pana analyzes the package outside the monorepo workspace; `resolution: workspace` then
# prevents any pub get. Strip it temporarily (restore on exit).
PANA_PUBSPEC_BAK="$PACKAGE_DIR/pubspec.yaml.beforepana"
pana_pubspec_strip_workspace=false
if grep -q '^resolution: workspace$' "$PACKAGE_DIR/pubspec.yaml" 2>/dev/null; then
    cp "$PACKAGE_DIR/pubspec.yaml" "$PANA_PUBSPEC_BAK"
    grep -v '^resolution: workspace$' "$PANA_PUBSPEC_BAK" > "$PACKAGE_DIR/pubspec.yaml"
    pana_pubspec_strip_workspace=true
    (cd "$PACKAGE_DIR" && dart pub get >/dev/null) || true
fi

restore_pana_pubspec() {
    if [ "$pana_pubspec_strip_workspace" = true ] && [ -f "$PANA_PUBSPEC_BAK" ]; then
        mv "$PANA_PUBSPEC_BAK" "$PACKAGE_DIR/pubspec.yaml"
        (cd "$PACKAGE_DIR" && dart pub get >/dev/null) || true
    fi
}
trap restore_pana_pubspec EXIT

# Run pana and capture output
PANA_OUTPUT=""
if ! PANA_OUTPUT=$(cd "$PACKAGE_DIR" && dart pub global run pana --no-warning 2>&1); then
    trap - EXIT
    restore_pana_pubspec
    log_error "Pana validation failed for $PACKAGE_NAME"
    echo "$PANA_OUTPUT" >&2
    echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:pana_error" >&2
    exit 1
fi

trap - EXIT
restore_pana_pubspec

# Extract pub points
PUB_POINTS=$(extract_pub_points "$PANA_OUTPUT")

if [ "$PUB_POINTS" = "0" ]; then
    log_error "Failed to extract pub points from pana output for $PACKAGE_NAME"
    echo "$PANA_OUTPUT" >&2
    echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:parse_error" >&2
    exit 1
fi

if [ "$PUB_POINTS" -lt "$REQUIRED_PUB_POINTS" ]; then
    log_error "$PACKAGE_NAME scored $PUB_POINTS/$REQUIRED_PUB_POINTS pub points (required: $REQUIRED_PUB_POINTS/$REQUIRED_PUB_POINTS)"
    log_info "Pana output summary:"
    echo "$PANA_OUTPUT" | tail -"$PANA_OUTPUT_TAIL_LINES" >&2
    # Output machine-readable failure indicator for parsing
    echo "PUB_CHECK_RESULT:FAIL:$PACKAGE_NAME:$PUB_POINTS" >&2
    exit 1
fi

log_success "$PACKAGE_NAME: $PUB_POINTS/$REQUIRED_PUB_POINTS pub points"
# Output machine-readable success indicator for parsing
echo "PUB_CHECK_RESULT:SUCCESS:$PACKAGE_NAME:$PUB_POINTS" >&2
exit 0
