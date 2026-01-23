#!/bin/bash
# Setup Cursor Rules + Initialize Beads & Serena
# Usage: ./setup-cursor-rules.sh [project-path]

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_PATH="${1:-.}"
PROJECT_PATH=$(cd "$PROJECT_PATH" 2>/dev/null && pwd || echo "$PROJECT_PATH")
RULES_DIR="$PROJECT_PATH/.cursor/rules"
TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cursor Orchestrated Workflow Setup      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Project: $PROJECT_PATH"
echo ""

# Check if template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${RED}✗${NC} Template not found at $TEMPLATE_DIR"
    exit 1
fi

# Check if we're in a git repo
if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo -e "${YELLOW}⚠️${NC}  Not a git repository. Initialize git first:"
    echo "    cd $PROJECT_PATH && git init"
    exit 1
fi

echo -e "${BLUE}Step 1: Installing Cursor Rules${NC}"
echo "────────────────────────────────────"

# Create .cursor/rules directory
mkdir -p "$RULES_DIR"
echo -e "${GREEN}✓${NC} Created .cursor/rules"

# Copy rule file
if [ -f "$RULES_DIR/orchestrated-workflow.mdc" ]; then
    echo -e "${YELLOW}⚠️${NC}  orchestrated-workflow.mdc exists, skipping..."
else
    cp "$TEMPLATE_DIR/orchestrated-workflow.mdc" "$RULES_DIR/"
    echo -e "${GREEN}✓${NC} Copied orchestrated-workflow.mdc"
fi

# Copy AGENTS.md
if [ -f "$PROJECT_PATH/AGENTS.md" ]; then
    echo -e "${YELLOW}⚠️${NC}  AGENTS.md exists, skipping..."
else
    cp "$TEMPLATE_DIR/AGENTS.md" "$PROJECT_PATH/"
    echo -e "${GREEN}✓${NC} Copied AGENTS.md"
fi

echo ""
echo -e "${BLUE}Step 2: Initializing Beads${NC}"
echo "────────────────────────────────────"

cd "$PROJECT_PATH"

# Check if bd is installed
if ! command -v bd &> /dev/null; then
    echo -e "${RED}✗${NC} bd (beads) not found. Install it first:"
    echo "    pip install beads-cli"
    exit 1
fi

# Initialize beads if not already initialized
if [ ! -d "$PROJECT_PATH/.beads" ]; then
    echo "Initializing beads..."
    bd init
    echo -e "${GREEN}✓${NC} Beads initialized"
    
    # Setup cursor integration
    if bd setup cursor &> /dev/null; then
        echo -e "${GREEN}✓${NC} Beads Cursor integration configured"
    fi
else
    echo -e "${YELLOW}⚠️${NC}  Beads already initialized"
fi

echo ""
echo -e "${BLUE}Step 3: Initializing Serena${NC}"
echo "────────────────────────────────────"

# Check if serena directory exists
if [ ! -d "$PROJECT_PATH/.serena" ]; then
    mkdir -p "$PROJECT_PATH/.serena"
    
    # Create basic project.yml
    cat > "$PROJECT_PATH/.serena/project.yml" << 'SERENA_EOF'
# Serena project configuration
languages:
- python
- typescript

encoding: "utf-8"
ignore_all_files_in_gitignore: true
ignored_paths: []
read_only: false
excluded_tools: []
initial_prompt: ""
project_name: ""
included_optional_tools: []
SERENA_EOF
    
    # Auto-detect project name from directory
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    sed -i '' "s/project_name: \"\"/project_name: \"$PROJECT_NAME\"/" "$PROJECT_PATH/.serena/project.yml"
    
    # Create .gitignore for serena
    cat > "$PROJECT_PATH/.serena/.gitignore" << 'GITIGNORE_EOF'
cache/
*.pyc
__pycache__/
GITIGNORE_EOF
    
    mkdir -p "$PROJECT_PATH/.serena/memories"
    mkdir -p "$PROJECT_PATH/.serena/cache"
    
    echo -e "${GREEN}✓${NC} Serena initialized"
    echo -e "${GREEN}✓${NC} Created .serena/project.yml"
    echo -e "${GREEN}✓${NC} Created memories and cache directories"
else
    echo -e "${YELLOW}⚠️${NC}  Serena already initialized"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Setup Complete! ✓               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo "Installed:"
echo "  • orchestrated-workflow.mdc (65 lines)"
echo "  • AGENTS.md (workflow guide)"
echo "  • Beads (.beads/ directory)"
echo "  • Serena (.serena/ directory)"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Commit the new files:"
echo "     git add .cursor .beads .serena AGENTS.md"
echo "     git commit -m 'chore: add orchestrated workflow setup'"
echo ""
echo "  2. Start using the workflow:"
echo "     bd create --title='First task' --type=task --priority=1"
echo "     bd ready"
echo ""
echo -e "${BLUE}Orchestrated Workflow Enabled:${NC}"
echo "  • Orchestrator delegates work"
echo "  • Beads tracks issues"
echo "  • Subagents have full tool access"
echo "  • Agent Mail coordinates"
echo "  • Serena searches code"
