{exec}   = require 'child_process'
fs       = require 'fs'
chokidar = require 'chokidar'
execSync = require 'exec-sync'
  
task 'compile', 'Compile coffescript ', ->
  compile()
    
task 'build', 'Compile', ->
  invoke 'clean'
  invoke 'compile'

task 'clean', 'Limpar', ->
  execOut('rm -rf build/*')
  execOut('rm -rf test/lib/*')
  execOut('rm -rf test/build/*')

task 'listen', 'Compila automaticamente a cada modificação', ->
  invoke 'clean'
  compile(true)  

task 'translate', 'Traduz', ->
  translate()
 
task "test", "run tests", ->
  exec "NODE_ENV=test
    ./node_modules/.bin/mocha
    --compilers coffee:coffee-script/register
    --require coffee-script
    --require test/test_helper.coffee
    --reporter spec
    --colors
  ", (err, output) ->
    throw err if err
    console.log output

translate = () ->
  names = []
  eachFile 'src', (filename) ->
    contents = fs.readFileSync(filename, {encoding:'utf8'})
    results = String(contents).match /i18n\.t[( ]+['"]([.A-Za-z0-9_-]+)['"]/g
    if results
      for result in results
        result = String(result).match /i18n\.t[( ]+['"]([.A-Za-z0-9_-]+)['"]/
        if names.indexOf(result[1]) == -1
          names.push result[1]

  http = require 'http'

  targets = ['en', 'es', 'pt-BR']

  @cacheLang = {}

  setLangContent = (lang, contents) =>
    @cacheLang[lang] = contents

  getLangContent = (lang) =>
    if !@cacheLang[lang]
      langpath = "src/app/locales/#{lang}"
      langfile = "#{langpath}/translation.json"
      fs.mkdirSync(langpath) if not fs.existsSync(langpath)
      if fs.existsSync(langfile)
        contents = fs.readFileSync(langfile).toString('utf8')
      else
        contents = '{}'
      @cacheLang[lang] = contents
    return @cacheLang[lang]

  saveCacheLang = (lang) =>
    langpath = "src/app/locales/#{lang}"
    langfile = "#{langpath}/translation.json"
    contents = @cacheLang[lang]
    fs.writeFileSync(langfile, contents, {'encoding':'utf8'})

  saveTranslate = (target, key, value) ->
    beautify = require('js-beautify').js_beautify
    contents = getLangContent target
    obj = JSON.parse(contents || '{}')
    key_pieces = key.split('.')
    last = obj
    last_last = null
    for k in key_pieces
      if !last[k]
        last[k] = {}
      last_last = last
      last = last[k]
    last_last[k] = value.charAt(0).toUpperCase() + value.slice(1);
    contents = beautify(JSON.stringify(obj), {indent_size: 2})

    setLangContent target, contents

  needTranslate = (target, key) ->
    contents = getLangContent target
    obj = JSON.parse(contents || '{}')
    key_pieces = key.split('.')
    last = obj
    for k in key_pieces
      if !last[k]
        return true
      last = last[k]
    return false

  tout_id = null
  tout_callback = () ->
    for target in targets
      saveCacheLang target
  
  for target in targets
    for name in names
      do (name, target) ->
        if needTranslate(target, name)
          english = name.split('.').pop().replace(/_/g, '+')
          result  = english

          if target != 'en'
            options = {
              host: "translate.google.com",
              port: 80,
              path: "/translate_a/single?client=t&sl=en&tl=#{target.split('-').shift()}&hl=pt-BR&dt=bd&dt=ex&dt=ld&dt=md&dt=qc&dt=rw&dt=rm&dt=ss&dt=t&dt=at&dt=sw&ie=UTF-8&oe=UTF-8&prev=btn&srcrom=1&ssel=0&tsel=0&q=#{english}"
              encoding: 'utf8'
            }

            http.get options, (resp) ->
              buffer = null
              resp.on 'data', (chunk) ->
                if buffer
                  buffer = buffer + chunk
                else
                  buffer = chunk
              resp.on 'end', ->
                result = buffer.toString('utf8').match(/\[\[\["(.+?)"/)[1]
                saveTranslate target, name, result
                clearTimeout tout_id
                tout_id = setTimeout tout_callback, 1000
            .on "error", (e) ->
              console.log "Got error: " + e.message
          else
            saveTranslate target, name, result.replace(/\+/g, ' ')
            clearTimeout tout_id
            tout_id = setTimeout tout_callback, 1000


eachFile = (path, callback) ->
  for filename in fs.readdirSync path
    filename = "#{path}/#{filename}"
    stat = fs.statSync(filename)
    if  stat.isDirectory()
      eachFile(filename, callback)
    else
      callback(filename)

compile = (autobuild) ->
  autobuild = autobuild || false

  doParseDir = (filename, from, to, oldState) ->
    if typeof(to) == 'string'
      to = [to]
    if from.indexOf('.subl') >= 0
      return false
    for t in to
      fs.mkdirSync(t) if not fs.existsSync(t)
    copyPath from, to

  doParseFile = (filename, from, to_array, oldState) ->
    if from.indexOf('.subl') >= 0
      return false

    if typeof(to_array) == 'string'
      to_array = [to_array]

    exist = true
    for t in to_array
      if not fs.existsSync(t)
        exist = false

    newState = fs.statSync(to_array[0]) if fs.existsSync(to_array[0])

    if not exist or parseInt(newState.mtime.getTime()) <= parseInt(oldState.mtime.getTime())
      contents = fs.readFileSync(from)
      needSave = true

      if /.*\.coffee$/.test(from)
        stdout = execOut "coffee -c -p #{from}"
        for t in to_array
          t = t.replace /\.coffee$/, '.js'
          fs.writeFileSync(t, stdout)  
          fs.utimesSync(t, oldState.atime, oldState.mtime)
        needSave = false
      else if /.*\.scss$/.test(from)
        for t in to_array
          t = t.replace /\.scss$/, '.css'
          execOut "sass --update #{from}:#{t}"
          fs.utimesSync(t, oldState.atime, oldState.mtime)
        needSave = false
      else if /.*\.coff?ee?/.test(from)
        throw new Error("Extensão inválida: #{from}")
      else if /.*\.sass?/.test(from)
        throw new Error("Extensão inválida: #{from}")

      if needSave
        for t in to_array
          fs.writeFileSync(t, contents)
          fs.utimesSync(t, oldState.atime, oldState.mtime)

  doParseItem = (filename, src, dest) ->
    do (filename) ->
      from = "#{src}/#{filename}"
      if typeof(dest) != 'object'
        dest = [dest]
      to = []
      for d in dest
        to.push "#{d}/#{filename}"
      oldState = fs.statSync(from)
      if oldState.isDirectory()
        doParseDir filename, from, to, oldState
      else
        doParseFile filename, from, to, oldState

  copyPath = (src, dest) ->
    if typeof(dest) == 'string'
      dest = [dest]
    for filename in fs.readdirSync src
      doParseItem(filename, src, dest)

  fs.mkdirSync('build') if not fs.existsSync('build')
  fs.mkdirSync('test/build') if not fs.existsSync('test/build')

  copyPath 'src', ['build', 'test/build']
  # Agora vamos para os testes unitários
  copyPath 'test/src', 'test/lib'

  if autobuild
    watcher = chokidar.watch 'src',
      persistent: true
      ignoreInitial: true

    watcher
      .on 'add', (path) ->
        if path.indexOf('.subl') >= 0
          return false
        console.log 'File', path, 'has been added'
        from = path
        for t in ['build', 'test/build']
          to = path.replace /^src/, t
          oldState = fs.statSync(from)
          doParseFile path, from, to, oldState
      .on 'addDir', (path) -> 
        if path.indexOf('.subl') >= 0
          return false
        console.log 'Directory', path, 'has been added'
        from     = path
        for t in ['build', 'test/build']
          to       = path.replace /^src/, t
          oldState = fs.statSync(from)
          if oldState.isDirectory()
            doParseDir path, from, to, oldState
          else
            doParseFile path, from, to, oldState
      .on 'change', (path) -> 
        if path.indexOf('.subl') >= 0
          return false
        console.log 'File', path, 'has been changed'
        from     = path
        for t in ['build', 'test/build']
          to       = path.replace /^src/, t
          oldState = fs.statSync(from)
          doParseFile path, from, to, oldState
      .on 'unlink', (path) ->
        if path.indexOf('.subl') >= 0
          return false
        console.log 'File', path, 'has been removed'
        from     = path
        for t in ['build', 'test/build']
          to       = path.replace /^src/, t
          execOut("rm #{to}")
      .on 'unlinkDir', (path) ->
        if path.indexOf('.subl') >= 0
          return false
        console.log 'Directory', path, 'has been removed'
      .on 'error', (error) -> 
        console.error 'Error happened', error

  if autobuild
    watcher = chokidar.watch 'test/src',
      persistent: true
      ignoreInitial: true

    watcher
      .on 'add', (path) ->
        if path.indexOf('.subl') >= 0
          return false
        console.log 'File', path, 'has been added'
        from     = path
        to       = path.replace /test\/src/, 'test/lib'
        oldState = fs.statSync(from)
        doParseFile path, from, to, oldState
      .on 'addDir', (path) -> 
        if path.indexOf('.subl') >= 0
          return false
        console.log 'Directory', path, 'has been added'
        from     = path
        to       = path.replace /test\/src/, 'test/lib'
        oldState = fs.statSync(from)
        if oldState.isDirectory()
          doParseDir path, from, to, oldState
        else
          doParseFile path, from, to, oldState
      .on 'change', (path) -> 
        if path.indexOf('.subl') >= 0
          return false
        console.log 'File', path, 'has been changed'
        from     = path
        to       = path.replace /test\/src/, 'test/lib'
        oldState = fs.statSync(from)
        doParseFile path, from, to, oldState
      .on 'unlink', (path) ->
        if path.indexOf('.subl') >= 0
          return false
        console.log 'File', path, 'has been removed'
        from     = path
        to       = path.replace /test\/src/, 'test/lib'
        execOut("rm #{to}")
      .on 'unlinkDir', (path) ->
        if path.indexOf('.subl') >= 0
          return false
        console.log 'Directory', path, 'has been removed'
      .on 'error', (error) -> 
        console.error 'Error happened', error
    
  '''
  execOut('cp -r src/vendor build/vendor')
  execOut('cp -r src/manifest.webapp build/manifest.webapp')
  execOut('mkdir -p build/assets')
  execOut('cp -r src/assets/image src/assets/image')
  execOut('cp -r src/assets/icon src/assets/icon')
  execOut('sass --update src/assets/style/:build/assets/style/')
  # @todo index.slim
  execOut('coffee --compile --output src/javascripts/ src/coffeescripts/')
  execOut('sass --update src/sass/:src/stylesheets/')
  '''

execOut = (commandLine) ->
  console.log("> #{commandLine}")
  stdout = execSync(commandLine)
  return stdout