Vorschlag zur Arbeitsteilung
============================

tl;dr: Roman macht einen Bogen um die exotischeren Ecken, und hält sich
zunächst an die eher kanonischen Teile.

Ich habe versucht, Arbeitspakete hier so zu sortieren, dass wir mit den
grundlegenden, kanonischen Dingen beginnen (Persistieren der Muster/Matches
durch den Turnierservice u.ä.) Als nächstes könnte man Dinge in Angriff nehmen,
die zwar Berührungen mit den Client-seitigen Frameworks (insb. react.js) haben,
das aber in mehr oder weniger kanonischer Weise -- Sprich: Die Probleme, in die
Roman laufen *wird*, lassen sich noch relativ gut mHv Googel et al
recherchieren.  (Leader-Board, Algorithmus zur Bestimmung des nächsten Matches,
ggFs Upload-Maske)

Bis zum Schluss aufheben sollten wir uns Schmankerl wie die Integration des
Crypto-Moduls zum Signieren der Nachrichten oder ggFs Detailarbeiten an der
Visualisierung. Dazu würde ich vor allem deshalb raten, weil sich hier Konzepte
vermischen. 

Das alles sind Vorschläge. Wenn Roman mit etwas anderem anfangen möchte, ist mir das auch recht.


Service und Persistenz
----------------------


UC2: Der Client lädt ein Muster hoch, dass an einem Turnier teilnehmen soll.
Das ist ein JSON-Dokument mit
- dem normalisierten Code des Musters (ein base64-String)
- dem Namen des Musters
- dem Namen des Autors
- einer  Signatur (die der Service erst einmal ignorieren kann)

Pro turnier sollen nicht zwei ähnliche Muster (also zwei Muster mit dem selben normalisierten Code)
teilnehmen können. Der Service muss das also prüfen, bevor er den kram persistiert.

Wenn später noch Zeit ist, sollten wir so sinnvolle Dinge wie
optimistic Locking einbauen...

Umsetzung: 

- server-spec.coffee enthält die Integrationstests für den Service. (Bisher nur einer :-) ) 
  Hier am besten anfangen und einen Testfall für den Muster-Upload ergänzen.
  Vermutlich muss der Test Data Builder (builder.coffee) angepasst werden, der geht z.B. derzeit noch 
  davon aus, dass in dem Match ein PIN gespeichert wird. Oder man lässt es erstmal so, spielt zunächst keine große rolle.

- Testfall für Repository ergänzen und Repository anpassen.

- service.coffee um die entsprechende Route ergänzen. 

UC 2.1: Der CLient fragt Meta-Informationen zu einem Muster an
  Der Client schickt ein GET an (z.B.) /api/{turnier-name}/patterns/{base64-String}
  Der Server antwortet mit 404, falls das Muster noch nicht hochgeladen wurde, oder mit
  exakt dem Dokument, das in UC2 hochgeladen wurde.

  Hintergrund: Der Client benutzt diese Anfragen um z.B. vor einem Upload zu prüfen, ob das Muster schon
  bekannt ist (i.e. von einem anderen Teilnehmer hochgeladen wurde).
  Hier kommt dann später auch die Sache mit dem optimistic locking zum tragen.

  Umsetzung analog zu UC 2

UC3: Der Client (nicht irgend einer, sondern ein "Spielleiter") lädt ein Match-Ergebnis hoch.

Das ist strukturell ganz analog zu oben, nur eben mit Matches statt Patterns.
Das Match-Dokument sollte enthalten
- Referenzen auf die Teilnehmenden Muster. Dazu kann man eigentlich einfach
  deren base64-Strings nehmen.
- Zu beiden Mustern jeweils
  - Translation (x/y versatz)
  - Rotation/Spiegelung: ein Muster gehört immer zu einer Klasse von 8
    ähnlichen Mustern die zueinander identisch modulo Rotation/Spieglung sind.
    Also im Wesentlichen eine Zahl von 0 bis 7
  - Den Punktestand nach dem Match. Keine Ahnung. Sagen wir: zwei Integer?
- Eine Signatur (auch hier: erst mal ignorieren)


UC4: Pattern/Matches ausgeben

Diese Requests benötigt vor allem das Kiosk-System zum erstellen des Leader-Boards,
sowie um auszutüfteln, wer als nächstes gegeneinander antreten soll.

Der Client schickt ein GET nach /api/{turniername}
Der Server antwortet mit einem JSON-Dokument
Dessen Aufbau könnte in etwa folgendermaßen sein:

patterns:[...]
matches:[...]

Die Elemente von patterns  könnten tatsächlich einfach die dokumente aus UC2 sein, da für das Leader-Board 
ohnehin all diese Infos benötigt werden.
Die Matches sollten andererseits aus Platzgründen die Muster nicht über den base64-Code referenzieren, sondern
über deren position in dem patterns-Array. (spezifisch für diese eine Response)

UC4 Leader Board
Das ist quasi das Client-seitige Gegenstück zu UC4.

Zu beachten wäre hier, dass, auch wenn die Berechnungen im Client stattfinden,
wir sie ordentlich in ein eigenes Modul kapseln und getrennt von der React-UI
testen können. Dieses Modul soll weder wissen, woher die Daten kommen, noch wie
sie angezeigt werden. Es soll aber als Ergebnis eine Datenstruktur liefern, die
quasi isomorph zum Aufbau der UI ist.

Die eigentliche Visualisierung ist dann fast trivial.

Hierzu noch ein Detail: Ich wollte dieses JSX-Zeugs nicht, und hab darum die
render-Methoden in den React-Componenten zu Fuß mit einer simplen
Coffeescript-DSL erledigt.  Die Inspiration dazu stammt von hier
http://blog.vjeux.com/2013/javascript/react-coffeescript.html, einige Details musste
ich an die aktuelle React-Version anpassen. Leider führt
dieses Vorgehen an ein oder zwei Stellen zu Brüchen: An den meisten Stellen
werden als Kind-Elemente nicht die Componenten-Constructor-Methoden erwartet,
sondern Factories (React.createFactory MyComponent) Blöderweise verhält es sich
bei den `component:`-Properties von Routes anders: hier *muss* es der
Constructor sein, sonst erhält man völlig abstruse Fehlermeldungen. Der
JSX-Transpiler kann diese Kanten glätten, unsere bescheidene DSL
leider nicht. Wenn man mal eingesehen hat, wie das ganze mit dem virtuellen
DOM funktioniert, ist das auch völlig logisch, aber für Anfänger ist es eine
gemeine Stolperfalle, für die ich mich schon mal in aller Form entschuldigen möchte. :-)

Wenn die Verwirrung vollständig ist, empfehle ich einen Besuch hier:
https://babeljs.io/repl/
Hier kann man sich anschauen, was der JSX-Transpiler genau macht-- eigentlich ist es ziemlich simpel.
Wenn man das mit der Funktionsweise der DSL (vgl. src/react-utils.coffee) vergleicht, wird auch klar,
wo der Hase im Pfeffer liegt.


UC4.1 Bestimmen, welches Match als nächstes dran ist.
Auch hier bitte die Logik von der UI separieren und testen.



Die Restlichen Arbeiten würde ich erstmal zurückstellen.
