package.path = '../../lib/?.lua'

require 'libcsrf'

-- it's statistically improbable that it will match this value.
local badval = 'd3268e11-e07e-480a-80d1-7c9f4b38b497'
local goodval, goodval1, goodval2

assert(not valid_token(badval))
goodval = generate_token()
assert(valid_token(goodval))

for i = 1, 50 do
	goodval1 = generate_token()
	for i = 1,18 do
		generate_token()
	end
	goodval2 = generate_token()
	-- token from a while back is still good.
	assert(valid_token(goodval1))
	-- latest token good.
	assert(valid_token(goodval2))
end

-- by now, the initial token expired.
assert(not valid_token(goodval))
print("success!")
