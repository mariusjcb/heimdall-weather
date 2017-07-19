# Heimdall Weather

Target: iOS 10.3+

Xcode 8.3+
Apple Swift version 3.1 (swiftlang-802.0.53 clang-802.0.42)
Swift Target: x86_64-apple-macosx10.9


### Functii

* Today Extension - Widget vreme
* Vremea pentru locatia curenta a utilizatorului
* Posibilitatea de a "urmari" vremea dintr-o noua locatie (butonul ADD)
* Posibilitatea de a nu mai urmari o locatie (butonul REMOVE)
* UIPageViewController cu toate locatiile "urmarite" de utilizator
* Verificare vreme in background


### Extindere

Extinderea codului sau modificarea structurii API-ului este destul de simpla, am incercat sa prevad cat mai multe posibilitati
de modificare a API-ului, astfel ca toate modificarile la nivel de structura se pot face in **Defaults.RestAPI**

La fel, multe din modificarile pe cod se pot face din **Defaults** sau **info.plist**


### Neimplementat Inca

* Autocomplete pentru gasirea locatiei


### Utilizare

La adaugarea unei locatii noi trebuie introdus **CORECT** numele orasului.
Campul Country va fi completat cu **CODUL ISO3166 al TARII** ex: RO, IN, UK

Mai multe aici: [Coduri ISO3166](https://en.wikipedia.org/wiki/ISO_3166)



Daca o locatie nu este valida aceasta va disparea automat din PageViewController
