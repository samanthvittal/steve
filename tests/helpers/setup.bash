# tests/helpers/setup.bash

# Create isolated test environment
common_setup() {
    TEST_DIR=$(mktemp -d)
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_DIR/fakehome"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.steve/commands"

    # Create a fake version file
    echo "0.1.0" > "$HOME/.steve/version"

    # Create all 8 fake command files
    for cmd in init design prd plan-phase next-task test-checkpoint complete-phase resume; do
        echo "# steve:${cmd}" > "$HOME/.steve/commands/steve:${cmd}.md"
    done

    # Create a fake project directory
    PROJECT_DIR="${TEST_DIR}/test-project"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"

    # Path to the steve CLI under test
    STEVE_CLI="${BATS_TEST_DIRNAME}/../steve"

    # Save original PATH for teardown
    ORIGINAL_PATH="$PATH"
}

common_teardown() {
    export HOME="$ORIGINAL_HOME"
    export PATH="$ORIGINAL_PATH"
    rm -rf "$TEST_DIR"
}
