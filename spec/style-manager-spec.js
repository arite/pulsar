const temp = require('temp').track();
const StyleManager = require('../src/style-manager');

describe('StyleManager', () => {
  let [styleManager, addEvents, removeEvents, updateEvents] = [];

  beforeEach(() => {
    styleManager = new StyleManager({
      configDirPath: temp.mkdirSync('atom-config')
    });
    addEvents = [];
    removeEvents = [];
    updateEvents = [];
    styleManager.onDidAddStyleElement(event => {
      addEvents.push(event);
    });
    styleManager.onDidRemoveStyleElement(event => {
      removeEvents.push(event);
    });
    styleManager.onDidUpdateStyleElement(event => {
      updateEvents.push(event);
    });
  });

  afterEach(() => {
    try {
      temp.cleanupSync();
    } catch (e) {
      // Do nothing
    }
  });

  describe('::addStyleSheet(source, params)', () => {
    it('adds a style sheet based on the given source and returns a disposable allowing it to be removed', () => {
      const disposable = styleManager.addStyleSheet('a {color: red}');
      expect(addEvents.length).toBe(1);
      expect(addEvents[0].textContent).toBe('a {color: red}');
      const styleElements = styleManager.getStyleElements();
      expect(styleElements.length).toBe(1);
      expect(styleElements[0].textContent).toBe('a {color: red}');
      disposable.dispose();
      expect(removeEvents.length).toBe(1);
      expect(removeEvents[0].textContent).toBe('a {color: red}');
      expect(styleManager.getStyleElements().length).toBe(0);
    });

    describe('atom-text-editor shadow DOM selectors upgrades', () => {
      beforeEach(() => {
        // attach styles element to the DOM to parse CSS rules
        styleManager.onDidAddStyleElement(styleElement => {
          jasmine.attachToDOM(styleElement);
        });
      });

      it('removes the ::shadow pseudo-element from atom-text-editor selectors', () => {
        styleManager.addStyleSheet(`
          atom-text-editor::shadow .class-1, atom-text-editor::shadow .class-2 { color: red }
          atom-text-editor::shadow > .class-3 { color: yellow }
          atom-text-editor .class-4 { color: blue }
          atom-text-editor[data-grammar*="js"]::shadow .class-6 { color: green; }
          atom-text-editor[mini].is-focused::shadow .class-7 { color: green; }
        `);
        expect(
          Array.from(styleManager.getStyleElements()[0].sheet.cssRules).map(
            r => r.selectorText
          )
        ).toEqual([
          'atom-text-editor.editor .class-1, atom-text-editor.editor .class-2',
          'atom-text-editor.editor > .class-3',
          'atom-text-editor .class-4',
          'atom-text-editor[data-grammar*="js"].editor .class-6',
          'atom-text-editor[mini].is-focused.editor .class-7'
        ]);
      });

      describe('when a selector targets the atom-text-editor shadow DOM', () => {
        it('prepends "--syntax" to class selectors matching a grammar scope name and not already starting with "syntax--"', () => {
          styleManager.addStyleSheet(
            `
            .class-1 { color: red }
            .source > .js, .source.coffee { color: green }
            .syntax--source { color: gray }
            #id-1 { color: blue }
          `,
            { context: 'atom-text-editor' }
          );
          expect(
            Array.from(styleManager.getStyleElements()[0].sheet.cssRules).map(
              r => r.selectorText
            )
          ).toEqual([
            '.class-1',
            '.syntax--source > .syntax--js, .syntax--source.syntax--coffee',
            '.syntax--source',
            '#id-1'
          ]);

          styleManager.addStyleSheet(`
            .source > .js, .source.coffee { color: green }
            atom-text-editor::shadow .source > .js { color: yellow }
            atom-text-editor[mini].is-focused::shadow .source > .js { color: gray }
            atom-text-editor .source > .js { color: red }
          `);
          expect(
            Array.from(styleManager.getStyleElements()[1].sheet.cssRules).map(
              r => r.selectorText
            )
          ).toEqual([
            '.source > .js, .source.coffee',
            'atom-text-editor.editor .syntax--source > .syntax--js',
            'atom-text-editor[mini].is-focused.editor .syntax--source > .syntax--js',
            'atom-text-editor .source > .js'
          ]);
        });
      });

      it('replaces ":host" with "atom-text-editor" only when the context of a style sheet is "atom-text-editor"', () => {
        styleManager.addStyleSheet(
          ':host .class-1, :host .class-2 { color: red; }'
        );
        expect(
          Array.from(styleManager.getStyleElements()[0].sheet.cssRules).map(
            r => r.selectorText
          )
        ).toEqual([':host .class-1, :host .class-2']);
        styleManager.addStyleSheet(
          ':host .class-1, :host .class-2 { color: red; }',
          { context: 'atom-text-editor' }
        );
        expect(
          Array.from(styleManager.getStyleElements()[1].sheet.cssRules).map(
            r => r.selectorText
          )
        ).toEqual(['atom-text-editor .class-1, atom-text-editor .class-2']);
      });

      it('does not throw exceptions on rules with no selectors', () => {
        styleManager.addStyleSheet('@media screen {font-size: 10px}', {
          context: 'atom-text-editor'
        });
      });
    });

    describe('css mathematical expression calc() wrap upgrades', () => {
      const mathStyleManager = new StyleManager();
      mathStyleManager.configDirPath = null; // Ensures for testing that we never
      // go looking for cached files, and will always use the css provided

      it('does not upgrade already wrapped math', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { padding: calc(10px/2); }",
          {}
        );
        expect(upgradedSheet.source).toEqual("p { padding: calc(10px/2); }");
      });

      it('does not upgrade negative numbers', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { padding: 0 -1px; }",
          {}
        );
        expect(upgradedSheet.source).toEqual("p { padding: 0 -1px; }");
      });

      it('upgrades simple division', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { padding: 10px/2; }",
          {}
        );
        expect(upgradedSheet.source).toEqual("p { padding: calc(10px/2); }");
      });

      it('upgrades multi parameter math', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { padding: 0 10px/2 5em; }",
          {}
        );
        expect(upgradedSheet.source).toEqual("p { padding: 0 calc(10px/2) 5em; }");
      });

      it('upgrades math with spaces', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { padding: 10px / 2; }",
          {}
        );
        expect(upgradedSheet.source).toEqual("p { padding: calc(10px / 2); }");
      });

      it('upgrades multiple math expressions in a single line', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { padding: 10px/2 10px/3; }",
          {}
        );
        expect(upgradedSheet.source).toEqual("p { padding: calc(10px/2) calc(10px/3); }");
      });

      it('does not upgrade base64 strings', () => {
        // Regression Check
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { cursor: -webkit-image-set(url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAL0lEQVQoz2NgCD3x//9/BhBYBWdhgFVAiVW4JBFKGIa4AqD0//9D3pt4I4tAdAMAHTQ/j5Zom30AAAAASUVORK5CYII=')); }",
          {}
        );
        expect(upgradedSheet.source).toEqual(
          "p { cursor: -webkit-image-set(url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAL0lEQVQoz2NgCD3x//9/BhBYBWdhgFVAiVW4JBFKGIa4AqD0//9D3pt4I4tAdAMAHTQ/j5Zom30AAAAASUVORK5CYII=')); }"
        );
      });

      it('does not modify hsl function where `/` is valid', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { caret-color: hsl(228deg 4% 24% / 0.8); }",
          {}
        );
        expect(upgradedSheet.source).toEqual(
          "p { caret-color: hsl(228deg 4% 24% / 0.8); }"
        );
      });

      it('does not modify acos function, where math is valid', () => {
        let upgradedSheet = mathStyleManager.upgradeDeprecatedMathUsageForStyleSheet(
          "p { transform: rotate(acos(2 * 0.125)); }",
          {}
        );
        expect(upgradedSheet.source).toEqual(
          "p { transform: rotate(acos(2 * 0.125)); }"
        );
      });

    });

    describe('when a sourcePath parameter is specified', () => {
      it('ensures a maximum of one style element for the given source path, updating a previous if it exists', () => {
        styleManager.addStyleSheet('a {color: red}', {
          sourcePath: '/foo/bar'
        });
        expect(addEvents.length).toBe(1);
        expect(addEvents[0].getAttribute('source-path')).toBe('/foo/bar');

        const disposable2 = styleManager.addStyleSheet('a {color: blue}', {
          sourcePath: '/foo/bar'
        });
        expect(addEvents.length).toBe(1);
        expect(updateEvents.length).toBe(1);
        expect(updateEvents[0].getAttribute('source-path')).toBe('/foo/bar');
        expect(updateEvents[0].textContent).toBe('a {color: blue}');
        disposable2.dispose();

        addEvents = [];
        styleManager.addStyleSheet('a {color: yellow}', {
          sourcePath: '/foo/bar'
        });
        expect(addEvents.length).toBe(1);
        expect(addEvents[0].getAttribute('source-path')).toBe('/foo/bar');
        expect(addEvents[0].textContent).toBe('a {color: yellow}');
      });
    });

    describe('when a priority parameter is specified', () => {
      it('inserts the style sheet based on the priority', () => {
        styleManager.addStyleSheet('a {color: red}', { priority: 1 });
        styleManager.addStyleSheet('a {color: blue}', { priority: 0 });
        styleManager.addStyleSheet('a {color: green}', { priority: 2 });
        styleManager.addStyleSheet('a {color: yellow}', { priority: 1 });
        expect(
          styleManager.getStyleElements().map(elt => elt.textContent)
        ).toEqual([
          'a {color: blue}',
          'a {color: red}',
          'a {color: yellow}',
          'a {color: green}'
        ]);
      });
    });
  });
});
