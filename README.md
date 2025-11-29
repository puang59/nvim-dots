# nvim config

## Gemini Cmd+K Assistant

- Set environment variable `GEMINI_API_KEY` before launching Neovim.
  - macOS (zsh): add to `~/.zshrc`:
    ```bash
    export GEMINI_API_KEY="your_api_key_here"
    ```
- Usage:
  - Select code in visual mode (or keep cursor on a line)
  - Press `Cmd+K` to open the Gemini window
  - Enter your question; the selected text/line is sent as context
  - Press `Cmd+K` again to close the window

pretty hot innit
