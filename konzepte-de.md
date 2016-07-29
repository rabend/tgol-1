Zentrale Konzepte
=================


Muster (Pattern)
----------------

Muster sind Value-Types. Sie sind immutable.  Ein Muster ist festgelegt durch
eine Menge lebender Zellen.  Zwei Muster mit der selben Menge lebender Zellen
sind identisch.

Muster zerfallen hinsichtlich ihres Verhaltens in Äquivalenz-Klassen.  Zu jeder
dieser klassen existieren immer genau acht Elemente:


```

*|*|*|  _|_|*|  _|*|_|  *|*|_|
_|_|*|  *|_|*|  *|_|_|  *|_|*|
_|*|_|  _|*|*|  *|*|*|  *|_|_|

_|*|_|  _|*|*|  *|*|*|  *|_|_|
_|_|*|  *|_|*|  *|_|_|  *|_|*|
*|*|*|  _|_|*|  _|*|_|  *|*|_|

```

Für jede solche Äquivalenzklasse wollen wir maximal einen Vertreter pro Turnier
zulassen. Dazu definieren wir eine totale Ordnung auf der Menge aller Muster
und wählen aus der ÄK das Minimum bezüglich dieser Ordnung.

Dazu benutzen wir die Kantor-Paarungsfunktion um zunächst alle Zellen in eine
totale Ordnung zu bringen:

```
0|1|3|6 …
2|4|7|
5|8|
9|
┆

```

Die Cantor-Zahl jeder Zelle interpretieren wir als Zweierpotenz, damit ist ein
Muster ein-eindeutig einer Zahl im Binärsystem zuordnebar. Damit haben wir eine
totale Ordnung auf Mustern.


Ein Muster heißt *normalisiert*, wenn es bezüglich dieser Ordnung minimal ist
und die obere, linke Ecke seiner Bounding Box auf dem Ursprung liegt.  
Im obigen Beispiel wäre das:

```
*|*|_|
*|_|*|
*|_|_|
```

Alle an einem Turnier teilnehmenden Muster sind normalisiert.


Spielfeld (Board)
-----------------

Ein Spielfeld ist ein konzeptionell unendliches, zwei-dimensionales Raster von Zellen.
Jede Zelle ist entweder tot, oder sie gehört einem von zwei Teilnehmern.
Der Zustand des Spielfelds kann sich ändern. 

Das Spielfeld kann aus seinem augenblicklichen Zustand ein neues Spielfeld mit
dem Folgezustand berechnen. Diese Berechnung ist nicht-destruktiv.
