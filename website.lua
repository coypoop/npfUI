package.path = 'lib/?.lua'
require 'common'
require 'csrf'

local httpd = require 'httpd'

function print_begin()

	httpd.write("HTTP/1.1 200 Ok\r\n")
	httpd.write("Content-Type: text/html\r\n\r\n")

	httpd.print([[
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta charset="UTF-8">
    <title>npfUI - configure your NetBSD network</title>
    <link rel="stylesheet" href="style/reset.css">
    <link rel="stylesheet" href="style/style.css">
    <script>
      function remove_entry(x) {
        elem = document.getElementById(x);
        elem.parentNode.removeChild(elem);
      }

      function get_index(elem) {
        for (i = 1; !!document.getElementById(elem + i); ++i) { }
        return i;
      }

      /* XXX dedup code */
      function insert_new_blocked_entry() {
        new_idx = get_index('blocked-entry');
        old_elem = document.getElementById('blocked-newentry');
				new_id_name = 'blocked-entry' + new_idx;
        old_elem.insertAdjacentHTML('beforebegin','\
          <tr id="'+ new_id_name + '">\
            <td><button type="button" onclick="remove_entry(\'' + new_id_name + '\');">➖</button></td>\
            <td><input type="text" name="blocked-ip" /></td>\
					</tr>\
        ');
      }

      function insert_new_static_entry() {
        new_idx = get_index('dhcp-entry');
        old_elem = document.getElementById('dhcp-newentry');
				new_id_name = 'dhcp-entry' + new_idx;
        old_elem.insertAdjacentHTML('beforebegin','\
          <tr id="'+ new_id_name + '">\
            <td><button type="button" onclick="remove_entry(\'' + new_id_name + '\');">➖</button></td>\
            <td><input type="text" name="dhcp-ip" /></td>\
            <td><input type="text" name="dhcp-mac" /></td>\
					</tr>\
        ');
      }
    </script>
  </head>
	]])
end

function print_end()
	httpd.print([[
  </body>
</html>
	]])
end

function initial_setup(env, headers, query)
  print_begin()
  print_menu()
  print_content_initial_setup()
  print_end()
end

function blocked(env, headers, query)
  print_begin()
  print_menu()
  print_content_blocked()
  print_end()
end

-- XXX XXX do something
function submit(env, header, query)

	httpd.write("HTTP/1.1 200 Ok\r\n")
	httpd.write("Content-Type: text/html\r\n\r\n")

	if query ~= nil then
    httpd.print('valid token?')
    if valid_token(query['csrf-token']) then
      httpd.print('yep')
    else
      httpd.print('no')
    end

		if env.CONTENT_TYPE ~= nil then
			httpd.print('Content-type: ' .. env.CONTENT_TYPE .. '<br>')
		end

		for k, v in pairs(query) do
			httpd.print(k .. '=' .. v .. '<br/>')
		end
	else
		httpd.print('No values')
	end
end

-- XXX active should be the current page, not fixed
function print_menu()
  httpd.print([[
  <body>
    <input id="hamburger" type="checkbox" checked>
      <label class="menuicon" for="hamburger">
      <span></span>
      </label>

    <div class="menu">
      <h1>npfUI</h1>
      <div class="active">
        <a href="initial_setup">Initial Setup</a>
      </div>
      <div>
        <a href="blocked">Block Connections</a>
        <a>Static Blocks</a>
        <a>Dynamic Blocks</a>
      </div>
      <div>
        <a href="allowed">Allow Connections</a>
        <a>Port Forwarding</a>
        <a>Whitelist (Dynamic)</a>
      </div>
      <div>
        <a href="status">Status</a>
        <a>Status</a>
        <a>Graphs</a>
      </div>
      <div>
        <a href="syslog">System Log</a>
      </div>
    </div>
  ]])
end

