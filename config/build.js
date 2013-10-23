requirejs.config({
  wrap: true,
  insertRequire: ['supermarket'],
  deps: ['supermarket'],
  shim: {
  },
  paths: {
    'supermarket': 'main'
  }
});

