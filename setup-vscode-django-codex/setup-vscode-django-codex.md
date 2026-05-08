# VS Code Django + Codex Environment Setup

This document explains how to use the companion script:

```bash
setup-vscode-django-codex.sh
```

The script is intended for **Ubuntu users** who want a clean VS Code setup for building **Django applications** while using the **OpenAI Codex extension** as the main coding assistant.

---

## What the script does

The script performs four main tasks:

1. Verifies that the VS Code command-line tool `code` is available.
2. Removes old GitHub Copilot extensions if they are installed.
3. Installs recommended VS Code extensions for Django/Python development.
4. Updates your VS Code user settings for Python formatting, linting, and AI feature control.

---

## Installed VS Code extensions

The script installs these required extensions:

```text
openai.chatgpt
ms-python.python
ms-python.vscode-pylance
ms-python.debugpy
charliermarsh.ruff
ms-python.black-formatter
batisteo.vscode-django
qwtel.sqlite-viewer
humao.rest-client
mikestead.dotenv
eamodio.gitlens
usernamehw.errorlens
redhat.vscode-yaml
```

### Extension purpose

| Extension | Purpose |
|---|---|
| `openai.chatgpt` | OpenAI / Codex extension |
| `ms-python.python` | Core Python support |
| `ms-python.vscode-pylance` | Python language server, autocomplete, type checking |
| `ms-python.debugpy` | Python debugger |
| `charliermarsh.ruff` | Fast Python linting and import cleanup |
| `ms-python.black-formatter` | Python formatting with Black |
| `batisteo.vscode-django` | Django template support |
| `qwtel.sqlite-viewer` | View local SQLite databases such as `db.sqlite3` |
| `humao.rest-client` | Test HTTP endpoints from `.http` files |
| `mikestead.dotenv` | `.env` syntax highlighting |
| `eamodio.gitlens` | Git history and blame tools |
| `usernamehw.errorlens` | Inline display of errors and warnings |
| `redhat.vscode-yaml` | YAML support for config files, Docker Compose, CI/CD, etc. |

---

## Optional extensions

The script supports optional flags.

### Docker extension

```bash
./setup-vscode-django-codex.sh --with-docker
```

Installs:

```text
ms-azuretools.vscode-docker
```

Use this if your Django project will use Docker, Docker Compose, Redis, PostgreSQL, Celery, Nginx, or similar services.

### PostgreSQL extension

```bash
./setup-vscode-django-codex.sh --with-postgres
```

Installs:

```text
cweijan.vscode-postgresql-client2
```

Use this if your Django project uses PostgreSQL instead of SQLite.

### Install all optional extensions

```bash
./setup-vscode-django-codex.sh --with-all
```

This installs both Docker and PostgreSQL helper extensions.

---

## How to run the script

Download or place the script in your desired folder.

Make it executable:

```bash
chmod +x setup-vscode-django-codex.sh
```

Run the base setup:

```bash
./setup-vscode-django-codex.sh
```

Or run the full setup:

```bash
./setup-vscode-django-codex.sh --with-all
```

Restart VS Code after running the script.

---

## What VS Code settings are changed

The script updates this file:

```bash
~/.config/Code/User/settings.json
```

If an existing settings file is found, the script creates a backup first:

```bash
~/.config/Code/User/settings.json.backup.YYYYMMDD-HHMMSS
```

The script adds or updates settings similar to this:

```json
{
  "chat.disableAIFeatures": true,
  "github.copilot.enable": {
    "*": false
  },
  "github.copilot.editor.enableAutoCompletions": false,

  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  },

  "python.analysis.typeCheckingMode": "basic",
  "python.analysis.autoImportCompletions": true,
  "ruff.enable": true,

  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true,
    "**/.pytest_cache": true,
    "**/.mypy_cache": true,
    "**/.ruff_cache": true
  },

  "editor.rulers": [88],
  "editor.tabSize": 4,
  "editor.insertSpaces": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

---

## Important note about AI features

The setting:

```json
"chat.disableAIFeatures": true
```

is used to disable VS Code's built-in AI/Copilot-style features.

The goal is to keep **Codex/OpenAI** as the primary coding assistant and avoid having multiple AI assistants competing inside the editor.

If this disables more AI UI than you want, remove or change that setting manually in:

```bash
~/.config/Code/User/settings.json
```

---

## Recommended Django project setup

After running the VS Code setup script, you can create a Django project like this:

```bash
mkdir my_django_app
cd my_django_app

