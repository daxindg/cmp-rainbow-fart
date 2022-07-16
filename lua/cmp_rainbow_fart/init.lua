local source = {}

local defaults = {
  on = true
}

local init_option = function(params)
  params.option = vim.tbl_deep_extend("keep", params.option, defaults)
  vim.validate({
    on = { params.option.on, 'boolean' }
  })
end

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.commit_items = nil
  self.insert_items = nil
  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = nil
  self.voices = require('cmp_rainbow_fart.voice')()
  self.on = nil
  vim.api.nvim_create_user_command('RainbowFartToggle', function()
    if self.on == nil then
      self.on = defaults.on
    end
    self.on = not self.on
  end, {})
  return self
end

source.get_keyword_pattern = function()
  return [[ ]]
end
source.showBuf = function(self, text)
  local width = 50
  local height = 10

  local ui = vim.api.nvim_list_uis()[1]

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (ui.width / 2) - (width / 2),
    row = (ui.height / 2) - (height / 2),
    anchor = 'NW',
    style = 'minimal',
  }
  if self.win ~= nil then
    vim.api.nvim_win_close(self.win, true)
  end
  vim.api.nvim_buf_set_lines(self.buf, 1, 2, false, { text })
  self.win = vim.api.nvim_open_win(self.buf, 1, opts)
end

source.complete = function(self, params, callback)
  callback()

  if self.on == nil then
    init_option(params)
    self.on = params.option.on
  end

  if not self.on then
    return
  end
  local line = params.context.cursor_before_line
  local res = self.voices.get_voice_path(self.voices, line)
  if res ~= nil then
    print(res)
    self.voices.play(self.voices, res)
  end
end

source.option = function(_, params)
  return vim.tbl_extend('force', {
    insert = false,
  }, params.option)
end

return source
