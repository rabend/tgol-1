Voraussetzung:
==============

für den Service, aber auch zum Bauen wird node.js und npm benötigt.

Ich empfehle zum Entwickeln die Verwendung von NVM 

https://github.com/creationix/nvm


Bauen
=====

Nachdem das Repository geclonet ist, einmal `npm install` ausführen. Das zieht alle Abhängigkeiten,
bastelt ein stand-alone client-bundle usw.


Mit `npm start` kann der Webservice direkt aus den Quellen gestartet werden. Danach ist die Anwendung unter http://localhost:9999 erreichbar.
Änderungen am Client-Code (`src/client`) erfordern idR keinen Neustart -- die Browserify-Middleware kriegt das mit, wenn sich etwas ändert.
Es kann allerdings mal vorkommen, dass eine Änderung nicht bemerkt wird. In dem Fall muss der Service neu gestartet werden.


Testen und Debuggen
===================

Mit `npm test` wird die Test-Suite einmalig durchgeführt.
Mit `npm run test-watch` passiert das gleiche, allerdings wird danach die Code-Basis auf Änderungen überwacht und die Tests erneut ausgeführt,
wenn sich etwas ändert. (Neue Dateien werden aber nicht entdeckt.)

`npm test-debug` macht dasselbe wie `npm-test`, startet dabei aber einen Chrome-basierten Debugger. Breakpoints können initial durch Einfügen des Schlüsselworts `debugger`
gesetzt wereden. Das ist insb. im Fall der Unit-Tests relevant, weil hier der Debugger beim Starten noch gar nicht alle Code-Module geladen hat.
Wenn der Debugger die Code-Basis erst einmal vollständig geladen hat, geht das dann auch wie gewohnt durch die UI.

Debuggen kann man den Client-Code natürlich wie gehabt im Browser. Zumindest Chromium hat mit den Sourcemaps wenig Probleme.

Debuggen via USB auf Android-Geräten geht auch, kann aber das Abschalten der Sourcemaps erfordern -- wenn die Code-Bundles zu groß werden, bricht der Debugger die Verbindung ab.

Deployment
==========

Es gibt derzeit noch keinen hübsches executable. Deployment auf dfg-demo funktioniert derzeit in groben Zügen so:

```
npm install {url des tarballs im jenkins}
export TGOL_HOME={Konfigurationsverzeichnis}
nodejs node_modules/tgol/lib/main.js
```

Auf DFG-Demo ist da ein kleiner service-wrapper rum gebschraubt.


Konfiguration
=============

Der Service benötigt ein Konfigurationsverzeichnis `TGOL_HOME`.
Darin gibt es für jedes Turnier ein Unterverzeichnis, sowie eine Datei `settings.yaml`.
Die Einstellungen in der Datei `settings.yaml` in der Code-Basis dienen als Defaults.

Bislang gibt es erst eine Einstellung:

```
port: 9999
```

Zum Aufbau der Turnier-Verzeichnisse (soweit schon bekannt) schaut man sich am besten die Testfälle zum `Repository` an.
Referenz für die verwendeten Datenstrukturen ist immer der Document Builder (`src/builder.coffee`), der auch für alle Tests verwendet werden sollte.
Viel ist da aber noch nicht festgelegt.


Coding "Style" und Konventionen
===============================

Ich bemühe mich soweit es geht, Test-getrieben zu arbeiten. Der Grad der Testabdeckung ist für mich weniger interessant als die Qualität der Testfälle.
Die Tests dienen weniger der Vermeidung von Regressionen als der Dokumentation.
Code der im Wesentlichen aus D3 oder React-Geschwurbsel besteht, habe ich nicht getestet. Ich versuche hier aber möglichst wenig Logik drin zu vergraben.

Insbesondere Klassen wie `pattern`, `board` und `bbox` sind von zentraler Bedeutung. Änderungen hieran sollten *IMMER* Test-getrieben erfolgen.

Die Tests verwenden Mocha und Chai. Alle Tests liegen unterhalb von `spec`. Die Namenskonvention ist: `{Name des getesteten Moduls}-spec.coffee`

Im Fall von asynchronen Funktionen ziehe ich Promises dem nodejs-Callback-Style vor. Ich verwende im ganzen Projekt Bluebird für Promises. Mit
`Promise.promisify` können Funktionen, die das nodjes-Callback-Idiom verwenden automatisch in Funktionen übersetzt werden, die Promises zurückgeben.

Groß geschriebene Funktionsnamen werden verwendet, wenn es sich um Constuctor-Funktionen handelt, also normalerweise ein `new`-Operator davor stehen sollte.
React-Komponenten sind ein Spezialfall, da steht normalerweise kein `new` davor.
Und gelegentlich falle ich in eine (schlechte!) Angewohnheit zurück, Factory-Funktionen groß zu schreiben, insbesondere, wenn sie von einem Modul exportiert werden.
Davon bitte nicht verwirren lassen.

Einrückung bitte mit zwei Leerzeichen ("  ").
Encoding aller source-files ist UTF-8.
Unix-Zeilenenden. :-)




Eingesetzte Technologie
=======================


- Expres.js für den Webservice
- D3.js für die SVG-Visualisierung 
- React.js für das client-seitige routing, templating usw.
- Coffeescript anstelle von Javascript. Gewohnheitssache.



