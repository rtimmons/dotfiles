set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default: update

update: pull brewup link ensure-localrc install shellcheck

pull:
  git pull --ff-only --quiet

brewup:
  brew cleanup --quiet
  brew update --quiet
  brew upgrade --quiet
  brew autoremove --quiet
  brew cleanup --quiet

install:
  @scripts=(); \
  while IFS= read -r script; do scripts+=("$script"); done < <(find . -mindepth 2 -maxdepth 2 -type f -name install.sh | LC_ALL=C sort); \
  count="${#scripts[@]}"; \
  interactive=0; [[ -t 2 && "${TERM:-dumb}" != "dumb" ]] && interactive=1; \
  if [[ "$interactive" -eq 0 ]]; then echo "Running install scripts..."; fi; \
  for script in "${scripts[@]}"; do \
    if [[ "$interactive" -eq 1 ]]; then printf '\r\033[KRunning %s' "$script" >&2; fi; \
    if ! "$script"; then \
      if [[ "$interactive" -eq 1 ]]; then printf '\r\033[K\n' >&2; fi; \
      echo "Install script failed: $script" >&2; \
      exit 1; \
    fi; \
  done; \
  if [[ "$interactive" -eq 1 ]]; then \
    printf '\r\033[KCompleted install scripts (%s)\n' "$count" >&2; \
  else \
    echo "Completed install scripts ($count)"; \
  fi

