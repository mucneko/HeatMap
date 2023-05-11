Feature: get Covid-19 Data for Muenchen

Scenario: get weekly inzidence for Muenchen from survstat.rki.de
Given open start page

When I choose Abfrage erstellen
When I click on "English"
When I add new Filter

Then make BrowserPicture and save it as "get_csv_MUC_inzidenz_0.png"

Then check for visible input fields

When set Erreger to Covid-19
When set Meldejahr to 2023
When set place to SK Muenchen

# When set Merkmale Zeilen to Altersgruppieren 5 Jahre Intervalle
When set Merkmale Spalten to Meldewoche
When activate Leere Zeilen
When activate Inzidenzen

Then make BrowserPicture and save it as "get_csv_MUC_inzidenz_1.png"

When click ZIP herunterladen

