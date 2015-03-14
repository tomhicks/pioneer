module.exports = (cucumber, options, callback) ->
  cucumber.Cli(options).run (success) ->
    callback(if success then 0 else 1)
