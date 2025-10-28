#!/bin/bash
# Update repository URLs from validated-patterns-ansible-toolkit to validated-patterns-ansible-toolkit
# This script updates all references in the codebase

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
FILES_UPDATED=0
TOTAL_REPLACEMENTS=0

echo -e "${GREEN}=== Repository URL Update Script ===${NC}"
echo "This script will update all references from:"
echo "  OLD: validated-patterns-ansible-toolkit"
echo "  NEW: validated-patterns-ansible-toolkit"
echo ""

# Backup option
BACKUP=${BACKUP:-true}
if [ "$BACKUP" = "true" ]; then
    BACKUP_DIR=".url-update-backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Creating backup in: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
fi

# Function to update a file
update_file() {
    local file="$1"
    local temp_file="${file}.tmp"
    
    # Skip if file doesn't exist
    if [ ! -f "$file" ]; then
        return
    fi
    
    # Backup if enabled
    if [ "$BACKUP" = "true" ]; then
        cp "$file" "$BACKUP_DIR/$(basename $file).bak"
    fi
    
    # Count replacements in this file
    local count=$(grep -c "validated-patterns-ansible-toolkit" "$file" 2>/dev/null || echo "0")
    
    if [ "$count" -gt 0 ]; then
        echo -e "${YELLOW}Updating: $file ($count occurrences)${NC}"
        
        # Perform replacements
        sed -i.bak \
            -e 's|validated-patterns-ansible-toolkit|validated-patterns-ansible-toolkit|g' \
            "$file"
        
        # Remove backup file created by sed
        rm -f "${file}.bak"
        
        FILES_UPDATED=$((FILES_UPDATED + 1))
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + count))
    fi
}

# Find and update all relevant files
echo -e "${GREEN}Searching for files to update...${NC}"

# Update YAML files
while IFS= read -r file; do
    update_file "$file"
done < <(find . -type f \( -name "*.yaml" -o -name "*.yml" \) ! -path "./.git/*" ! -path "./node_modules/*" ! -path "./.venv/*")

# Update Markdown files
while IFS= read -r file; do
    update_file "$file"
done < <(find . -type f -name "*.md" ! -path "./.git/*" ! -path "./node_modules/*")

# Update Shell scripts
while IFS= read -r file; do
    update_file "$file"
done < <(find . -type f -name "*.sh" ! -path "./.git/*")

# Update Chart.yaml files
while IFS= read -r file; do
    update_file "$file"
done < <(find . -type f -name "Chart.yaml" ! -path "./.git/*")

echo ""
echo -e "${GREEN}=== Update Complete ===${NC}"
echo -e "Files updated: ${GREEN}$FILES_UPDATED${NC}"
echo -e "Total replacements: ${GREEN}$TOTAL_REPLACEMENTS${NC}"

if [ "$BACKUP" = "true" ]; then
    echo -e "Backup location: ${YELLOW}$BACKUP_DIR${NC}"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review changes: git diff"
echo "2. Test the changes"
echo "3. Update .git/config manually if needed"
echo "4. Commit changes: git add -A && git commit -m 'chore: update repository URLs to validated-patterns-ansible-toolkit'"

# Verify no old URLs remain
echo ""
echo -e "${GREEN}Verifying update...${NC}"
REMAINING=$(grep -r "validated-patterns-ansible-toolkit" --include="*.yaml" --include="*.yml" --include="*.md" --include="*.sh" . 2>/dev/null | grep -v ".git/" | grep -v "$BACKUP_DIR" | wc -l || echo "0")

if [ "$REMAINING" -eq 0 ]; then
    echo -e "${GREEN}✅ All URLs updated successfully!${NC}"
else
    echo -e "${RED}⚠️  Warning: $REMAINING occurrences still found${NC}"
    echo "Run this to see remaining occurrences:"
    echo "  grep -r 'validated-patterns-ansible-toolkit' --include='*.yaml' --include='*.yml' --include='*.md' --include='*.sh' . | grep -v '.git/'"
fi

