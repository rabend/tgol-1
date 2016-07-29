Was war nochmal die Idee?
=========================

Die wesentliche Idee ist, eine Conway's-Game-of-Life Simulation mit leicht
modifizierten Regeln zu erstellen, die es erlaubt, jeweils zwei
*Muster* (d.h.  Ausgangskonfiguration lebender Zellen) in einer "Welt"
gegeneinander antreten zu lassen.  Dabei verwenden die Muster  jeweils eine andere "Farbe", d.h.
anders als bei Conways Orginalregeln gibt es drei Zustände für eine Zelle: Tod, Farbe I und Farbe II.
Wie beim Orginal erwacht eine tote Zelle zum Leben, wenn sie genau drei lebende Nachbarn hat; es gibt in
diesem Fall also immer mindestens zwei Nachbarzellen mit der selben Farbe. Die neue Zelle 
übernimmt diese Farbe.

Diejenige Farbe, von der es nach einer festgelegten Anzahl von Runden die meisten lebenden Zellen gibt,
gewinnt das Match.

Jeder Froscon-Besucher kann beliebig viele eigene Muster ins Rennen
schicken.  Voraussetzung ist irgend ein Gerät mit Webbrowser ("Smart"-Phone,
Tablett, Laptop,...). Die Größe der Muster (genauer: die Anzahl der lebendigen Zellen) ist dabei beschränkt.

Die Austragung des ganzen Gemetzels lässt sich hübsch bunt auf unseren
rieseigen Fernsehrn visualisieren.

Der Gewinner gewinnt neben Ruhm und Ehre z.B. dolle Preise. Oder was weiss ich.

Lösungskomponenten
==================

Ich sehe drei wesentliche Lösungskomponenten:

Der *Turnier-Service* hält alle Informationen über
 - aktuelle Turniere (in unserem Fall verm. genau eines?)
 - Teilnehmende Muster und deren Autoren
 - bereits gepsielte Matches und deren Ausgang

Die *Teilnehmer-Schnittstelle* wird von Turnier-Teilnehmern (Spielern) zum
Entwerfen/Testen eigener Muster sowie zum Anmelden der Muster am
Turnier verwendet. Zusätzlich wird es evtl Funktionen zum lokalen Verwalten
von Mustern oder zum direkten Austausch mit anderen Teilnehmern geben.


Das *Kiosk-System* dient der zentralen Visualisierung der Matches so wie des
Leader-Boards am Stand.  Das Kiosk-System ist gleichzeitig der Agent, der
gegenüber dem Turnier-Service als "Turnierleitung" auftritt. Es entscheidet, welches Match
jeweils als nächstes auszutragen ist, übernimmt die Bewertung des Matches und überträgt das Ergebnis
an den Turnier-Service. Das Kiosk-System ist als entsprechend konfigurierte Variante der Teilnehmer-Schnittstelle
umzusetzen. Es sollte nach dem Start keine weitere Interaktion benötigen.


Turnier-Service
===============

In meiner Fantasie irgend ein kleiner schnuckeliger REST-Service, den man z.B. mit
Express.JS realisieren würde.


UC Neues Turnier erzeugen
-------------------------

Tournierleiter erzeugt Tournier. Das geht manuell auf dem Persistenzlayer
(verm. Dateisystem) Das Turnier *gehört* diesem Tournierleiter.  Er legt beim
Erzeugen einen RSA Public Key ab, den der Service später verwendet, um 
die übersandten Matchergebnisse zu validieren.


UC Teilnehmer beim System registrieren
--------------------------------------

Endbenutzer lädt einen Nick ggfs inkl. Emailadresse und einen (eigens für das Spiel generierten!)
public key hoch. Er wird diese und alle folgenden Requests an den Service mit dem zugehörigen 
private key signieren.


UC Muster zu Turnier anmelden
---------------------------------

Endnutzer lädt eine Start-Muster zum Turnierservice hoch. Diese Muster
*gehört* diesem Nutzer, er signiert es mit seinem private key. Der Service kann diese 
Signatur anhand des hinterlegten Public Keys verifizieren.

Idealerweise sollte der Endbenutzer ein Captcha lösen müssen. 

Muster sind modulo Rotation/Spiegelung/Translation eindeutig durch eine Liste
lebender Zellen festgelegt. Diese Liste wird, in geeigneter Weise normalisiert
und kodiert, zum Referenzieren des Musters verwendet.

