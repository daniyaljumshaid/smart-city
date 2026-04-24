window.addEventListener('load', function () {
  _flutter.loader.loadEntrypoint({
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine({
        renderer: 'html',
      });
      await appRunner.runApp();
    },
  });
});
