local M = {}

local state = {
  win = nil,
  buf = nil,
}

local function is_window_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_buffer_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function close_window()
  if is_window_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  if is_buffer_valid(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
  state.win = nil
  state.buf = nil
end

local function open_floating_window(title)
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title or "Gemini",
    title_pos = "center",
  })

  state.buf = buf
  state.win = win

  return buf, win
end

local function get_visual_selection_or_line()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    local start_pos = vim.fn.getpos("<")
    local end_pos = vim.fn.getpos(">")
    local start_line = start_pos[2]
    local start_col = start_pos[3]
    local end_line = end_pos[2]
    local end_col = end_pos[3]

    if start_line > end_line or (start_line == end_line and start_col > end_col) then
      start_line, end_line = end_line, start_line
      start_col, end_col = end_col, start_col
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    if #lines == 0 then
      return ""
    end

    if mode == "v" then
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
      lines[1] = string.sub(lines[1], start_col)
    elseif mode == "\22" then
      -- blockwise: fall back to whole lines for simplicity
    end
    return table.concat(lines, "\n")
  else
    return vim.api.nvim_get_current_line()
  end
end

local function render_text(text)
  if not is_buffer_valid(state.buf) then
    open_floating_window("Gemini")
  end
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, vim.split(text or "", "\n", { plain = true }))
  if is_window_valid(state.win) then
    vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
  end
end

local function json_encode(tbl)
  return vim.fn.json_encode(tbl)
end

local function call_gemini_api(prompt, context)
  local api_key = os.getenv("GEMINI_API_KEY")
  if not api_key or api_key == "" then
    return nil, "GEMINI_API_KEY is not set"
  end

  local ok, curl = pcall(require, "plenary.curl")
  if not ok then
    return nil, "plenary.nvim is required (dependency of telescope). Please install it."
  end

  local body = {
    contents = {
      {
        role = "user",
        parts = {
          { text = "Context:\n" .. (context or "") },
          { text = "\n\nInstruction:\n" .. prompt },
        },
      },
    },
  }

  local url =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite-preview-06-17:generateContent?key=" ..
  api_key
  local res = curl.post(url, {
    headers = {
      ["Content-Type"] = "application/json",
    },
    body = json_encode(body),
    timeout = 30000,
  })

  if not res then
    return nil, "No response from Gemini API"
  end
  if res.status ~= 200 then
    return nil, string.format("Gemini API error (%s): %s", tostring(res.status), res.body or "")
  end

  local ok_decode, decoded = pcall(vim.json.decode, res.body)
  if not ok_decode then
    return nil, "Failed to parse Gemini response"
  end

  local text = nil
  if decoded and decoded.candidates and decoded.candidates[1] and decoded.candidates[1].content and decoded.candidates[1].content.parts then
    local parts = decoded.candidates[1].content.parts
    local texts = {}
    for _, part in ipairs(parts) do
      if type(part.text) == "string" then
        table.insert(texts, part.text)
      end
    end
    text = table.concat(texts, "\n")
  end

  if not text or text == "" then
    return nil, "Empty response from Gemini"
  end
  return text, nil
end

function M.toggle_cmdk()
  if is_window_valid(state.win) then
    close_window()
    return
  end

  local selection = get_visual_selection_or_line()
  open_floating_window("Gemini ▷ thinking…")
  render_text("Enter your question for Gemini...")

  vim.schedule(function()
    vim.ui.input({ prompt = "Gemini prompt: " }, function(input)
      if not input or input == "" then
        render_text("Cancelled.")
        return
      end
      render_text("Sending request to Gemini...")
      vim.schedule(function()
        local text, err = call_gemini_api(input, selection)
        if err then
          render_text("Error: " .. err)
          return
        end
        -- Render markdown/plain text
        render_text(text)
      end)
    end)
  end)
end

return M