Der Service prüft, ob das (in diesem Sinne) selbe
Muster bereits von einem anderen Spieler hochgeladen wurde und antwortet
gegebenenfalls mit einer Fehlermeldung.



UC Abfrage zu einem Turnier ausstehender Matches und Leaderboard
----------------------------------------------------------------

Endbenutzer erfragt vom Service eine Liste aller derzeit bereits ausgetragenen
Matches.  Ein Match wird anhand eines UUIDs referenziert und beinhaltet
folgende Informationen:
- Teilnehmende Muster, ihre Farbe und ihre Position in der Arena
- Ergebnis des Matches. Je nachdem, wie genau die
  Turniermodalitäten aussehen, sollte hier auch das Leader-Board oder ein
  Turnierbaum o.ä. übertragen werden.

Für diese Abfrage ist keine Authentifizierung notwendig.

UC Ergebnis für Match hochladen
-------------------------------

Der Tournierleiter (s.o. "Kiosk-System") kann ein Matchergebnis hochladen.
Er signiert das übertragene Ergebnis mit seinem private key,
der Server verifiziert diese Signatur anhand des hinterlegten Public Keys.




Teilnehmer-Schnittstelle (Mobile-taugliche SPA)
===============================================

das SPA funktionieren grundsätzlich auch komplett ohne Turnier-Service.  Eigene
Muster werden via Local Storage persistiert.  Da ein typisches Muster
in unserer konkreter Situation vermutlich nicht sonderlich komplex werden wird,
läßt sie sich bequem als QR-Code bzw query-parameter abbilden.  Ein direkter
Austausch von Mustern zwischen Benutzern z.B. zum Austragen von
Freundschaftsspielen wäre auf diese Weise realisierbar. (NTH)


UC Muster erstellen/ Testen ("Design-Ansicht")
--------------------------------------------------

Ein Spieler kann ein eigenes Muster erstellen und schauen wie sie sich
alleine (ohne Gegner) entwickelt.
 - Er kann dabei die Simulation jederzeit in ihren Anfangszustand
   zurücksetzen.
 - Er kann dem Muster einen Namen geben und es im Local DOM Storage
   persistieren. 
 - Er kann aus ein zuvor gespeichertes Muster laden modifizieren und die
   gespeicherte Version überschreiben.
 - Er kann eine zuvor gepseicherte Muster duplizieren.



UC Tournierteilname
-------------------

In der "Design-Ansicht" kann der Spieler ein Muster markieren und zu einem Tournier
anmelden.  Dazu muss er idealerweise ein Captcha lösen. Siehe entsprechender UC
beim Tournier-Service. 

UC Muster via QR-Code austauschen
---------------------------------------

Spieler A erzeugt zu einem eigenen Muster einen QR-Code.  Spieler B scanned
den QR-Code, der enthält eine URL, die Spieler B in seinem Browser öffnet.
Beim Öffnen der URL wird die in der URL kodierte Muster im Local Store
gespeichert und in der Design-Ansicht geöffnet


Kiosk-System / Turnier-"Leitung"
================================

Das Kiosk-System ist als nicht-interaktive Webanwendung ausgelegt.  Das System
verfügt über den nötigen Private Key, um so Matchergebnisse zu signieren und an
den Tournierservice zu übertragen. 

UC ausstehende Matches austragen
--------------------------------

 - Die Turnierleitung fragt den Service nach teilnehmenden Mustern und bereits gespielten matches, 
   und wählt in geeigneter Weise die nächste Paarung, die gegeneinander antreten soll.
 - Die Simulation wird visualisiert. Anschließend wird das Ergebnis an den
   Turnierdienst übertragen.
 - Das ganze wird wiederholt, theoretisch bis zum Ende der Froscon.

UC Leader-Board anzeigen
------------------------

 - Die Turnierleitung fragt den Service nach dem derzeitigen Punktestand aller
   Turnierteilnehmer und stellt das ganze in einer hübschen Tabelle dar.
 - Die Darstellung wird alle paar Sekunden aktualisiert.
 - Besser: Der Service benachrichtigt die Turnierleitung über irgend eine Art
   Message-Bus wenn sich die Daten ändern.


