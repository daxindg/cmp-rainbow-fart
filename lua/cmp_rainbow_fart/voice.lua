local voice = {}
local base = vim.fn.stdpath("data").."/site/pack/packer/start/cmp-rainbow-fart/"
local prefix = base.."lua/cmp_rainbow_fart/".."built-in-voice-packages/built-in-voice-chinese/"
local player = base.."bin/aplay"

local file_exists = function(name)
	local f = io.open(name,"r")
	if f then
		io.close(f)
		return true
	else
		return false
	end
end

local build = function()
  io.popen('sh -c "cd '..base..' && cargo build --release > /dev/null && mkdir -p bin && mv target/release/aplay bin"')
end

voice.new = function()
  local self = setmetatable({}, { __index = voice })
  self.kv = {}
  for _, e in ipairs(voice._read(prefix..'contributes.json').contributes) do
    for _, k in ipairs(e.keywords) do
      if self.kv[k] == nil then
        self.kv[k] = {}
      end
      for _, v in ipairs(e.voices) do
        table.insert(self.kv[k], v)
      end
    end
  end
  if file_exists(player) ~= true then
    build()
  end
  return self
end

voice._read = function(path)
  return vim.fn.json_decode(vim.fn.readfile(path))
end

voice.get_voice_path = function(self, keyword)
  local voices = self.kv[keyword]
  if voices == nil then
    return nil
  end

  math.randomseed(os.time())
  return prefix..voices[math.random(1, #voices)]
end


voice.play = function(path)
  io.popen(player.." "..path)

  -- local ffi = require("ffi")
  -- ffi.cdef[[
  -- void aplay(char * uri);
  -- ]]
  -- local lib = ffi.load(libpath)

  -- local c_path = ffi.new("char[?]", #path + 1)
  -- ffi.copy(c_path, path)

  -- lib.aplay(c_path)
end

return function()
  return voice:new()
end

