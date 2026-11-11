-- Also attach to Angular templates for HTML tag and attribute completion.
-- No formatting: prettier formats html, and Angular templates are left alone.
return {
  filetypes = { 'html', 'htmlangular' },
  init_options = { provideFormatter = false },
}
