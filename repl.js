var Repl;
CoffeeScript.compile("entry.value", window);
Repl = function() {
  var dom_object_view, entry, log, repl;
  dom_object_view = function(obj) {
    if ([null, void 0, true, false].includes(obj)) {
      return Element('boolean', {}, ['' + obj]);
    }
    if (typeof obj === 'number') {
      return Element('number', {}, ['' + obj]);
    }
    if (typeof obj === 'string') {
      return Element('string', {}, ['"' + obj + '"']);
    }
    if (typeof obj === 'function') {
      return Element('function', {}, ['fn(' + obj.signature() + ")->"]);
    }
    if (obj instanceof Array) {
      return Element('array', {}, ['[' + obj.toString() + "]"]);
    }
    if (obj instanceof Error) {
      return Element('error', {}, [obj.toString()]);
    }
    if (obj instanceof Object) {
      return Element('object', {}, ['{' + obj.toString() + "}"]);
    }
    return "obj";
  };
  log = Element('log', {});
  log.history = [];
  log.history.pointer = 0;
  log.history.current = function() {
    return log.history[log.history.pointer];
  };
  log.history.entry_buffer = '';
  log.history.lookup_mode = function() {
    if (this.pointer >= 0 && this.pointer < this.length) {
      return true;
    }
    return false;
  };
  log.scroll_down = function() {
    return log.scrollTop = log.scrollHeight - log.offsetHeight;
  };
  window.log = log;
  entry = Element('input', {
    type: 'text',
    "class": 'entry'
  });
  entry.onkeydown = function(ev) {
    if (ev.keyIdentifier === 'Enter') {
      if (log.history.lookup_mode()) {
        log.history.current().className = '';
        log.history.pointer = log.history.length;
      }
      repl.eval(entry.value);
      entry.value = '';
      log.scroll_down();
      return;
    }
    if (ev.keyIdentifier === 'Up') {
      if (!log.history.lookup_mode() && log.history.length === 0) {
        return;
      }
      if (!log.history.lookup_mode()) {
        l('enter');
        log.history.entry_buffer = entry.value;
        log.history.pointer -= 1;
        log.history.current().className = 'selected';
        entry.value = log.history.current().statement;
        return;
      }
      if (log.history.lookup_mode() && log.history.pointer === 0) {
        return;
      }
      if (log.history.lookup_mode()) {
        log.history.current().className = '';
        log.history.pointer -= 1;
        log.history.current().className = 'selected';
        entry.value = log.history.current().statement;
        log.scrollTo(log.history.current());
        return;
      }
    }
    if (ev.keyIdentifier === 'Down' && log.history.lookup_mode()) {
      log.history.current().className = '';
      log.history.pointer = log.history.pointer + 1;
      if (log.history.lookup_mode()) {
        log.history.current().className = 'selected';
        entry.value = log.history.current().statement;
        log.scrollTo(log.history.current());
      } else {
        entry.value = log.history.entry_buffer;
        log.scroll_down();
      }
    }
  };
  repl = Element('repl', {}, [log, entry]);
  repl.eval = function(statement) {
    "Ealuates statement, logs it and logs the result.";    var js, logline, result, statement_element;
    try {
      js = CoffeeScript.compile(statement, window);
      result = eval(js);
    } catch (e) {
      result = e;
    }
    statement_element = Element('statement', {}, [statement]);
    statement_element.statement = statement;
    logline = Element('result', {}, ["=> ", dom_object_view(result)]);
    log.append(statement_element);
    log.history.push(statement_element);
    log.history.pointer = log.history.length;
    return log.append(logline);
  };
  repl.focus = function() {
    return entry.focus();
  };
  return repl;
};