function print_content_initial_setup()
  -- XXX move styling of header to style.css
  httpd.print([[
    <div class="header" style="background: #bfbfbf; font-size: 2.5em; text-align: right;">Initial Setup</div>
    <div class="content initial-setup">
      <table>
        <tbody>
          <form action="submit">
            <tr>
              <td></td>
              <td>External Interface</td>
              <td>
                <select>
  ]])
  -- XXX selected interface should be the one currently used.
    for k, v in pairs(ifaces_all()) do
        print('<option>' .. v .. '</option>')
    end
  httpd.print([[
                </select>
              </td>
            </tr>
            <tr>
              <td></td>
              <td>Connection Method</td>
              <td>
                <input type="radio" name="connection-method" value="dhcp">Automatic (DHCP)
                <input type="radio" name="connection-method" value="static">Manual
              </td>
            </tr>
            <tr>
              <td></td>
              <td>IP Address</td>
  ]])
  httpd.print('<td><input type="text" name="static-ip" value="' .. current_ip() .. '" /></td>')
  httpd.print([[
            </tr>
            <tr>
              <td></td>
              <td>Gateway</td>
  ]])
  httpd.print('<td><input type="text" name="static-gateway" value="' .. current_gateway() .. '" /></td>')
  httpd.print([[
            </tr>
            <tr>
              <td></td>
              <td>DNS Server</td>
  ]])
  -- XXX messy with multiple DNS servers.
  httpd.print('<td><input type="text" name="dns" value="' .. current_dns() .. '" /></td>')
  httpd.print([[
            </tr>
            <tr>
              <td></td>
              <td>DHCP</td>
  ]])
  httpd.print('<td><input type="checkbox" name="dhcp-server" ' .. dhcpd_checked() ..' /></td>')
  httpd.print([[
            </tr>
            <tr>
              <td></td>
              <td>NAT</td>
  ]])
  httpd.print('<td><input type="checkbox" name="nat" ' .. nat_checked() .. ' /></td>')
  httpd.print([[
            </tr>
            <tr>
              <td>Static IPs</td>
              <td>IP Address</td>
              <td>MAC Address</td>
            </tr>
            <tr id="dhcp-newentry">
              <td><button type="button" onclick="insert_new_static_entry()">➕</button></td>
              <td></td>
              <td></td>
            </tr>
            <tr>
              <td></td>
	]])
	httpd.print('<td><input type="hidden" name="csrf-token" value="' .. generate_token() .. '"/></td>')
	httpd.print([[
              <td style="text-align: center;"><input type="submit" value="Submit" /></td>
            </tr>
          </tbody>
        </form>
      </table>
		</div>
  ]])
end

-- XXX grab currently blocked IPs
function print_content_blocked()
  -- XXX move styling of header to style.css
  httpd.print([[
    <div class="header" style="background: #ff2f2f; font-size: 2.5em; text-align: right;">Block Connections</div>
    <div class="content block-connections">
      <table>
        <form action="submit">
          <tbody>
            <tr>
              <td>Statically blocked IPs</td>
              <td>IP Address</td>
            </tr>
            <tr id="blocked-entry1">
              <td><button type="button" onclick="remove_entry('blocked-entry1');">➖</button></td>
              <td><input type="text" name="blocked-ip" /></td>
            </tr>
            <tr id="blocked-newentry">
              <td><button type="button" onclick="insert_new_blocked_entry()">➕</button></td>
              <td></td>
            </tr>
            <tr>
	]])
	httpd.print('<td><input type="hidden" name="csrf-token" value="' .. generate_token() .. '"/></td>')
	httpd.print([[
              <td style="text-align: center;"><input type="submit" value="Submit" /></td>
            </tr>
          </tbody>
        </form>
      </table>
		</div>
  ]])
end

-- register this handler for http://<hostname>/<prefix>/initial_setup
httpd.register_handler('initial_setup', initial_setup)
httpd.register_handler('blocked', blocked)
httpd.register_handler('submit', submit)

