#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# VS Code Django + Codex Environment Setup for Ubuntu
# ============================================================
# What this does:
#   - Verifies VS Code CLI is installed
#   - Installs recommended VS Code extensions for Django development
#   - Installs OpenAI Codex extension
#   - Removes/disables GitHub Copilot extensions if present
#   - Writes safe VS Code user settings for Python/Django development
#   - Optionally installs Docker/PostgreSQL/YAML helper extensions
#
# Usage:
#   chmod +x setup-vscode-django-codex.sh
#   ./setup-vscode-django-codex.sh
#
# Optional:
#   ./setup-vscode-django-codex.sh --with-docker
#   ./setup-vscode-django-codex.sh --with-postgres
#   ./setup-vscode-django-codex.sh --with-all
# ============================================================

WITH_DOCKER=false
WITH_POSTGRES=false

for arg in "$@"; do
  case "$arg" in
    --with-docker)
      WITH_DOCKER=true
      ;;
    --with-postgres)
      WITH_POSTGRES=true
      ;;
    --with-all)
      WITH_DOCKER=true
      WITH_POSTGRES=true
      ;;
    -h|--help)
      echo "Usage: $0 [--with-docker] [--with-postgres] [--with-all]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--with-docker] [--with-postgres] [--with-all]"
      exit 1
      ;;
  esac
done

echo "==> Checking for VS Code CLI..."

if ! command -v code >/dev/null 2>&1; then
  echo "ERROR: VS Code CLI 'code' was not found."
  echo
  echo "Install VS Code first, then make sure the 'code' command is available."
  echo "In VS Code: Ctrl+Shift+P -> Shell Command: Install 'code' command in PATH"
  exit 1
fi

echo "==> VS Code CLI found: $(command -v code)"
echo

# ------------------------------------------------------------
# Remove / disable GitHub Copilot if installed
# ------------------------------------------------------------

echo "==> Removing GitHub Copilot extensions if installed..."

if code --list-extensions | grep -qi '^GitHub\.copilot$'; then
  code --uninstall-extension GitHub.copilot || true
else
  echo "GitHub.copilot not installed."
fi

if code --list-extensions | grep -qi '^GitHub\.copilot-chat$'; then
  code --uninstall-extension GitHub.copilot-chat || true
else
  echo "GitHub.copilot-chat not installed."
fi

echo

# ------------------------------------------------------------
# Required extensions
# ------------------------------------------------------------

REQUIRED_EXTENSIONS=(
  "openai.chatgpt"
  "ms-python.python"
  "ms-python.vscode-pylance"
  "ms-python.debugpy"
  "charliermarsh.ruff"
  "ms-python.black-formatter"
  "batisteo.vscode-django"
  "qwtel.sqlite-viewer"
  "humao.rest-client"
  "mikestead.dotenv"
  "eamodio.gitlens"
  "usernamehw.errorlens"
  "redhat.vscode-yaml"
)

OPTIONAL_EXTENSIONS=()

if [ "$WITH_DOCKER" = true ]; then
  OPTIONAL_EXTENSIONS+=("ms-azuretools.vscode-docker")
fi

if [ "$WITH_POSTGRES" = true ]; then
  OPTIONAL_EXTENSIONS+=("cweijan.vscode-postgresql-client2")
fi

install_extension() {
  local ext="$1"

  if code --list-extensions | grep -qi "^${ext}$"; then
    echo "Already installed: $ext"
  else
    echo "Installing: $ext"
    code --install-extension "$ext"
  fi
}

echo "==> Installing required VS Code extensions..."

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
  install_extension "$ext"
done

if [ "${#OPTIONAL_EXTENSIONS[@]}" -gt 0 ]; then
  echo
  echo "==> Installing optional VS Code extensions..."

  for ext in "${OPTIONAL_EXTENSIONS[@]}"; do
    install_extension "$ext"
  done
fi

echo

# ------------------------------------------------------------
# Configure VS Code user settings
# ------------------------------------------------------------

SETTINGS_DIR="${HOME}/.config/Code/User"
SETTINGS_FILE="${SETTINGS_DIR}/settings.json"
BACKUP_FILE="${SETTINGS_FILE}.backup.$(date +%Y%m%d-%H%M%S)"

mkdir -p "$SETTINGS_DIR"

echo "==> Configuring VS Code settings..."

if [ -f "$SETTINGS_FILE" ]; then
  echo "Existing settings.json found."
  echo "Creating backup:"
  echo "$BACKUP_FILE"
  cp "$SETTINGS_FILE" "$BACKUP_FILE"
fi

python3 - "$SETTINGS_FILE" <<'PY'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])

if settings_path.exists() and settings_path.read_text().strip():
    try:
        data = json.loads(settings_path.read_text())
    except json.JSONDecodeError:
        backup_bad = settings_path.with_suffix(".json.invalid")
        settings_path.rename(backup_bad)
        print(f"WARNING: Existing settings.json was invalid JSON.")
        print(f"Moved invalid file to: {backup_bad}")
        data = {}
else:
    data = {}

# Disable VS Code built-in AI/Copilot-style features.
# This keeps Codex/OpenAI as the intended coding assistant.
data["chat.disableAIFeatures"] = True

# Extra Copilot-specific safety settings if the old extensions/settings exist.
data["github.copilot.enable"] = {"*": False}
data["github.copilot.editor.enableAutoCompletions"] = False

# Python editor behavior.
python_settings = data.get("[python]", {})
python_settings["editor.defaultFormatter"] = "ms-python.black-formatter"
python_settings["editor.formatOnSave"] = True

# VS Code newer versions expect string values like "explicit" here.
python_settings["editor.codeActionsOnSave"] = {
    "source.fixAll.ruff": "explicit",
    "source.organizeImports.ruff": "explicit"
}

data["[python]"] = python_settings

# Pylance.
data["python.analysis.typeCheckingMode"] = "basic"
data["python.analysis.autoImportCompletions"] = True

# Ruff.
data["ruff.enable"] = True

# Cleaner file explorer.
files_exclude = data.get("files.exclude", {})
files_exclude.update({
    "**/__pycache__": True,
    "**/*.pyc": True,
    "**/.pytest_cache": True,
    "**/.mypy_cache": True,
    "**/.ruff_cache": True
})
data["files.exclude"] = files_exclude

# Useful editor defaults.
data["editor.rulers"] = [88]
data["editor.tabSize"] = 4
data["editor.insertSpaces"] = True
data["files.trimTrailingWhitespace"] = True
data["files.insertFinalNewline"] = True

settings_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Wrote settings to: {settings_path}")
PY

echo

# ------------------------------------------------------------
# Optional Python project helper message
# ------------------------------------------------------------

echo "==> Done."
echo
echo "Recommended next steps for a Django project:"
echo
echo "  mkdir my_django_app && cd my_django_app"
echo "  python3 -m venv .venv"
echo "  source .venv/bin/activate"
echo "  python -m pip install --upgrade pip"
echo "  pip install django djangorestframework python-dotenv black ruff"
echo "  django-admin startproject config ."
echo "  python manage.py runserver"
echo
echo "Then open the folder:"
echo
echo "  code ."
echo
echo "Optional script flags:"
echo "  --with-docker     Install Docker extension"
echo "  --with-postgres   Install PostgreSQL extension"
echo "  --with-all        Install both"
echo
echo "Restart VS Code after this setup."
