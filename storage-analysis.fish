#!/usr/bin/env fish

echo "📊 Nix Storage Analysis Report"
echo "Based on your links.txt garbage collection roots analysis"
echo ""

echo "=== MAJOR STORAGE CONSUMERS ==="
echo "🏠 Home Manager Generations: 201 generations (98-298)"
echo "   - Recommended: Keep only last 10-30 generations"
echo "   - Potential savings: Significant (each generation can be 100MB-1GB+)"
echo ""

echo "📦 Flake Inputs Cache:"
echo "   - /home/sarw/flake/.direnv/: 49 cached inputs"
echo "   - /home/sarw/Programming/astal-bar/.direnv/: 3 cached inputs"
echo "   - Potential savings: 500MB-2GB+"
echo ""

echo "🔄 Running Process References: 2,337 processes"
echo "   - These prevent garbage collection of store paths"
echo "   - Some may be from long-running services or development shells"
echo ""

echo "🖥️  System Generations: 3 (reasonable amount)"
echo ""

echo "=== QUICK WINS FOR IMMEDIATE SPACE RECOVERY ==="
echo "1. 🥇 Clear flake inputs cache:"
echo "   rm -rf /home/sarw/flake/.direnv/flake-inputs/"
echo "   rm -rf /home/sarw/Programming/astal-bar/.direnv/flake-inputs/"
echo ""

echo "2. 🥈 Remove old Home Manager generations:"
echo "   home-manager expire-generations '-30 days'"
echo ""

echo "3. 🥉 Run garbage collection:"
echo "   nix-collect-garbage -d"
echo ""

echo "=== ESTIMATED SPACE RECOVERY ==="
echo "Conservative estimate: 15-25GB"
echo "Optimistic estimate: 30-40GB"
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
