-- Schemas from SchemaStore give completion and validation in package.json,
-- tsconfig.json, angular.json, .eslintrc and so on. Formatting stays with
-- prettier (conform).
return {
  init_options = { provideFormatter = false },
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
}
