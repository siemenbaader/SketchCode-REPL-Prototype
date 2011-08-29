var Repl;
CoffeeScript.compile("entry.value", window);
Repl = function() {
  var dom_object_view, entry, log, repl;
  dom_object_view = function(obj) {
    if ([null, void 0, true, false].includes(obj)) {
      return Element('boolean', {
        style: 'color: gray;'
      }, ['' + obj]);
    }
    if (typeof obj === 'number') {
      return Element('number', {
        style: 'color: green;'
      }, ['' + obj]);
    }
    if (typeof obj === 'string') {
      return Element('string', {
        style: 'color: red;'
      }, ['"' + obj + '"']);
    }
    if (typeof obj === 'function') {
      return Element('function', {
        style: 'color: lightblue;'
      }, ['fn(' + obj.signature() + ")->"]);
    }
    if (obj instanceof Array) {
      return Element('array', {
        style: 'color: blue;'
      }, ['[' + obj.toString() + "]"]);
    }
    if (obj instanceof Error) {
      return Element('error', {
        style: 'color: black; background-color: red; border: white; display: block; padding: 3px;'
      }, [obj.toString()]);
    }
    if (obj instanceof HTMLElement) {
      return obj;
    }
    if (obj instanceof Object) {
      return Element('object', {
        style: 'color: white; font-weight: bold;'
      }, ['{' + obj.toString() + "}"]);
    }
    return "obj";
  };
  repl = Element('repl', {
    style: 'display: block; width: 200px; background-color: black; padding: 3px;'
  });
  log = Element('log', {
    style: 'display: block;\
                                 max-height: 100px;\
                                 overflow: auto;'
  });
  window.log = log;
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
  repl.reset = function() {
    "Clears the REPL, but replays sticky lines";    var sticky_statements;
    sticky_statements = log.history.filter(function(statement_element) {
      return statement_element.sticky_checkbox.checked;
    });
    log.history = [];
    log.history.pointer = 0;
    log.history.current = function() {
      return log.history[log.history.pointer];
    };
    log.history.entry_buffer = '';
    log.history.lookup_mode = function() {};
    if (this.pointer >= 0 && this.pointer < this.length) {
      return true;
    }
    false;
    log.innerHTML = '';
    return sticky_statements.forEach(function(st) {
      return repl.eval(st.statement);
    });
  };
  entry = Element('input', {
    type: 'text',
    style: 'border-left: 5px solid blue; background-color: none;'
  });
  entry.styles = {
    normal: 'border-left: 5px solid blue; background-color: none;',
    selected: 'border-left: 5px solid blue; background-color: darkgreen;'
  };
  entry.set_style = function(preset) {
    return this.style.cssText = this.styles[preset];
  };
  entry.set_style('selected');
  entry.onkeydown = function(ev) {
    if (ev.keyIdentifier === 'U+001B') {
      repl.onescape();
      return;
    }
    if (ev.keyIdentifier === 'Enter') {
      if (log.history.lookup_mode()) {
        log.history.current().set_style('normal');
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
        log.history.entry_buffer = entry.value;
        log.history.pointer -= 1;
        log.history.current().set_style('selected');
        entry.value = log.history.current().statement;
        entry.set_style('normal');
        return;
      }
      if (log.history.lookup_mode() && log.history.pointer === 0) {
        return;
      }
      if (log.history.lookup_mode()) {
        log.history.current().set_style('normal');
        log.history.pointer -= 1;
        log.history.current().set_style('selected');
        entry.value = log.history.current().statement;
        log.scrollTo(log.history.current());
        return;
      }
    }
    if (ev.keyIdentifier === 'Down' && log.history.lookup_mode()) {
      log.history.current().set_style('normal');
      log.history.pointer = log.history.pointer + 1;
      if (log.history.lookup_mode()) {
        log.history.current().set_style('selected');
        entry.value = log.history.current().statement;
        log.scrollTo(log.history.current());
      } else {
        entry.value = log.history.entry_buffer;
        entry.set_style('selected');
        log.scroll_down();
      }
    }
  };
  repl.append(log);
  repl.append(entry);
  repl.eval = function(statement) {
    "Ealuates statement, logs it and logs the result.";    var js, logline, result, statement_element, sticky_checkbox;
    try {
      js = CoffeeScript.compile(statement, window);
      result = eval(js);
    } catch (e) {
      result = e;
    }
    window.s = sticky_checkbox = new Element('input', {
      type: 'checkbox',
      style: 'float: right',
      checked: true
    });
    statement_element = Element('statement', {}, [statement, sticky_checkbox]);
    statement_element.sticky_checkbox = sticky_checkbox;
    statement_element.statement = statement;
    statement_element.styles = {
      normal: 'display: block; color: white; padding-left: 3px;',
      selected: 'display: block; color: white; padding-left: 3px; background-color: darkgreen;'
    };
    statement_element.set_style = function(preset) {
      return this.style.cssText = this.styles[preset];
    };
    statement_element.set_style('normal');
    logline = Element('result', {
      style: 'display: block; color: white; border-bottom: 1px solid gray;'
    }, ["=> ", dom_object_view(result)]);
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