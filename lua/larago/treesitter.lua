local ts = vim.treesitter
local M = {}

M.getRoot = function(language, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, language, {})
    local tree = parser:parse()[1]
    return tree:root(), bufnr
end

M.cursor = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local node = vim.treesitter.get_node_at_pos(0, row - 1, col, {})
    return node
end

M.get_name = function(node)
    node = node or M.cursor()
    return ts.query.get_node_text(node, 0, {}) -- empty brackets are important
end

M.parent = function(type)
    local node = M.cursor()
    while node and node:type() ~= type do
        node = node:parent()
    end
    return node
end

M.child = function(cnode, cname)
    cnode = cnode or M.cursor()
    for node, name in cnode:iter_children() do
        if node:named() then
            if name == cname then
                return node
            end
        end
    end
end

M.child_type = function(node, type)
    local id = 0
    local child = node:child(id)
    while child do
        if child:type() == type then
            break
        end
        id = id + 1
        child = node:child(id)
    end
    return child
end

M.children = function(cnode, type)
    cnode = cnode or M.cursor()
    for node, _ in cnode:iter_children() do
        if node:type() == type then
            return M.get_name(node) --  perhaps returning node could be better idea
        end
    end
end

return M
