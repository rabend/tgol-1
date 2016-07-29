
Offene Punkte Tournierservice
=============================

URI-Pfad sollte immer mit `/api/` beginnen.
Auf den Anderen URIs macht sich die Router-Komponente in der Client SPA breit.


0. UC Neues Turnier erzeugen
----------------------------

Service:

Im Dateisystem ein Verzeichnis für das Turnier anlegen.
Darin eine Datei `meta.yaml`. 
Hier muss ein RSA-Schlüsselpaar erzeugt werden. Der Public Key wird
in der `meta.yaml` hinterlegt.

Es existiert ein rudimentäres Skelet:
- builder.coffee: erzeugt die entsprechenden Datenstrukturen. Unfertig.
- repository.coffee: liest und schreibt von/zu Tournierverzeichnis.

Der derzeitige Service kann die existierenden Tourniere auflisten. Viel mehr noch nicht.
Siehe Testfälle.


2. UC Population zu Turnier anmelden
------------------------------------

todo

4. UC Abfrage Muster und bereits gespielte Matches
--------------------------------------------------

todo

3. UC Ergebnis für Match hochladen
----------------------------------

todo




Teilnehmer-Schnittstelle (Mobile-taugliche SPA)
===============================================

1. UC Population erstellen/ Testen ("Design-Ansicht")
-----------------------------------------------------

weitestgehend fertig. Es fehlen für einige Kommandos noch die nötigen "Knöpfe", dass
ist aber schnell gemacht. Stand ist einsehbar unter <end-point>/editor

Der Editor ist immer in einem von drei Zuständen: edit, select, pattern.
*edit* ist der Startzustand, der es erlaubt, Zellen an und auszuknipsen.
Wenn ich unten auf den "auswahl"-Knopf drücke, komme ich in den 
*select*-Modus. Hier kann ich einen Rechteckigen Bereich im editor auswählen.
Wenn ich auf den ausgewählten Bereich tippe, oder im Unteren Panel den Copy-Knopf drücke,
komme ich in den *pattern*-Modus. (Hier ist noch ein bug, ich glaube im Moment werden die markierten
Zellen immer ausgeschnitten.)
Im *pattern* Modus kann ich das zuvor kopierte/ausgeschnittene Muster verschieben. wenn ich auf das Muster tippe,
wird es an der Stelle, an der es sich gerade befindet, in den Editor eingefügt.
Hier fehlen noch Knöpfe zum drehen und spiegeln -- die entsprechenden Transformationen sind implementiert.

Was ich eigentlich noch einbauen wollte ist eine Art LRU-Puffer im oberen Panel, wo ich für die 
zuletzt kopierten/ausgeschnittenen Muster eine Mini-Vorschau habe. Bei Klick auf solch ein Vorschau-Bildchen
würde der Editor in den *pattern*-Modus wechseln und das angetippte Muster laden.

2. UC Tournierteilname
----------------------

Da bin ich gerade dran. Plan ist folgender: im *select* und *edit* -Modus gibt
es in der Kopfleiste einen Knopf, der auf die URI `/patterns/{base64-String}`
verweist. Der Base64-String ist der Kodierung des Musters in normaldarstellung.
(vgl. Pattern.normalize und Pattern.encode )

Folge ich diesem Link, gelange ich in eine Seite, die grob folgende Elemente besitzt:

- Eine Miniaturansicht des Musters (dazu kann die `Visualization`-Komponente
  des Editors verwendet werden, einfach die `bus`-Property undefiniert lassen,
  dann ist das Ding komplett passiv.)

- Ein Feld, dass den Namen des Musters beinhaltet

- Ein Feld, dass den Namen des Autors beinhaltet

- Ein Button "hochladen"

- Ein Button "qr-code"

- Ein Button "verwenden"

Beim Initialisieren des Dialogs fragt die Anwendung beim Service nach, ob das
Muster dort bereits bekannt ist.  Falls das der Fall ist, werden die Felder
entsprechend read-only, der hochladen-button wird disabled.

Anderenfalls ist das Feld mit dem Autornamen eine Drop-Down-Liste. Hier kann
der Anwender einen der lokal auf seinem gerät gespeicherten Identitäten
hochladen. Weiterhin gibt es die möglichkeit, eine neue Identität zu erzeugen.
Dazu gibt der Benutzer (z.B. in einem popup) eine Nick ggFs mit Emailadresse
("John Doe <john.doe@tarent.de>") an und bestätigt. Die Anwendung generiert dann
ein neues Schlüsselpaar und speichert den Private Key im DOM-Storage. Zusätzlich sollte
der Public Key zusammen mit dem Nick an den Server geschickt werden.


Der "hochladen"-Button ist nur enabled, wenn
- eine Identität ausgewählt wurde
- der Service das Muster noch nicht kennt.

Der "verwenden"-Button verweist auf `/editor?pattern={base64-String}`
Der Editor startet im *pattern*-Modus mit dem bewußten Pattern.

7. UC Populationen via QR-Code austauschen
---------------------------------------

TODO

Der zuvor erwähnte Button "qr-code" verweist auf eine Seite
`/qr-codes/{base64-String}`
Diese Seite enthält nur den QR-Code. Der QR-Code kodiert
die oben bereits erwähnte URI `/patterns/{base64-String}` 


Kiosk-System / Turnier-"Leitung"
================================

TODO

Das Kiosk-System verwendet die gleiche SPA wie dir Teilnehmerschnittstelle.
Leader-Board und Match-Austragungen könnten 

- nebeneinander auf einer Seite
- abwechselnd auf dem sleben Bildschirm
- auf zwei Verschiedenen bildschirmen 

angezeigt werden. Ich gehe für den Augenblick von letzterem aus, das sollte aber leicht
anzupassen sein.

5. UC Matches austragen
-----------------------

TODO

URI hat die Form `/kiosk/arena`

6. UC Leader-Board anzeigen
---------------------------

TODO

URI hat die Form `/kiosk/leaderboard`
