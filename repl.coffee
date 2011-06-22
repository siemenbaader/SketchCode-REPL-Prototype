CoffeeScript.compile("entry.value", window) #weird 1st time...

Repl = ->
  dom_object_view = (obj) ->
    if [null, undefined, true, false].includes obj
      return Element 'boolean', {}, ['' + obj]
    if typeof obj == 'number'
      return Element 'number', {}, ['' + obj]
    if typeof obj == 'string'
      return Element 'string', {}, ['"' + obj + '"'  ]
    if typeof obj == 'function'
      return Element 'function', {}, ['fn(' + obj.signature() + ")->" ]
    if obj instanceof Array
      return Element 'array', {}, ['[' + obj.toString() + "]" ]
    if obj instanceof Error
      return Element 'error', {}, [ obj.toString() ]
    if obj instanceof Object
      return Element 'object', {}, ['{' + obj.toString() + "}" ]
    
    "obj"
  


  log = Element 'log', {}
  log.history = []
  log.history.pointer = 0
  log.history.current = () -> log.history[log.history.pointer]
  log.history.entry_buffer = '' # save entry during lookup
  log.history.lookup_mode = ->
    return true if @pointer >= 0 and @pointer < @length
    false
    
  log.scroll_down = ->
    log.scrollTop = log.scrollHeight - log.offsetHeight
  
  window.log = log
  entry = Element 'input', {type: 'text', class: 'entry'}
  
  entry.onkeydown = (ev) -> 
  
    if ev.keyIdentifier == 'Enter'
    
      # Leave lookup mode
      if log.history.lookup_mode()
        log.history.current().className = ''
        log.history.pointer = log.history.length 
    
      repl.eval( entry.value )
        
      entry.value = ''
      do log.scroll_down
      return

    # State machine observations:
    # -------------------------------------------------------------------
    #  - can do all the tests for the state up front
    #  - blocks of ifs with redundant actions are easier to cenceptually
    #    understand
    #  - progressive ifs don't need to test all previous conditions
    #  - Up is better split than down, it could be changed but seems ok 
    #    this way.
    # -------------------------------------------------------------------
    
    if ev.keyIdentifier == 'Up'
      
      # Trying to enter lookup with no history
      if not log.history.lookup_mode() and log.history.length == 0
        return
    
      # Entering history lookup, saving old input value
      if not log.history.lookup_mode()
        l 'enter'
        log.history.entry_buffer = entry.value
        log.history.pointer -= 1
        log.history.current().className = 'selected'
        entry.value = log.history.current().statement
        return
      
      # Reached top of history
      if log.history.lookup_mode() and log.history.pointer == 0
        return

      # Moving up one item
      if log.history.lookup_mode()
        log.history.current().className = ''
        log.history.pointer -= 1
        log.history.current().className = 'selected'
        entry.value = log.history.current().statement
        log.scrollTo( log.history.current() )
        return
        
    
    # Down only happens in lookup mode
    if ev.keyIdentifier == 'Down' and log.history.lookup_mode()
        log.history.current().className = ''
        
        log.history.pointer = log.history.pointer + 1
        if log.history.lookup_mode() 
          # if still looking up
          log.history.current().className = 'selected'
          entry.value = log.history.current().statement
          log.scrollTo( log.history.current() )
        else 
          # exit lookup mode restores buffer
          entry.value = log.history.entry_buffer
          log.scroll_down()
        return
      
  repl = Element 'repl', {}, [ log, entry ]

  repl.eval = ( statement ) ->
    "Ealuates statement, logs it and logs the result."
    
    try
      js = CoffeeScript.compile(statement, window)
      result = eval( js )
    catch e
      result = e
    
    statement_element = Element 'statement', {}, [statement]
    statement_element.statement = statement
    logline = Element 'result', {}, [ "=> ", dom_object_view(result) ]
    log.append statement_element
    log.history.push statement_element
    log.history.pointer = log.history.length # 1 bigger means current HEAD
    log.append logline
  
  repl.focus = ->
    do entry.focus
    
  return repl


