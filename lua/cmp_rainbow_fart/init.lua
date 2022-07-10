local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.commit_items = nil
  self.insert_items = nil
  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = nil
  self.voices = require('cmp_rainbow_fart.voice')()
  return self
end

source.get_keyword_pattern = function()
  return [[ ]]
end
source.showBuf =function(self, text)
    local width = 50
    local height = 10

    local ui = vim.api.nvim_list_uis()[1]

    local opts = {
      relative = "editor",
      width = width,
      height= height,
      col= (ui.width/2) - (width/2),
      row= (ui.height/2) - (height/2),
      anchor= 'NW',
      style= 'minimal',
    }
    if self.win ~= nil then
      vim.api.nvim_win_close(self.win, true)
    end
    vim.api.nvim_buf_set_lines(self.buf, 1, 2, false, {text})
    self.win = vim.api.nvim_open_win(self.buf, 1, opts)
 end

source.complete = function(self, params, callback)
  -- Avoid unexpected completion.
  callback()
  local kw = ""
  local sep = "%s"
  for str in string.gmatch(params.context.cursor_before_line, "([^"..sep.."]+)") do
    kw = str
  end
  local res = self.voices.get_voice_path(self.voices, kw)
  if res ~= nil then
    local co = coroutine.create(
      function()
        self.voices.play(res)
      end
    )
    coroutine.resume(co)
  end
end

source.option = function(_, params)
  return vim.tbl_extend('force', {
    insert = false,
  }, params.option)
end

return source

