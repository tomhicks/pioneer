moment          = require('moment')
fs              = require('fs')
path            = require('path')
minimist        = require('minimist')
scaffoldBuilder = require('./scaffold_builder')
color           = require('colors')
cucumber        = require('cucumber')

class Pioneer
  constructor: (libPath, {@testRunner, @configBuilder}) ->
    args = minimist(process.argv.slice(2))
    process.argv = []

    if this.isVersionRequested(args)
      console.log require('../package').version
      return
    if(args.configPath && fs.existsSync(args.configPath))
      configPath = args.configPath
    else if args.scaffold
      scaffoldBuilder.createScaffold()
    else
      p = path.join(process.cwd(), '/pioneer.json')
      if(fs.existsSync(p))
        configPath = p
      else
        configPath = null

    this.getSpecifications(configPath, libPath, args)

  getSpecifications: (path, libPath, args) ->
    configObject = {}
    if(path)
      fs.readFile(path,
        'utf8',
        (err, data) =>
          throw err if(err)
          configObject = this.parseAndValidateJSON(data, path)

          if @isVerbose(args, configObject)
            console.log ('Configuration loaded from ' + path).yellow.inverse

          this.applySpecifications(configObject, libPath, args)
      )
    else
      if @isVerbose(args, configObject)
        console.log ('No configuration path specified').yellow.inverse

      this.applySpecifications(configObject, libPath, args)

  applySpecifications: (obj, libPath, args) ->
    runnerOptions = @configBuilder.generateOptions(args, obj, libPath)
    require('./environment')()
    @testRunner(cucumber, runnerOptions, process.exit) if runnerOptions

  parseAndValidateJSON: (config, path) ->
    try
      JSON.parse(config)
    catch err
      throw new Error(path + " does not include a valid JSON object.\n")

  isVersionRequested: (args) ->
    args.version || args.v

  isVerbose: (args, config = {}) ->
    if args.verbose?
      return args.verbose and args.verbose isnt "false"
    else
      return !!config.verbose

module.exports = Pioneer
