#!/usr/bin/env fish

echo "📊 Nix Storage Analysis Report"
echo "Analyzing current system state..."
echo ""

# Get current Nix store size
set nix_store_size (du -sh /nix/store 2>/dev/null | cut -f1 || echo "Unknown")

# Count Home Manager generations
set hm_profile_path ~/.local/state/nix/profiles/home-manager
if test -d $hm_profile_path
    set hm_generations (ls $hm_profile_path-*-link 2>/dev/null | wc -l)
    set hm_oldest (ls $hm_profile_path-*-link 2>/dev/null | head -1 | sed 's/.*home-manager-\([0-9]*\)-link/\1/')
    set hm_newest (ls $hm_profile_path-*-link 2>/dev/null | tail -1 | sed 's/.*home-manager-\([0-9]*\)-link/\1/')
else
    set hm_generations 0
    set hm_oldest "N/A"
    set hm_newest "N/A"
end

# Count system generations
set sys_generations (sudo nix-env --list-generations -p /nix/var/nix/profiles/system 2>/dev/null | wc -l || echo "0")

# Count flake inputs in common directories
set flake_inputs_count 0
set flake_dirs
for dir in /home/sarw/flake/.direnv /home/sarw/Programming/astal-bar/.direnv ~/.cache/direnv
    if test -d $dir/flake-inputs
        set dir_count (find $dir/flake-inputs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        set flake_inputs_count (math $flake_inputs_count + $dir_count)
        if test $dir_count -gt 0
            set flake_dirs $flake_dirs "$dir: $dir_count cached inputs"
        end
    end
end

# Get running processes that might hold Nix store references
set running_processes (ps aux | grep -c /nix/store || echo "0")

# Calculate direnv cache sizes
set direnv_cache_size "0"
if test -d ~/.cache/direnv
    set direnv_cache_size (du -sh ~/.cache/direnv 2>/dev/null | cut -f1 || echo "0")
end

echo "=== CURRENT STORAGE STATUS ==="
echo "💾 Total Nix store size: $nix_store_size"
echo ""

echo "=== MAJOR STORAGE CONSUMERS ==="
echo "🏠 Home Manager Generations: $hm_generations generations"
if test $hm_generations -gt 0
    echo "   - Range: $hm_oldest to $hm_newest"
    if test $hm_generations -gt 30
        echo "   - ⚠️  Recommended: Keep only last 10-30 generations"
        echo "   - Potential savings: Significant (each generation can be 100MB-1GB+)"
    else if test $hm_generations -gt 10
        echo "   - ⚡ Consider: Keep only last 10 generations for more space"
    else
        echo "   - ✅ Reasonable amount"
    end
end
echo ""

echo "📦 Flake Inputs Cache: $flake_inputs_count total cached inputs"
for dir_info in $flake_dirs
    echo "   - $dir_info"
end
if test $flake_inputs_count -gt 0
    echo "   - Potential savings: 500MB-2GB+"
end
echo ""

echo "💾 Direnv Cache: $direnv_cache_size"
if test "$direnv_cache_size" != "0"
    echo "   - Location: ~/.cache/direnv"
end
echo ""

echo "🔄 Running Process References: $running_processes processes"
echo "   - These prevent garbage collection of store paths"
echo "   - Some may be from long-running services or development shells"
echo ""

echo "🖥️  System Generations: $sys_generations"
if test $sys_generations -gt 10
    echo "   - ⚠️  Consider cleaning old system generations"
else
    echo "   - ✅ Reasonable amount"
end
echo ""

echo ""

echo "=== QUICK WINS FOR IMMEDIATE SPACE RECOVERY ==="

if test $flake_inputs_count -gt 0
    echo "1. 🥇 Clear flake inputs cache ($flake_inputs_count cached inputs):"
    for dir_info in $flake_dirs
        set dir_path (echo $dir_info | cut -d: -f1)
        echo "   rm -rf $dir_path/flake-inputs/"
    end
    echo ""
end

if test $hm_generations -gt 10
    echo "2. 🥈 Remove old Home Manager generations (keeping last 10):"
    echo "   home-manager expire-generations '-30 days'"
    echo ""
end

echo "3. 🥉 Run garbage collection:"
echo "   nix-collect-garbage -d"
echo ""

if test "$direnv_cache_size" != "0"
    echo "4. 🧹 Clear direnv cache ($direnv_cache_size):"
    echo "   rm -rf ~/.cache/direnv/"
    echo ""
end

echo "=== ESTIMATED SPACE RECOVERY ==="
set potential_savings 0

if test $hm_generations -gt 30
    echo "Conservative estimate: 15-25GB"
    echo "Optimistic estimate: 30-40GB"
else if test $hm_generations -gt 10
    echo "Conservative estimate: 5-15GB"
    echo "Optimistic estimate: 10-25GB"
else if test $flake_inputs_count -gt 20
    echo "Conservative estimate: 2-5GB"
    echo "Optimistic estimate: 5-10GB"
else
    echo "Conservative estimate: 1-3GB"
    echo "Optimistic estimate: 3-8GB"
end
echo ""

echo "=== TO PREVENT FUTURE BLOAT ==="
echo "Add to your NixOS configuration:"
echo ""
echo "  nix = {"
echo "    gc = {"
echo "      automatic = true;"
echo "      dates = \"weekly\";"
echo "      options = \"--delete-older-than 30d\";"
echo "    };"
echo "    settings.auto-optimise-store = true;"
echo "  };"
echo ""

echo "And in your Home Manager config:"
echo ""
echo "  programs.home-manager.enable = true;"
echo "  # Add this to automatically clean old generations"
echo ""

echo "Run './cleanup-nix-storage.fish' to start the cleanup process!"
