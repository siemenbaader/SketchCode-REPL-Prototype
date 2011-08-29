CoffeeScript.compile("entry.value", window) #weird 1st time...

Repl = ->
  dom_object_view = (obj) ->
    if [null, undefined, true, false].includes obj
      return Element 'boolean', {style: 'color: gray;'}, ['' + obj]
    if typeof obj == 'number'
      return Element 'number',  {style: 'color: green;'}, ['' + obj]
    if typeof obj == 'string'
      return Element 'string', {style: 'color: red;'}, ['"' + obj + '"'  ]
    if typeof obj == 'function'
      return Element 'function', {style: 'color: lightblue;' }, ['fn(' + obj.signature() + ")->" ]
    if obj instanceof Array
      return Element 'array', {style: 'color: blue;'}, ['[' + obj.toString() + "]" ]
    if obj instanceof Error
      return Element 'error', {style: 'color: black; background-color: red; border: white; display: block; padding: 3px;'}, [ obj.toString() ]

    if obj instanceof HTMLElement
      return obj
    if obj instanceof Object
      return Element 'object', {style: 'color: white; font-weight: bold;'}, ['{' + obj.toString() + "}" ]
    
    "obj"
  
  repl = Element 'repl', {style: 'display: block; width: 200px; background-color: black; padding: 3px;'}
  

  log = Element 'log',   {style: 'display: block;
                                 max-height: 100px;
                                 overflow: auto;' }
 
  window.log = log
  # refactor - make History class to fix bug in reset
  log.history = []
  log.history.pointer = 0
  log.history.current = () -> log.history[log.history.pointer]
  log.history.entry_buffer = '' # save entry during lookup
  log.history.lookup_mode = ->
    return true if @pointer >= 0 and @pointer < @length
    false
    
  log.scroll_down = ->
    log.scrollTop = log.scrollHeight - log.offsetHeight
  
  repl.reset = ->
    "Clears the REPL, but replays sticky lines"
    sticky_statements = log.history.filter ( statement_element )->
      statement_element.sticky_checkbox.checked
    log.history = []
    log.history.pointer = 0
    log.history.current = () -> log.history[log.history.pointer]
    log.history.entry_buffer = '' # save entry during lookup
    log.history.lookup_mode = ->
    return true if @pointer >= 0 and @pointer < @length
    false
  
    log.innerHTML = ''
    sticky_statements.forEach (st)->
      repl.eval st.statement  # also keep the statement selected. rework the APIs..!
    

 
  entry = Element 'input', {type: 'text',  style: 'border-left: 5px solid blue; background-color: none;'}
  entry.styles = {
    normal: 'border-left: 5px solid blue; background-color: none;'
    selected : 'border-left: 5px solid blue; background-color: darkgreen;'
  }
  
  entry.set_style = ( preset )->
    @style.cssText = @styles[ preset ]
  entry.set_style 'selected'
  
  entry.onkeydown = (ev) -> 
    if ev.keyIdentifier == 'U+001B' #Escape
      do repl.onescape
      return
  
    if ev.keyIdentifier == 'Enter'
    
      # Leave lookup mode
      if log.history.lookup_mode()
        log.history.current().set_style 'normal'
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
        log.history.entry_buffer = entry.value
        log.history.pointer -= 1
        log.history.current().set_style('selected')
        entry.value = log.history.current().statement
        entry.set_style 'normal'
        return
      
      # Reached top of history
      if log.history.lookup_mode() and log.history.pointer == 0
        return

      # Moving up one item
      if log.history.lookup_mode()
        log.history.current().set_style('normal')
        log.history.pointer -= 1
        log.history.current().set_style('selected')
        entry.value = log.history.current().statement
        log.scrollTo( log.history.current() )
        return
        
    
    # Down only happens in lookup mode
    if ev.keyIdentifier == 'Down' and log.history.lookup_mode()
        log.history.current().set_style 'normal'
        
        log.history.pointer = log.history.pointer + 1
        if log.history.lookup_mode() 
          # if still looking up
          log.history.current().set_style('selected')
          entry.value = log.history.current().statement
          log.scrollTo( log.history.current() )
        else 
          # exit lookup mode restores buffer
          entry.value = log.history.entry_buffer
          entry.set_style 'selected'
          log.scroll_down()
        return
  repl.append log
  repl.append entry
  
  repl.eval = ( statement ) ->
    "Ealuates statement, logs it and logs the result."
    
    try
      js = CoffeeScript.compile(statement, window)
      result = eval( js )
    catch e
      result = e
    
    window.s = sticky_checkbox = new Element 'input', {type: 'checkbox', style: 'float: right', checked: true}
    statement_element = Element 'statement', {}, [statement, sticky_checkbox ]
    statement_element.sticky_checkbox = sticky_checkbox
    statement_element.statement = statement
    statement_element.styles = {
      normal: 'display: block; color: white; padding-left: 3px;',
      selected: 'display: block; color: white; padding-left: 3px; background-color: darkgreen;'
    }
    statement_element.set_style = ( preset ) ->
      @style.cssText = @styles[ preset ]
    statement_element.set_style('normal')
    
    logline = Element 'result', {style: 'display: block; color: white; border-bottom: 1px solid gray;'}, [ "=> ", dom_object_view(result) ]
    
    log.append statement_element
    log.history.push statement_element
    log.history.pointer = log.history.length # 1 bigger means current HEAD
    log.append logline
  
  repl.focus = ->
    do entry.focus

  return repl


