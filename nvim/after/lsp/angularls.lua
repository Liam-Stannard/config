-- lspconfig's shipped defaults resolve `ngserver` and probe locations
-- dynamically; this file exists as a place to override them if a project
-- needs it (e.g. a non-standard node_modules layout). Requires a local
-- @angular/language-service + typescript in node_modules and an angular.json
-- at the project root for root-detection.
return {
  root_markers = { 'angular.json', 'project.json' },
}
