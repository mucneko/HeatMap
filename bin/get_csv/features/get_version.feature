Feature: get last update of Database

Scenario: get last update
Given open start page

Then make BrowserPicture and save it as "get_feature_0.png"
When I choose Abfrage erstellen
Then make BrowserPicture and save it as "get_feature_1a.png"
When I click on "English"
Then make BrowserPicture and save it as "get_feature_1.png"

Then save HTML-Page as "get_feature.html"

