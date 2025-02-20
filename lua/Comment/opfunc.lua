local U = require('Comment.utils')
local A = vim.api
local op = {}

---Opfunc options
---@class OpFnParams
---@field cfg Config
---@field cmode CMode
---@field lines table
---@field rcs string
---@field lcs string
---@field scol number
---@field ecol number
---@field srow number
---@field erow number

---Linewise commenting
---@param p OpFnParams
---@return integer CMode
function op.linewise(p)
    local lcs_esc, rcs_esc = U.escape(p.lcs), U.escape(p.rcs)

    -- While commenting a block of text, there is a possiblity of lines being both commented and non-commented
    -- In that case, we need to figure out that if any line is uncommented then we should comment the whole block or vise-versa
    local cmode = U.cmode.uncomment

    -- When commenting multiple line, it is to be expected that indentation should be preserved
    -- So, When looping over multiple lines we need to store the indentation of the mininum length (except empty line)
    -- Which will be used to semantically comment rest of the lines
    local min_indent = nil

    -- Computed ignore pattern
    local pattern = U.get_pattern(p.cfg.ignore)

    -- If the given comde is uncomment then we actually don't want to compute the cmode or min_indent
    if p.cmode ~= U.cmode.uncomment then
        for _, line in ipairs(p.lines) do
            -- I wish lua had `continue` statement [sad noises]
            if not U.ignore(line, pattern) then
                if cmode == U.cmode.uncomment and p.cmode == U.cmode.toggle then
                    local is_cmt = U.is_commented(line, lcs_esc, nil, p.cfg.padding)
                    if not is_cmt then
                        cmode = U.cmode.comment
                    end
                end

                -- If the internal cmode changes to comment or the given cmode is not uncomment, then only calculate min_indent
                -- As calculating min_indent only makes sense when we actually want to comment the lines
                if not U.is_empty(line) and (cmode == U.cmode.comment or p.cmode == U.cmode.comment) then
                    local indent = line:match('^(%s*).*')
                    if not min_indent or #min_indent > #indent then
                        min_indent = indent
                    end
                end
            end
        end
    end

    -- If the comment mode given is not toggle than force that mode
    if p.cmode ~= U.cmode.toggle then
        cmode = p.cmode
    end

    local uncomment = cmode == U.cmode.uncomment
    for i, line in ipairs(p.lines) do
        if U.ignore(line, pattern) then
            p.lines[i] = line
        else
            if uncomment then
                p.lines[i] = U.uncomment_str(line, lcs_esc, rcs_esc, p.cfg.padding)
            else
                p.lines[i] = U.comment_str(line, p.lcs, p.rcs, p.cfg.padding, min_indent)
            end
        end
    end
    A.nvim_buf_set_lines(0, p.scol - 1, p.ecol, false, p.lines)

    return cmode
end

---Full/Partial Blockwise commenting
---@param p OpFnParams
---@param partial boolean Whether to do a partial or full comment
---@return integer CMode
function op.blockwise(p, partial)
    -- Block wise, only when there are more than 1 lines
    local sln, eln = p.lines[1], p.lines[2]
    local lcs_esc, rcs_esc = U.escape(p.lcs), U.escape(p.rcs)

    -- These string should be checked for comment/uncomment
    local sln_check = sln
    local eln_check = eln
    if partial then
        sln_check = sln:sub(p.srow + 1)
        eln_check = eln:sub(0, p.erow + 1)
    end

    -- If given mode is toggle then determine whether to comment or not
    local cmode
    if p.cmode == U.cmode.toggle then
        local s_cmt = U.is_commented(sln_check, lcs_esc, nil, p.cfg.padding)
        local e_cmt = U.is_commented(eln_check, nil, rcs_esc, p.cfg.padding)
        cmode = (s_cmt and e_cmt) and U.cmode.uncomment or U.cmode.comment
    else
        cmode = p.cmode
    end

    local l1, l2

    if cmode == U.cmode.uncomment then
        l1 = U.uncomment_str(sln_check, lcs_esc, nil, p.cfg.padding)
        l2 = U.uncomment_str(eln_check, nil, rcs_esc, p.cfg.padding)
    else
        l1 = U.comment_str(sln_check, p.lcs, nil, p.cfg.padding)
        l2 = U.comment_str(eln_check, nil, p.rcs, p.cfg.padding)
    end

    if partial then
        l1 = sln:sub(0, p.srow) .. l1
        l2 = l2 .. eln:sub(p.erow + 2)
    end

    A.nvim_buf_set_lines(0, p.scol - 1, p.scol, false, { l1 })
    A.nvim_buf_set_lines(0, p.ecol - 1, p.ecol, false, { l2 })

    return cmode
end

---Blockwise (left-right/x-axis motion) commenting
---@param p OpFnParams
---@return integer CMode
function op.blockwise_x(p)
    local line = p.lines[1]
    local first = line:sub(0, p.srow)
    local mid = line:sub(p.srow + 1, p.erow + 1)
    local last = line:sub(p.erow + 2)

    local yes, _, stripped = U.is_commented(mid, U.escape(p.lcs), U.escape(p.rcs), p.cfg.padding)

    local cmode
    if p.cmode == U.cmode.toggle then
        cmode = yes and U.cmode.uncomment or U.cmode.comment
    else
        cmode = p.cmode
    end

    if cmode == U.cmode.uncomment then
        A.nvim_set_current_line(first .. (stripped or mid) .. last)
    else
        local pad = p.cfg.padding and ' ' or ''
        local lcs = p.lcs and p.lcs .. pad or ''
        local rcs = p.rcs and pad .. p.rcs or ''
        A.nvim_set_current_line(first .. lcs .. mid .. rcs .. last)
    end

    return cmode
end

return op