shellcheck *args:
  @list_only=0; \
  for arg in {{args}}; do \
    if [[ "$arg" == "--list" || "$arg" == "--ls" ]]; then \
      list_only=1; \
    fi; \
  done; \
  [[ "${LS:-}" == "1" || "${LIST:-}" == "1" ]] && list_only=1; \
  interactive=0; [[ -t 2 && "${TERM:-dumb}" != "dumb" ]] && interactive=1; \
  if [[ "$list_only" -eq 1 ]]; then \
    echo "Listing shellcheck targets..."; \
  elif [[ "$interactive" -eq 1 ]]; then \
    printf '\r\033[KScanning for shell scripts...' >&2; \
  else \
    echo "Running shellcheck..."; \
  fi; \
  shellcheck_ignored() { \
    local path="$1" dir rel line ignore_file; \
    dir="$(dirname "$path")"; \
    while true; do \
      ignore_file="$dir/.shellcheckignore"; \
      if [[ -f "$ignore_file" ]]; then \
        rel="${path#"$dir/"}"; \
        while IFS= read -r line || [[ -n "$line" ]]; do \
          line="${line#"${line%%[![:space:]]*}"}"; \
          line="${line%"${line##*[![:space:]]}"}"; \
          [[ -z "$line" || "${line:0:1}" == "#" ]] && continue; \
          [[ "$rel" == "$line"* ]] && return 0; \
        done < "$ignore_file"; \
      fi; \
      [[ "$dir" == "." ]] && break; \
      dir="$(dirname "$dir")"; \
    done; \
    return 1; \
  }; \
  shellcheck_is_target() { \
    local path="$1" ext first_line; \
    case "$path" in \
      *[Zz][Ss][Hh]*) return 1 ;; \
    esac; \
    ext="${path##*.}"; \
    case "$ext" in \
      sh|bash|ksh|mksh) return 0 ;; \
    esac; \
    if IFS= read -r first_line < "$path"; then \
      [[ "$first_line" =~ ^#!.*[[:space:]/](bash|sh|dash|ksh)([[:space:]]|$) ]] && return 0; \
    fi; \
    return 1; \
  }; \
  scripts=(); \
  while IFS= read -r path; do \
    file="./$path"; \
    [[ -f "$file" ]] || continue; \
    shellcheck_is_target "$file" || continue; \
    shellcheck_ignored "$file" && continue; \
    scripts+=("$file"); \
  done < <(git ls-files | LC_ALL=C sort); \
  count="${#scripts[@]}"; \
  if [[ "$count" -eq 0 ]]; then \
    if [[ "$interactive" -eq 1 && "$list_only" -eq 0 ]]; then \
      printf '\r\033[KNo shell scripts found\n' >&2; \
    else \
      echo "No shell scripts found"; \
    fi; \
    exit 0; \
  fi; \
  if [[ "$list_only" -eq 1 ]]; then \
    printf '%s\n' "${scripts[@]}"; \
    echo "Total shell scripts: $count"; \
    exit 0; \
  fi; \
  errors_found=0; \
  for script in "${scripts[@]}"; do \
    if [[ "$interactive" -eq 1 ]]; then printf '\r\033[Kshellcheck %s' "$script" >&2; fi; \
    if ! shellcheck "$script"; then \
      if [[ "$interactive" -eq 1 ]]; then printf '\r\033[K\n' >&2; fi; \
      errors_found=1; \
    fi; \
  done; \
  if [[ "$errors_found" -eq 1 ]]; then \
    if [[ "$interactive" -eq 1 ]]; then printf '\r\033[KShellcheck found issues.\n' >&2; else echo "Shellcheck found issues."; fi; \
    exit 1; \
  fi; \
  if [[ "$interactive" -eq 1 ]]; then \
    printf '\r\033[KShellcheck complete (%s files)\n' "$count" >&2; \
  else \
    echo "Shellcheck complete ($count files)"; \
  fi

ensure-localrc:
  @localrc_path="$HOME/.localrc"; \
  if [[ -f "$localrc_path" ]]; then \
    chmod 600 "$localrc_path"; \
    exit 0; \
  fi; \
  printf '%s\n' \
    '# ~/.localrc' \
    '# Local shell configuration - not checked into git' \
    '# This file is automatically sourced after all dotfiles configs.' \
    '# Use this file to set secret environment variables, machine-specific settings, etc.' \
    '#' \
    '# Example:' \
    '#   export API_KEY="your-secret-api-key"' \
    '#   export DATABASE_PASSWORD="your-secret-password"' \
    '#' > "$localrc_path"; \
  chmod 600 "$localrc_path"; \
  echo "Created ~/.localrc with helpful comment"

link:
  @linkables=(); \
  while IFS= read -r linkable; do linkables+=("$linkable"); done < <(find . -name '*.symlink' -type f | LC_ALL=C sort); \
  skip_all=0; overwrite_all=0; backup_all=0; \
  for linkable in "${linkables[@]}"; do \
    overwrite=0; backup=0; \
    filename="$(basename "$linkable" .symlink)"; \
    target="$HOME/.${filename}"; \
    link_dest="$PWD/${linkable#./}"; \
    if [[ -e "$target" || -L "$target" ]]; then \
      already_done=0; \
      if [[ -L "$target" && "$(readlink "$target")" == "$link_dest" ]]; then \
        already_done=1; \
      fi; \
      [[ "$already_done" -eq 1 ]] && continue; \
      if [[ "$skip_all" -eq 0 && "$overwrite_all" -eq 0 && "$backup_all" -eq 0 ]]; then \
        if [[ -t 0 ]]; then \
          echo "File already exists: $target"; \
          echo; \
          ls -l "$target"; \
          echo; \
          echo "what do you want to do?"; \
          echo "[s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all, [q]uit"; \
          echo; \
          IFS= read -r choice; \
          case "$choice" in \
            o) overwrite=1 ;; \
            b) backup=1 ;; \
            O) overwrite_all=1 ;; \
            B) backup_all=1 ;; \
            S) skip_all=1 ;; \
            q|Q) exit 0 ;; \
            s|*) continue ;; \
          esac; \
        else \
          continue; \
        fi; \
      fi; \
      if [[ "$overwrite" -eq 1 || "$overwrite_all" -eq 1 ]]; then rm -rf "$target"; fi; \
      if [[ "$backup" -eq 1 || "$backup_all" -eq 1 ]]; then mv "$target" "$target.backup"; fi; \
      [[ "$skip_all" -eq 1 ]] && continue; \
    fi; \
    ln -s "$link_dest" "$target"; \
  done

uninstall:
  @while IFS= read -r linkable; do \
    filename="$(basename "$linkable" .symlink)"; \
    target="$HOME/.${filename}"; \
    backup="$target.backup"; \
    if [[ -L "$target" ]]; then rm "$target"; fi; \
    if [[ -e "$backup" ]]; then mv "$backup" "$target"; fi; \
  done < <(find . -name '*.symlink' -type f | LC_ALL=C sort)
