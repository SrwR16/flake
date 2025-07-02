#!/usr/bin/env fish

# Nix Storage Cleanup Script
# This script will help reclaim storage from your Nix installation

echo "🧹 Nix Storage Cleanup Script"
echo "Analyzing current storage usage..."

# Get current system state
set nix_store_size (du -sh /nix/store 2>/dev/null | cut -f1 || echo "Unknown")

# Count Home Manager generations
set hm_generations (home-manager generations | wc -l)

# Count system generations
set sys_generations (sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | wc -l || echo "0")

# Count flake inputs
set flake_inputs_count 0
set flake_dirs
for dir in /home/sarw/flake/.direnv /home/sarw/Programming/astal-bar/.direnv ~/.cache/direnv
    if test -d $dir/flake-inputs
        set dir_count (find $dir/flake-inputs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        set flake_inputs_count (math $flake_inputs_count + $dir_count)
        if test $dir_count -gt 0
            set flake_dirs $flake_dirs $dir
        end
    end
end

# Get running processes
set running_processes (ps aux | grep -c /nix/store || echo "0")

echo "Current storage analysis:"
echo "- Nix store size: $nix_store_size"
echo "- $hm_generations Home Manager generations"
echo "- $flake_inputs_count flake inputs cached"
echo "- $running_processes running process references"
echo "- $sys_generations system generations"
echo ""

# Function to ask for confirmation
function confirm
    read -P "$argv[1] (y/N): " -l response
    test "$response" = "y" -o "$response" = "Y"
end

echo "=== STEP 1: Clean up old Home Manager generations ==="
if test $hm_generations -gt 3
    echo "Found $hm_generations generations - keeping only the last 3"
    if confirm "Remove old Home Manager generations (keep last 3)"
        echo "Removing old Home Manager generations..."
        # Use generation number-based cleanup instead of time-based
        nix-env --delete-generations +3 -p ~/.local/state/nix/profiles/home-manager
        echo "✅ Old Home Manager generations removed"
    end
else if test $hm_generations -gt 2
    echo "Found $hm_generations generations - keeping only the last 2"
    if confirm "Remove old Home Manager generations (keep last 2)"
        echo "Removing old Home Manager generations..."
        nix-env --delete-generations +2 -p ~/.local/state/nix/profiles/home-manager
        echo "✅ Home Manager generations removed"
    end
else if test $hm_generations -gt 1
    echo "Found $hm_generations generations - keeping only the current generation"
    if confirm "Remove old Home Manager generations (keep last 1)"
        echo "Removing old Home Manager generations..."
        nix-env --delete-generations +1 -p ~/.local/state/nix/profiles/home-manager
        echo "✅ Home Manager generations cleaned"
    end
else
    echo "Only $hm_generations Home Manager generation found - nothing to clean"
end

echo ""
echo "=== STEP 2: Clean up flake inputs cache ==="
if test $flake_inputs_count -gt 0
    echo "Found $flake_inputs_count cached flake inputs in:"
    for dir in $flake_dirs
        if test -d $dir/flake-inputs
            set dir_count (find $dir/flake-inputs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
            echo "  - $dir ($dir_count inputs)"
        end
    end
    if confirm "Clear flake inputs cache"
        echo "Clearing flake inputs cache..."
        for dir in $flake_dirs
            if test -d $dir/flake-inputs
                rm -rf $dir/flake-inputs/
                echo "  ✅ Cleared $dir/flake-inputs/"
            end
        end
        echo "Flake inputs cache cleared. They will be re-downloaded as needed."
    end
else
    echo "No flake inputs cache found - skipping"
end

echo ""
echo "=== STEP 3: System generations cleanup ==="
if test $sys_generations -gt 3
    echo "Found $sys_generations system generations - keeping only the last 3"
    if confirm "Clean old system generations (keep last 3)"
        echo "Cleaning old system generations..."
        sudo nix-env --delete-generations +3 -p /nix/var/nix/profiles/system
        echo "✅ Old system generations cleaned"
    end
else if test $sys_generations -gt 2
    echo "Found $sys_generations system generations - keeping only the last 2"
    if confirm "Clean system generations (keep last 2)"
        echo "Cleaning old system generations..."
        sudo nix-env --delete-generations +2 -p /nix/var/nix/profiles/system
        echo "✅ System generations cleaned"
    end
else
    echo "Found $sys_generations system generations - this is already minimal"
    if confirm "Still want to clean system generations (keep last 1)"
        echo "Cleaning old system generations..."
        sudo nix-env --delete-generations +1 -p /nix/var/nix/profiles/system
        echo "✅ System generations cleaned"
    end
end

echo "=== STEP 4: Clean up boot entries ==="
echo "Cleaning old boot entries (this helps free system generations)"
if confirm "Clean old boot entries"
    echo "Cleaning old boot entries..."
    sudo /run/current-system/bin/switch-to-configuration boot
    echo "✅ Boot entries cleaned"
end

echo ""
echo "=== STEP 5: Clean direnv cache ==="
if test -d ~/.cache/direnv
    set direnv_size (du -sh ~/.cache/direnv 2>/dev/null | cut -f1 || echo "Unknown")
    echo "Found direnv cache: $direnv_size"
    if confirm "Clear direnv cache"
        echo "Clearing direnv cache..."
        rm -rf ~/.cache/direnv/
        echo "✅ Direnv cache cleared"
    end
else
    echo "No direnv cache found - skipping"
end

echo ""
echo "=== STEP 6: Run garbage collection ==="
echo "This will remove all unreferenced store paths"
if confirm "Run full garbage collection"
    echo "Running garbage collection..."
    nix-collect-garbage -d
    echo "✅ Garbage collection completed"
end

echo ""
echo "=== STEP 7: Optimize Nix store ==="
echo "This will deduplicate identical files in the store"
if confirm "Optimize Nix store (may take a while)"
    echo "Optimizing Nix store..."
    nix-store --optimise
    echo "✅ Store optimization completed"
end

echo ""
echo "=== Storage Analysis After Cleanup ==="
echo "Checking current Nix store size..."
set new_nix_store_size (du -sh /nix/store 2>/dev/null | cut -f1 || echo "Unknown")
echo "Previous size: $nix_store_size"
echo "Current size:  $new_nix_store_size"

# Count remaining generations
set new_hm_generations (home-manager generations | wc -l)
set new_sys_generations (sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | wc -l || echo "0")

echo ""
echo "Remaining after cleanup:"
echo "- Home Manager generations: $new_hm_generations (was $hm_generations)"
echo "- System generations: $new_sys_generations (was $sys_generations)"

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