python3 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
pip install django djangorestframework python-dotenv black ruff

django-admin startproject config .
python manage.py runserver
```

Then open the project in VS Code:

```bash
code .
```

---

## Recommended project files

For a clean Django project, consider adding these files:

```text
.env
.gitignore
README.md
requirements.txt
pyproject.toml
```

Example `.gitignore`:

```gitignore
.venv/
__pycache__/
*.pyc
.env
db.sqlite3
.pytest_cache/
.mypy_cache/
.ruff_cache/
```

Example `requirements.txt`:

```text
django
djangorestframework
python-dotenv
black
ruff
```

Example `pyproject.toml`:

```toml
[tool.black]
line-length = 88

[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP"]
ignore = []
```

---

## Verify installed extensions

Check installed extensions:

```bash
code --list-extensions
```

Check for OpenAI/Codex:

```bash
code --list-extensions | grep -Ei "openai|chatgpt|codex"
```

Check for Copilot:

```bash
code --list-extensions | grep -Ei "copilot"
```

If Copilot does not appear, the old Copilot extensions are not installed.

---

## Troubleshooting

### `code: command not found`

VS Code CLI is not available.

Open VS Code and run:

```text
Ctrl + Shift + P
```

Then search for:

```text
Shell Command: Install 'code' command in PATH
```

After that, close and reopen the terminal.

---

### Extensions fail to install

Check that VS Code is installed correctly:

```bash
code --version
```

Then try installing one extension manually:

```bash
code --install-extension ms-python.python
```

---

### Settings file becomes invalid

The script tries to safely edit JSON. If your original `settings.json` is invalid, the script moves it to:

```bash
~/.config/Code/User/settings.json.invalid
```

Then it creates a new valid settings file.

---

### Codex extension does not appear

Restart VS Code after installation.

Then check:

```bash
code --list-extensions | grep -Ei "openai|chatgpt"
```

You may need to sign in to your OpenAI/ChatGPT account inside VS Code.

---

## Uninstalling installed extensions

You can uninstall an extension with:

```bash
code --uninstall-extension EXTENSION_ID
```

Example:

```bash
code --uninstall-extension usernamehw.errorlens
```

---

## Restoring old VS Code settings

If you want to restore your previous settings, look for a backup file:

```bash
ls ~/.config/Code/User/settings.json.backup.*
```

Then copy the backup over the current settings file:

```bash
cp ~/.config/Code/User/settings.json.backup.YYYYMMDD-HHMMSS ~/.config/Code/User/settings.json
```

Restart VS Code after restoring.

---

## Suggested workflow with Codex

A good workflow is:

1. Create a clean Django project.
2. Open the folder in VS Code.
3. Ask Codex to create or modify one feature at a time.
4. Review generated code before running migrations.
5. Use Ruff and Black on save.
6. Test endpoints using REST Client.
7. Inspect local data with SQLite Viewer or PostgreSQL extension.

Example Codex prompts:

```text
Create a Django app called accounts with a custom user model.
```

```text
Add Django REST Framework serializers and viewsets for this model.
```

```text
Review this Django settings.py file for security problems before production.
```

```text
Create pytest tests for these Django views.
```

---

## Recommended minimal setup

For most Django projects, the most important pieces are:

```text
OpenAI / Codex
Python
Pylance
Python Debugger
Ruff
Black Formatter
Django
SQLite Viewer
DotENV
REST Client
```

The rest are useful but optional.
