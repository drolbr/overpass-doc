Fehlermeldungen
===============

Mögliche Fehlermeldungen von der Overpass API und ihre Bedeutung.

## Syntaxfehler

...

## Keine Verbindung zum Server

In einigen Fällen wird eine Abfrage schon vor dem eigentlichen Start abgewiesen.
Dies kann daran liegen,
dass der Server nicht erreichbar ist,
nicht die passenden Daten hat,
bereits zu viele Anfragen gestellt worden sind
oder an einem internen Fehler.

In allen diesen Fällen ist der erste Schritt zu prüfen,
ob ein anderer Server genutzt werden sollte.

``Tried to use meta file but no meta files available on this instance.``:
...

``Tried to use museum file but no museum files available on this instance.``:
...

``open64: `` ... ``Please check /api/status for the quota of your IP address.``:
...

``open64: `` ... ``The server is probably too busy to handle your request.``:
...

``The dispatcher (i.e. the database management system) is turned off.``:
...

``open64: `` ...:
...

## Abbruch durch den Server

Aus Schutz vor Überlastung haben Abfragen eine zulässige Höchstlaufzeit und eine Speicherplatzbegrenzung.
Dies sind die Meldungen,
mit denen der Server die Verletzung der jeweiligen Grenze anzeigt.

In den meisten Fällen ist es erforderlich,
die Abfrage anzupassen,
indem z.B. das Zielgebiet verkleinert
oder die Suchkriterien gestrafft werden.

``Query timed out in `` ... `` at line `` ... `` after `` ... ``seconds.``:
...

``Query ran out of memory in `` ... `` at line `` ... ``. It would need at least ``...`` MB of RAM to continue.``:
...

``Query run out of memory using about ``...`` MB of RAM.``:
...

``Query failed with the exception: `` ...:
...
