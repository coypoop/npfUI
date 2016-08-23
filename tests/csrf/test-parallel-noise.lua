package.path = '../../lib/?.lua'

require 'libcsrf'

for i = 1, 10 do
	for i = 1,5 do
		generate_token()
	end
	os.execute("sleep 1")
end
