#!/usr/bin/env bats

setup() {
    load 'helpers/setup'
    common_setup
}

teardown() {
    common_teardown
}

@test "steve version prints version" {
    run bash "$STEVE_CLI" version
    [ "$status" -eq 0 ]
    [[ "$output" == *"Steve v0.1.0"* ]]
}

@test "steve help shows usage" {
    run bash "$STEVE_CLI" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"init"* ]]
    [[ "$output" == *"update"* ]]
}

@test "steve with no args shows usage" {
    run bash "$STEVE_CLI"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "steve unknown command fails" {
    run bash "$STEVE_CLI" foobar
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown command: foobar"* ]]
}

@test "steve init fails without claude CLI" {
    # Ensure claude is not found — remove any path containing claude but keep system paths
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"
    # Make sure there's no claude in any of those dirs
    run bash "$STEVE_CLI" init
    [ "$status" -eq 1 ]
    [[ "$output" == *"Claude Code CLI not found"* ]]
}

@test "steve init fails without git repo and user declines" {
    # Mock claude to exist
    echo '#!/bin/bash' > "$HOME/.local/bin/claude"
    chmod +x "$HOME/.local/bin/claude"
    export PATH="$HOME/.local/bin:$PATH"

    # Not a git repo, simulate 'n' response via bash -c pipe
    run bash -c "echo 'n' | bash '$STEVE_CLI' init"
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires a git repository"* ]]
}

@test "steve init fails when steve commands not installed" {
    # Mock claude to exist
    echo '#!/bin/bash' > "$HOME/.local/bin/claude"
    chmod +x "$HOME/.local/bin/claude"
    export PATH="$HOME/.local/bin:$PATH"

    # Init a git repo but remove steve commands
    git init "$PROJECT_DIR" > /dev/null 2>&1
    rm -rf "$HOME/.steve/commands"

    run bash "$STEVE_CLI" init
    [ "$status" -eq 1 ]
    [[ "$output" == *"Steve commands not found"* ]]
}

@test "steve init copies commands into project" {
    # Mock claude to just exit 0
    cat > "$HOME/.local/bin/claude" <<'CLEOF'
#!/bin/bash
exit 0
CLEOF
    chmod +x "$HOME/.local/bin/claude"
    export PATH="$HOME/.local/bin:$PATH"

    # Init a git repo
    git init "$PROJECT_DIR" > /dev/null 2>&1

    run bash "$STEVE_CLI" init
    [ "$status" -eq 0 ]
    [ -f ".claude/commands/steve:init.md" ]
    [[ "$output" == *"commands installed"* ]]
}

@test "steve init overwrites existing commands" {
    # Mock claude
    cat > "$HOME/.local/bin/claude" <<'CLEOF'
#!/bin/bash
exit 0
CLEOF
    chmod +x "$HOME/.local/bin/claude"
    export PATH="$HOME/.local/bin:$PATH"

    # Update source commands to v2
    for cmd in init design prd plan-phase next-task test-checkpoint complete-phase resume; do
        echo "# steve:${cmd} v2" > "$HOME/.steve/commands/steve:${cmd}.md"
    done

    git init "$PROJECT_DIR" > /dev/null 2>&1
    mkdir -p .claude/commands
    echo "# old" > .claude/commands/steve:init.md

    run bash "$STEVE_CLI" init
    [ "$status" -eq 0 ]
    # Verify overwrite
    run cat .claude/commands/steve:init.md
    [[ "$output" == *"v2"* ]]
}

@test "steve update with mocked gh shows already latest" {
    # Mock gh to return current version
    cat > "$HOME/.local/bin/gh" <<'GHEOF'
#!/bin/bash
echo "0.1.0"
GHEOF
    chmod +x "$HOME/.local/bin/gh"
    export PATH="$HOME/.local/bin:$PATH"

    run bash "$STEVE_CLI" update
    [ "$status" -eq 0 ]
    [[ "$output" == *"already the latest"* ]]
}

@test "steve update refreshes project commands when inside a project" {
    # Mock gh to return current version (no actual update)
    cat > "$HOME/.local/bin/gh" <<'GHEOF'
#!/bin/bash
echo "0.1.0"
GHEOF
    chmod +x "$HOME/.local/bin/gh"
    export PATH="$HOME/.local/bin:$PATH"

    # Set up a project with steve commands
    mkdir -p .claude/commands
    echo "# old" > .claude/commands/steve:init.md

    run bash "$STEVE_CLI" update
    [ "$status" -eq 0 ]
    # Should have copied latest commands into project
    [[ "$output" == *"Project commands updated"* ]]
}
