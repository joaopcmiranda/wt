#!/usr/bin/env bats
# Unit tests for pure functions in wt.zsh (no git repo required).

load helpers

# ---------------------------------------------------------------------------
# _wt_sanitize_branch
# ---------------------------------------------------------------------------

@test "sanitize_branch: replaces single slash" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch 'feat/foo'"
  [ "$status" -eq 0 ]
  [ "$output" = "feat-foo" ]
}

@test "sanitize_branch: replaces multiple slashes" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch 'feat/sub/deep'"
  [ "$status" -eq 0 ]
  [ "$output" = "feat-sub-deep" ]
}

@test "sanitize_branch: strips leading dash after slash replacement" {
  # A branch like /foo starts with / which becomes -foo; leading - is stripped
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch '/foo'"
  [ "$status" -eq 0 ]
  [ "$output" = "foo" ]
}

@test "sanitize_branch: strips trailing dash after slash replacement" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch 'foo/'"
  [ "$status" -eq 0 ]
  [ "$output" = "foo" ]
}

@test "sanitize_branch: strips both leading and trailing dashes" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch '/foo/'"
  [ "$status" -eq 0 ]
  [ "$output" = "foo" ]
}

@test "sanitize_branch: preserves simple name unchanged" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch 'main'"
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "sanitize_branch: preserves existing dashes" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch 'my-feature'"
  [ "$status" -eq 0 ]
  [ "$output" = "my-feature" ]
}

@test "sanitize_branch: full conventional branch name" {
  run zsh -c "source '$WT_ZSH' && _wt_sanitize_branch 'feat/practice-app-login-page'"
  [ "$status" -eq 0 ]
  [ "$output" = "feat-practice-app-login-page" ]
}

# ---------------------------------------------------------------------------
# _wt_detect_pm
# ---------------------------------------------------------------------------

@test "detect_pm: detects pnpm from pnpm-lock.yaml" {
  local dir="$BATS_TEST_TMPDIR/pm-pnpm"
  mkdir -p "$dir"
  touch "$dir/pnpm-lock.yaml"

  run zsh -c "source '$WT_ZSH' && _wt_detect_pm '$dir'"
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm" ]
}

@test "detect_pm: detects yarn from yarn.lock" {
  local dir="$BATS_TEST_TMPDIR/pm-yarn"
  mkdir -p "$dir"
  touch "$dir/yarn.lock"

  run zsh -c "source '$WT_ZSH' && _wt_detect_pm '$dir'"
  [ "$status" -eq 0 ]
  [ "$output" = "yarn" ]
}

@test "detect_pm: detects npm from package-lock.json" {
  local dir="$BATS_TEST_TMPDIR/pm-npm"
  mkdir -p "$dir"
  touch "$dir/package-lock.json"

  run zsh -c "source '$WT_ZSH' && _wt_detect_pm '$dir'"
  [ "$status" -eq 0 ]
  [ "$output" = "npm" ]
}

@test "detect_pm: defaults to pnpm when no lockfile present" {
  local dir="$BATS_TEST_TMPDIR/pm-none"
  mkdir -p "$dir"

  run zsh -c "source '$WT_ZSH' && _wt_detect_pm '$dir'"
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm" ]
}

@test "detect_pm: pnpm takes precedence over yarn when both present" {
  local dir="$BATS_TEST_TMPDIR/pm-both-py"
  mkdir -p "$dir"
  touch "$dir/pnpm-lock.yaml" "$dir/yarn.lock"

  run zsh -c "source '$WT_ZSH' && _wt_detect_pm '$dir'"
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm" ]
}

@test "detect_pm: pnpm takes precedence over npm when both present" {
  local dir="$BATS_TEST_TMPDIR/pm-both-pn"
  mkdir -p "$dir"
  touch "$dir/pnpm-lock.yaml" "$dir/package-lock.json"

  run zsh -c "source '$WT_ZSH' && _wt_detect_pm '$dir'"
  [ "$status" -eq 0 ]
  [ "$output" = "pnpm" ]
}
