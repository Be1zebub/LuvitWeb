local luahtml = require("luahtml")
local http, https, fs = require("http"), require("https"), require("fs")

local function IsDir(path)
    local f = io.open(path, "r")
    local ok, err, code = f:read(1)
    f:close()
    return code == 21
end

local function ScanDir(path, cback, dirs)
	fs.readdir(path, function(_, files)
		for i, name in ipairs(files) do
			local fpath = path .."/".. name
			if IsDir(fpath) then
				if dirs == nil then dirs = {} end
				table.insert(dirs, name)
				ScanDir(fpath, cback, dirs)
			else
				cback(fpath, dirs or {""})
			end
		end
	end)
end

return function(path, domain, http_port, https_port)
	local path_patterns = {
		"/index.html",
		"/index.html.lua",
		"/index.htmllua",
		"/index.lua.html",
		"/index.lua",
		"/"
	}

	local pages, pages_str = {}, ""

	ScanDir(path, function(fpath, dirs)
		local path = table.concat(dirs, "/")
		pages[path] = fpath

		for i, pp in ipairs(path_patterns) do
			pages[path .. pp] = fpath
		end

		pages["/".. path] = fpath

		pages_str = pages_str .."\n\"".. path .."\" > ".. fpath
	end)

	local function onRequest(req, res)
		local function response(body, code)
			res:setHeader("Content-Type", "text/plain")
			res:setHeader("Content-Length", #body)
			res.statusCode = code or 200
			res:finish(body)
		end

		if pages[req.url] then
			local succ, body = luahtml.evalfile(pages[req.url])
			return response(succ and body or "FILE NOT FOUND", succ and 200 or 404)
		end

		response("404 Page not found\nEndpoints:\n".. pages_str, 404)
	end

	http.createServer(onRequest):listen(http_port)

	https.createServer({
	  key = fs.readFileSync("/etc/letsencrypt/live/".. domain .."/privkey.pem"),
	  cert = fs.readFileSync("/etc/letsencrypt/live/".. domain .."/cert.pem"),
	}, onRequest):listen(https_port)
end

--[[ Example:
	local luahtml_server = require("luahtml_server")
	luahtml_server("/var/www/mysite", "incredible-gmod.ru", 1000, 2000)
]]--
