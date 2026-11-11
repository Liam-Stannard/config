-- ys{motion}{char} adds, ds{char} deletes, cs{old}{new} changes; S in visual.
-- t is a tag target, e.g. cst changes the surrounding HTML tag.
return {
  'kylechui/nvim-surround',
  version = '*',
  event = 'VeryLazy',
  opts = {},
}
