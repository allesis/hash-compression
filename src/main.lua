local data_table = [[
<table>
	<tr>
		<% for k,v in ipairs(CSV_DATA.keys) do -%>
			<th><%= v -%></th>
		<% end -%>
	</tr>
	<% for keys,values in ipairs(ROTATE_TABLE(CSV_DATA.values)) do -%>
		<tr>
			<% for k,v in ipairs(values) do -%>
				<td><%= v -%></td>
			<% end -%>
		</tr>
	<% end -%>
</table>
]]

local outer = [[
<!DOCTYPE html>
<html>
<head>
<title>Compression Results</title>
<link rel="stylesheet" href="<%= pathToRoot %>style.css" />
</head>
<body>
<%- content %>
</body>
</html>
]]

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local function parse_csv_line(line)
	local result = {}
	local from = 1
	local sep = ","
	local field
	while true do
		local start, finish = string.find(line, sep, from)
		if not start then
			table.insert(result, string.sub(line, from))
			break
		end
		field = string.sub(line, from, start - 1)
		table.insert(result, field)
		from = finish + 1
	end
	return result
end

function ROTATE_TABLE(input_table)
	local output_table = {}
	for col = 1, #input_table[1] do
		local column_values = {}
		for key, inner in pairs(input_table) do
			column_values[key] = inner[col]
		end
		table.insert(output_table, column_values)
	end
	return output_table
end

local function read_csv(filepath)
	local file = io.open(filepath, "r")

	local csv = { keys = {}, values = {} }

	for line in file:lines() do
		local values = parse_csv_line(line)
		if #csv.keys == 0 then
			for i, v in ipairs(values) do
				csv.keys[i] = v
				table.insert(csv.values, {})
			end
		else
			for i, v in ipairs(values) do
				table.insert(csv.values[i], v)
			end
		end
	end

	return csv
end

CSV_DATA = read_csv(os.getenv("PERF_DATA_DIRECTORY"))

return {
	readFromSource("content"),
	aggregate("index.html", "%.html$"),

	applyTemplates({ { "index.html", data_table } }),
	applyTemplates({ { "index.html", outer } }),

	writeToDestination("out"),
}
