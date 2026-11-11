-- Schemas from SchemaStore (GitLab CI, GitHub workflows, docker-compose, ...)
-- replace yamlls' own schema store download. No formatting, as before.
return {
  settings = {
    yaml = {
      schemaStore = { enable = false, url = '' },
      schemas = require('schemastore').yaml.schemas(),
      format = { enable = false },
    },
  },
}
