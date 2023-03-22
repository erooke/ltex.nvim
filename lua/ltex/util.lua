local M = {}
--- Concat two lua ``arrays``
-- TODO surely this is built in somewhere?
function M.concat_array(t1, t2)
	n = #t1
	for i = 1, #t2 do
		t1[n + i] = t2[i]
	end
	return t1
end

--- Merge two lua tables which hold lists
function M.merge_list_table(t1, t2)
	result = {}

	for k, _ in pairs(t1) do
		result[k] = true
	end

	for k, _ in pairs(t2) do
		result[k] = true
	end

	for k, _ in pairs(result) do
		result[k] = M.concat_array(t1[k] or {}, t2[k] or {})
	end

	return result
end

function M.update_field(t1, field, t2)
	t1[field] = M.merge_list_table(t1[field] or {}, t2)

	return t1
end

return M
