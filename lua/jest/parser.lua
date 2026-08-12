local M = {}

--- Flatten a decoded `jest --json` payload into a flat list of result rows.
--- @param decoded table decoded jest --json output
--- @return table[] rows { file, fullName, title, status, failureMessages, line, column }
function M.flatten(decoded)
  local rows = {}
  for _, file_result in ipairs(decoded.testResults or {}) do
    if file_result.assertionResults and #file_result.assertionResults > 0 then
      for _, a in ipairs(file_result.assertionResults) do
        table.insert(rows, {
          file = file_result.name,
          fullName = a.fullName,
          title = a.title,
          ancestorTitles = a.ancestorTitles,
          status = a.status,
          failureMessages = a.failureMessages,
          line = a.location and a.location.line or nil,
          column = a.location and a.location.column or nil,
        })
      end
    else
      -- file-level failure (e.g. syntax/import error) with no assertions to report
      table.insert(rows, {
        file = file_result.name,
        fullName = file_result.name,
        title = file_result.name,
        status = 'failed',
        failureMessages = { file_result.message or 'Unknown error' },
        line = nil,
        column = nil,
      })
    end
  end
  return rows
end

return M
