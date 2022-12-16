local keywords = {
  ["and"] = true,
  ["break"] = true,
  ["do"] = true,
  ["else"] = true,
  ["elseif"] = true,
  ["end"] = true,
  ["false"] = true,
  ["for"] = true,
  ["function"] = true,
  ["if"] = true,
  ["in"] = true,
  ["local"] = true,
  ["nil"] = true,
  ["not"] = true,
  ["or"] = true,
  ["repeat"] = true,
  ["return"] = true,
  ["then"] = true,
  ["true"] = true,
  ["until"] = true,
  ["while"] = true
}

local function is_keyword(str)
  return keywords[str] ~= nil
end

local function is_identifier(str)
  -- Check if the string starts with a letter or underscore
  if string.match(str, "^[%a_]") then
    -- Check if the string contains only letters, digits, and underscores
    return string.match(str, "^[%w_]*$") ~= nil
  end
  return false
end

local function is_number(str)
  -- Check if the string is a hexadecimal number
  if string.match(str, "^0x[%da-fA-F]+$") then
    return true
  end
  -- Check if the string is a decimal number
  return string.match(str, "^[%d%.]+$") ~= nil
end

local function is_string(str)
  -- Check if the string is a single-quoted string
  if string.match(str, "^'[^']*'$") then
    return true
  end
  -- Check if the string is a double-quoted string
  return string.match(str, '^"[^"]*"$') ~= nil
end

local function lex(str)
  local tokens = {}
  local current_token = ""
  local in_string = false
  local in_comment = false
  local in_long_comment = false
  local string_delimiter = ""
  for i = 1, #str do
    local c = string.sub(str, i, i)
    if in_string then
      if c == string_delimiter then
        in_string = false
        table.insert(tokens, {type = "string", value = current_token})
        current_token = ""
      else
        current_token = current_token .. c
      end
    elseif in_comment then
      if c == "\n" then
        in_comment = false
      end
    elseif in_long_comment then
      if string.sub(str, i, i + 1) == "--" then
        in_long_comment = false
      end
    elseif c == "-" and string.sub(str, i + 1, i + 1) == "-" then
      in_comment = true
    elseif c == "-" and string.sub(str, i + 1, i + 2) == "--" then
      in_long_comment = true
    elseif c == "'" or c == '"' then
      in_string = true
      string_delimiter = c
    elseif c == " " or c == "\t" or c == "\n" or c == "\r" then
      -- Ignore whitespace characters
    else
      current_token = current_token .. c
    end
  end
  if #current_token > 0 then
    if is_keyword(current_token) then
      table.insert(tokens, {type = "keyword", value = current_token})
    elseif is_identifier(current_token) then
      table.insert(tokens, {type = "identifier", value = current_token})
    elseif is_number(current_token) then
      table.insert(tokens, {type = "number", value = current_token})
    else
      error("Unexpected token: " .. current_token)
    end
  end
  return tokens
end
