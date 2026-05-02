(function () {
  function showStartupError(message) {
    document.body.innerHTML =
      '<pre style="color: red; padding: 20px; font-family: monospace; white-space: pre-wrap;">' +
      message +
      '</pre>';
  }

  function startFlutter() {
    if (typeof _flutter === 'undefined' || !_flutter.loader) {
      showStartupError('Flutter runtime is not available. The web bootstrap could not start.');
      return;
    }

    // Use the recommended loader API. Decide whether to pass a renderer
    // configuration depending on whether the page already set
    // `window.flutterWebRenderer` in index.html. Passing both causes an
    // assertion in the engine.
    _flutter.loader.load({
      onEntrypointLoaded: async function (engineInitializer) {
        try {
          let appRunner;
          if (typeof window.flutterWebRenderer === 'undefined') {
            appRunner = await engineInitializer.initializeEngine({ renderer: 'html' });
          } else {
            appRunner = await engineInitializer.initializeEngine();
          }
          await appRunner.runApp();
        } catch (error) {
          showStartupError('Flutter app initialization failed: ' + error.toString());
        }
      },
      onEntrypointNotLoaded: (error) => {
        showStartupError('Entrypoint failed to load: ' + (error && error.toString ? error.toString() : error));
      },
    });
  }

  window.addEventListener('load', function () {
    if (typeof _flutter !== 'undefined' && _flutter.loader) {
      startFlutter();
      return;
    }

    const script = document.createElement('script');
    script.src = 'flutter.js';
    script.defer = true;
    script.onload = startFlutter;
    script.onerror = function () {
      showStartupError('Failed to load flutter.js.');
    };
    document.head.appendChild(script);
  });
})();
