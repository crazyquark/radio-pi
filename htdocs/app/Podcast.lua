--[[
-- Copyright (c) 2013 Marcus Rohrmoser, https://github.com/mro/radio-pi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
-- associated documentation files (the "Software"), to deal in the Software without restriction,
-- including without limitation the rights to use, copy, modify, merge, publish, distribute,
-- sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
-- NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
-- OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- MIT License http://opensource.org/licenses/MIT
]]

-- http://nova-fusion.com/2011/06/30/lua-metatables-tutorial/
-- http://lua-users.org/wiki/LuaClassesWithMetatable
Podcast = {}							-- methods table
Podcast_mt = { __index = Podcast }		-- metatable

function Podcast.each()
	if not Podcast._each then
		local ret = {}
		for pc_id in lfs.dir('podcasts') do
			ret[pc_id] = Podcast.from_id(pc_id)
		end
		Podcast._each = ret
	end
	return Podcast._each
end


function Podcast.from_id(id)
	local pc = nil
	if Podcast._each then pc = Podcast._each[id] end
	if not pc then
		local f = table.concat{'podcasts', '/', id, '/', 'app', '/', 'podcast.cfg'}
		local fh,msg = io.open(f,'r')
		if not fh then return nil,msg end
		local m,msg = loadstring('return ' .. assert(fh, msg):read('*a'))()
		fh:close()
		io.stderr:write('loading ', f, "\n")
		local ret = {
			id = id,
			title = assert(m.title, 'bo title'),
			subtitle = assert(m.subtitle, 'no subtitle'),
			episodes_to_keep = assert(m.episodes_to_keep, 'episodes'),
			match = assert(m.match, 'match'),
		}
		pc = setmetatable( ret, Podcast_mt )
		-- Podcast._each[id] = pc
	end
	return pc
end


function Podcast:contains_broadcast(bc)
	return 'file' == lfs.attributes(table.concat{'podcasts', '/', self.id, '/', bc.id, '.xml'}, 'mode')
end


function Podcast:add_broadcast(bc)
	return io.write_if_changed(table.concat{'podcasts', '/', self.id, '/', bc.id, '.xml'}, '')
end


function Podcast:remove_broadcast(bc)
	os.remove(table.concat{'podcasts', '/', self.id, '/', bc.id, '.xml'})
end


function Podcast:broadcasts(comparator)
	local tmp = {}
	local callback = function(file,t) table.insert( tmp, assert(Broadcast.from_file(file)) ) end
	local base = table.concat{'podcasts', '/', self.id}
	for station_id in lfs.dir(base) do
		local sta = table.concat{base, '/', station_id}
		if 'directory' == lfs.attributes(sta, 'mode') then
			lfs.files_between(sta, nil, nil, callback, true)
		end
	end
	if not comparator then
		comparator = function(a,b) return a:dtstart() < b:dtstart() end
	end
	table.sort(tmp, comparator)
	return tmp
end


local slt2 = require "slt2" -- http://github.com/henix/slt2

function Podcast:template_rss()
	local tmpl = self.template_rss_
	if not tmpl then
		local file = table.concat({ 'podcasts', assert(self.id), 'app', 'podcast.slt2.rss'}, '/')
		-- io.stderr:write('loading template \'', file, '\'\n')
		tmpl = slt2.loadfile(file)
		self.template_rss_ = tmpl
		io.stderr:write('loaded template ', file, '\n')
	end
	return tmpl
end

function Podcast:save_rss()
	local rss_file = table.concat{'podcasts', '/', assert(self.id), '.rss'}
	local rss_new = slt2.render(assert(self:template_rss()), {podcast=self})
	return io.write_if_changed(rss_file, rss_new)
end
