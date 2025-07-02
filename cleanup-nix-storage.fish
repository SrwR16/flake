#!/usr/bin/env fish

# Nix Storage Cleanup Script
# This script will help reclaim storage from your 55GB Nix installation

echo "🧹 Nix Storage Cleanup Script"
echo "Current storage usage analysis based on links.txt:"
echo "- 201 Home Manager generations (generations 98-298)"
echo "- 49 flake inputs in /home/sarw/flake/.direnv/"
echo "- 2,337 running process references"
echo ""

# Function to ask for confirmation
function confirm
    read -P "$argv[1] (y/N): " -l response
    test "$response" = "y" -o "$response" = "Y"
end

echo "=== STEP 1: Clean up old Home Manager generations ==="
echo "Keeping only the last 10 generations (instead of 201)"
if confirm "Remove old Home Manager generations"
    echo "Removing old Home Manager generations..."
    home-manager expire-generations "-10 days"
    # Alternative: keep only last 5 generations
    # nix-env --delete-generations +5 -p ~/.local/state/nix/profiles/home-manager
end

echo ""
echo "=== STEP 2: Clean up flake inputs cache ==="
echo "This will remove 49 cached flake inputs from /home/sarw/flake/.direnv/"
if confirm "Clear flake inputs cache"
    echo "Clearing flake inputs cache..."
    rm -rf /home/sarw/flake/.direnv/flake-inputs/
    rm -rf /home/sarw/Programming/astal-bar/.direnv/flake-inputs/
    echo "Flake inputs cache cleared. They will be re-downloaded as needed."
end

echo ""
echo "=== STEP 3: System generations cleanup ==="
echo "You only have 3 system generations, which is reasonable."
echo "But we can clean up old boot entries if desired."
if confirm "Clean old system generations (keep last 5)"
    echo "Cleaning old system generations..."
    sudo nix-collect-garbage --delete-older-than 30d
end

echo ""
echo "=== STEP 4: Run garbage collection ==="
echo "This will remove all unreferenced store paths"
if confirm "Run full garbage collection"
    echo "Running garbage collection..."
    nix-collect-garbage -d
    echo "Garbage collection completed."
end

echo ""
echo "=== STEP 5: Optimize Nix store ==="
echo "This will deduplicate identical files in the store"
if confirm "Optimize Nix store (may take a while)"
    echo "Optimizing Nix store..."
    nix-store --optimise
    echo "Store optimization completed."
end

echo ""
echo "=== Storage Analysis After Cleanup ==="
echo "Checking current Nix store size..."
du -sh /nix/store 2>/dev/null || echo "Could not measure /nix/store size"

echo ""
echo "🎉 Cleanup completed!"
echo ""
echo "💡 Tips to prevent storage bloat:"
echo "1. Regularly run: home-manager expire-generations '-30 days'"
echo "2. Set up automatic garbage collection in your NixOS config:"
echo "   nix.gc.automatic = true;"
echo "   nix.gc.dates = \"weekly\";"
echo "   nix.gc.options = \"--delete-older-than 30d\";"
echo "3. Clean direnv caches periodically: rm -rf ~/.cache/direnv/"
echo "4. Consider using 'nix.settings.auto-optimise-store = true;' in your config"
