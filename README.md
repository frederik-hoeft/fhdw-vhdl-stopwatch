# fhdw-vhdl-stopwatch
An embedded systems project for college.

## Test Preprocessor
Um die Implementierung des Stoppuhr-Automaten möglichst angenehm zu testen, wurde ein C\#/.NET Programm erstellt, welches annotierte CSV Dateien in TXT Dateien umwandelt. Dies ermöglicht es mithilfe von CSV kompatiblen Editoren (wie Microsoft Excel) Testdaten anzulegen und mit Notizen zu versehen, was die Daten auch für Dritte einsichtiger macht. Die Testdaten werden dann ohne die Kommentare in TXT Dateien kopiert, in denen sie so aufbereitet werden, dass sie für das Testframework genutzt werden können.

### CSV Struktur
Damit das C\#-Programm die Testdaten verarbeiten kann, wird der Aufbau der CSV Datei wie folgt vorgeschrieben:
- Die erste Zeile kann für Kommentare o.Ä. verwendet werden.
- Die erste Spalte kann für Kommentare o.Ä. verwendet werden.
- Die Input-Daten fangen ab Zeile 2 Spalte 2 an. Für jedes Input-Feld wird eine neue Spalte hinzugefügt.
- Die Output-Daten werden durch eine leere Spalte von den Input-Daten getrennt. Für jedes Output-Feld wird eine neue Spalte hinzugefügt.
- Ein Input-Output-Datenpaar steht in einer Zeile.

Der folgende Bildschirmausschnitt veranschaulicht die oben beschriebene Struktur anhand eines Beispiels mit drei Input-Feldern und zwei Output-Feldern. **(1)**
![](./assets/images/csv-structure.png)

### TXT Struktur
Pro CSV Datei werden zwei TXT Dateien erstellt. Eine Datei beinhaltet die Input-Felder und eine Datei beinhaltet die Output-Felder. Daten in verschiedenen Spalten werden durch Leerzeichen separiert. Die Daten werden unter Beeinhaltung der angegebenen Reihenfolge kopiert, jedoch wird der letzte Input-Datensatz, sowie der erste Output-Datensatz zwei Mal eingefügt, da die Zustandsänderung um einen Takt nach hinten verschoben ist.

Die generierten Dateien passend zu Beispiel **(1)** sehen wie folgt aus:

*Input.txt*
```
0 0 0
0 0 1
0 1 1
1 0 1
1 0 1
1 1 1
0 1 1
0 0 1
0 0 1
0 1 1
1 0 1
0 1 1
1 0 1
1 0 1
```

*Output.txt*
```
0 0
0 0
0 0
0 0
1 0
1 0
1 0
1 0
1 0
1 0
1 0
0 0
0 0
0 0
```

