-- TODO
-- [-] Handle Tabs
-- [x] Dot repeat
-- [x] Comment multiple line.
-- [x] Hook support
--      [x] pre
--      [x] post
-- [x] Custom (language) commentstring support
-- [x] Block comment basic ie. /* */ (for js)
-- [-] Block comment extended
--      [x] left-right-motions
--      [x] Partial blocks ie. gba{ gbaf
--      [ ] V-BLOCK (IDK, maybe)
--      [ ] Char motion covering mutliple lines ie. gc300w (level: HARD)
-- [ ] Doc comment ie. /** */ (for js)
-- [ ] Treesitter Integration
--      [ ] Better comment detection
--      [ ] Context commentstring
-- [ ] Insert mode mapping (also move the cursor after commentstring)
-- [-] Port `commentstring` from tcomment
-- [ ] Header comment
-- [x] Ignore line
-- [x] Disable `extra` mapping by default
-- [x] Provide more arguments to pre and post hooks
-- [x] `ignore` as a function
-- [ ] Parse `set comments` if block comment is missing in the plugin
-- [ ] Use `nvim_buf_get_text` instead of `nvim_buf_get_lines`. Blocked by https://github.com/neovim/neovim/pull/15181
-- [ ] Use `nvim_buf_set_text` instead of `nvim_buf_set_lines`

-- FIXME
-- [x] visual mode not working correctly
-- [x] space after and before of commentstring
-- [x] multiple line behavior to tcomment
--      [x] preserve indent
--      [x] determine comment status (to comment or not)
-- [x] prevent uncomment on uncommented line
-- [x] `comment` and `toggle` misbehaving when there is leading space
-- [x] messed up indentation, if the first line has greater indentation than next line (calc min indendation)
-- [x] `gcc` empty line not toggling comment
-- [x] Optimize blockwise mode (just modifiy the start and end line)
-- [x] Weird commenting when the first line is empty and the whole is indented
-- [x] no padding support in block-x
-- [ ] Dot repeat support for visual mode mappings
-- [ ] Weird comments, if you do comments on already commented lines incl. an extra empty line

-- THINK:
-- 1. Should i return the operator's starting and ending position in pre-hook
-- 2. Restore initial cursor position in some motion operator (try `gcip`)
-- 3. It is possible that, commentstring is updated inside pre-hook as we want to use it but we can't
--    bcz the filetype is also present in the lang-table (and it has high priority than bo.commentstring)
-- 4. When there is an uncommented empty line b/w two commented blocks. It should uncomment instead of commenting again in toggle.
-- 5. Conflict when uncommenting interchangebly with line/block wise comment
-- 6. `ignore` is missing in blockwise and blockwise_x but on the other hand this doesn't make much sense
