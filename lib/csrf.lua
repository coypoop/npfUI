function string_to_table(str)
	tbl = {}
	if str then
		for i in string.gmatch(str, "%S+") do
			table.insert(tbl, i)
		end
	end
	return tbl
end

function generate_token()
	local oldTokenTable
	local newTokenTable = {}

	local newTokenHandle = io.popen("uuidgen")
	local newToken = newTokenHandle:read("*line")
	newTokenHandle:close()

	local file = io.open("../CSRF-tokens", "r")
	if file then
		oldTokenTable = string_to_table(file:read("*all"))
		file:close()
	else
		oldTokenTable = {}
	end

	file = io.open("../CSRF-tokens", "w")

	local i = 1
	newTokenTable[i] = newToken

	while oldTokenTable[i] and i < 20 do
		newTokenTable[i+1] = oldTokenTable[i]
		i = i + 1
	end

	file:write(table.concat(newTokenTable,"\n"))

	file:close()

	return newToken
end

function valid_token(token)
	local file = io.open("../CSRF-tokens", "r")
	local validTokens = string_to_table(file:read("*all"))
	file:close()

	for _, v in pairs(validTokens) do
		if token == v then
			return true
		end

	end
	return false
end
