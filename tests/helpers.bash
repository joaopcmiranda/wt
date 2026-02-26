# Shared test helpers for wt test suite.
# Loaded via `load helpers` in each .bats file.

WT_ZSH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/wt.zsh"

# On macOS, $BATS_TEST_TMPDIR is under /var/folders which is a symlink to
# /private/var/folders. git rev-parse --show-toplevel resolves symlinks, so
# canonicalise the temp dir to prevent path comparison mismatches in tests.
BATS_TEST_TMPDIR="$(cd "$BATS_TEST_TMPDIR" 2>/dev/null && pwd -P || echo "$BATS_TEST_TMPDIR")"

# Create a minimal single-commit git repo at $1, on branch "main".
setup_repo() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email "test@wt.test"
  git -C "$dir" config user.name "WT Test"
  printf 'init\n' > "$dir/README.md"
  git -C "$dir" add .
  git -C "$dir" commit -q -m "init"
  git -C "$dir" branch -M main
}

# Create a repo with a bare origin so _wt_default_branch can resolve
# refs/remotes/origin/HEAD. Layout:
#   $base/main/       ← working repo
#   $base/origin.git  ← bare remote
setup_repo_with_origin() {
  local base="$1"
  local branch="${2:-main}"

  mkdir -p "$base"
  git init -q --bare "$base/origin.git"

  setup_repo "$base/main"
  # Rename local branch to match desired default
  if [[ "$branch" != "main" ]]; then
    git -C "$base/main" branch -M "$branch"
  fi

  git -C "$base/main" remote add origin "$base/origin.git"
  git -C "$base/main" push -q origin "$branch"

  # Wire up origin/HEAD so _wt_default_branch resolves correctly
  git -C "$base/main" remote set-head origin "$branch" 2>/dev/null || \
    git -C "$base/main" symbolic-ref refs/remotes/origin/HEAD \
      "refs/remotes/origin/$branch"
}
