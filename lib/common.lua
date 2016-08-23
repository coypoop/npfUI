
function shellcmd_success(shellcmd)
  local handle = io.popen(shellcmd .. "&& echo $?")
  local resultstr = handle:read("*all")
  handle:close()
  return (tonumber(resultstr) == 0)
end

function shell_to_string(shellcmd)
  local handle = io.popen(shellcmd)
  local string = handle:read("*all")
  handle:close()
  return string
end

function file_to_string(filename)
  local file = io.open(filename, "rb")
  if not file then return "" end
  local string = file:read("*all")
  file:close()
  return string
end

function space_separated_string_to_table(string)
	local result_table = {}
	for k,v in string.gmatch(string, "[^%s]+") do
    table.insert(result_table, k)
	end
	return result_table
end

function ifconfig_status(iface)
  return shell_to_string("ifconfig " .. iface)
end

function ifconfig_read_conf(iface)
	local file = io.open("/etc/ifconfig." .. iface, "rb")
	if not file then return ifconfig_example() end
	local result = file:read "*all"
	file:close()
	return result
end

function dhcpcd_read_conf()
	local file = io.open("/etc/dhcpcd.conf", "rb")
	if not file then return dhcpcd_example() end
	local result = file:read "*all"
	file:close()
	return result
end

function npf_read_conf()
	local file = io.open("/etc/npf.conf", "rb")
	if not file then return npf_example() end
	local result = file:read "*all"
	file:close()
	return result
end

function npf_example()
	local file = io.open("examples/npf.conf", "rb")
	if not file then return nil end
	local result = file:read "*all"
	file:close()
	return result
end

-- XXX add blacklistd chunk in by default
function npf_status()
	-- don't show all the config
	local handle = io.popen("npfctl show |grep '^#'")
	local npf_status = handle:read("*all")
	handle:close()

	return npf_status
end

function dhcpd_read_conf()
	local file = io.open("/etc/dhcpd.conf", "rb")
	if not file then return dhcpd_example() end
	local result = file:read "*all"
	file:close()
	return result
end

function dhcpd_example()
	local file = io.open("examples/dhcpd.conf", "rb")
	if not file then return nil end
	local result = file:read "*all"
	file:close()
	return result
end

-- XXX better dhcpd status
function dhcpd_status()
	local handle = io.popen("service dhcpd status")
	local result = handle:read("*all")
	handle:close()

	return result
end

function blacklistd_read_conf()
	local file = io.open("/etc/blacklistd.conf", "rb")
	if not file then return dhcpd_example() end
	local result = file:read "*all"
	file:close()
	return result
end

function blacklistd_example()
	local file = io.open("examples/blacklistd.conf", "rb")
	if not file then return nil end
	local result = file:read "*all"
	file:close()
	return result
end

function blacklistd_status()
	local handle = io.popen("blacklistctl dump -a")
	local result = handle:read("*all")
	handle:close()

	return result
end

function ifaces_all()
	local handle = io.popen("ifconfig -lb")
	local string = handle:read("*all")
	handle:close()

	return space_separated_string_to_table(string .. ifaces_special())
end

-- interfaces that won't be listed normally
-- XXX check if they are already listed
function ifaces_special()
  return "urndis0"
end

function make_tmp_copy(filename)
  local old_file = io.open(filename, "rb")

	if not old_file then return nil end
	old_file_contents = old_file:read("*all")

	local file = io.popen("mktemp")
	local tmp_filename = file:read("*line")
	file:close() -- ... races? (man mktemp)

	local new_file = io.open(tmp_filename, "w+")
	new_file:write(old_file_contents)
	new_file:close()

	return tmp_filename
end

function dhcpd_checked()
  if shellcmd_success("service dhcpd status") then
    return "checked"
  else
    return ""
  end
end

function nat_checked()
  if shellcmd_success("grep -q '<-' /etc/npf.conf") then
    return "checked"
  else
    return ""
  end
end

function current_dns()
  return shell_to_string("resolvconf -l |grep nameserver |sed 's/^nameserver //'")
end

function current_gateway()
  return shell_to_string("route -s get default")
end

function current_ip()
  return shell_to_string("route get default |grep local |sed 's/^.*: //'")
end
