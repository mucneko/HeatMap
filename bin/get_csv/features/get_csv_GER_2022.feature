Feature: get Covid-19 Data for GERMENAY

Scenario: get data for Germny from survstat.rki.de
Given open start page

Wshen I choose Abfrage erstellen
When I click on "English"
When I add new Filter

Then make BrowserPicture and save it as "get_csv_GER_2022_0.png"

Then check for visible input fields

When set Erreger to Covid-19

When set Meldejahr to 2022
When set Merkmale Zeilen to Altersgruppieren 5 Jahre Intervalle
When set Merkmale Spalten to Meldewoche
When activate Leere Zeilen
When activate Inzidenzen

Then make BrowserPicture and save it as "get_csv_GER_2022_1.png"

When click ZIP herunterladen

