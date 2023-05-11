require 'capybara/cucumber'

# Config ziehen
require 'inifile'

# inifile holen
# read an existing file
inifile = IniFile.load('local.conf')
confGeneral = inifile["general"]
confTest = inifile["test"]
confModify = inifile["modify"]
confView = inifile["view"]

# multiline comment
=begin
inifile.each do |section, parameter, value|
  puts "#{parameter} = #{value} [in section - #{section}]"
end
=end

#output one property
$baseURL = confGeneral['baseURL']
$testPageURL = confTest['testPageURL']
# $path = confModify['path']
$script = confGeneral['script']
# $details_view = confGeneral['details_view']
# $action = confModify['action']

Capybara.default_driver = :selenium_chrome_headless # :selenium :selenium_chrome_headless :selenium_chrome

# default: css - wir sind aber eher im xpath unterwegs
Capybara.default_selector = :xpath

# https://github.com/teamcapybara/capybara/issues/1057
# The head element is usually invisible, the default has changed in
# Capybara 2.1.0 to by default not find hidden elements, you need to
# pass :visible => false or set Capybara.ignore_hidden_elements = false.
Capybara.ignore_hidden_elements = false


Given (/^open test page$/) do
  @url = "#{$testPageURL}"
  puts "lade #{@url}"
  visit @url
  # current_window.resize_to(1200, 1500);
end

Given (/^open start page$/) do
  # http://user:pass@example.com....
  @url = "#{$baseURL}#{$script}"
  puts "lade #{@url}"
  # visit "#{@url}"
  # page.driver.language = 'de'
  # header "Accept-Language", 'de'
  # page.driver.add_headers('Accept-Language' => 'de')
  # page.driver.header 'Accept-Language', 'de'
  visit @url
  current_window.resize_to(1200, 2500);
  #  page.save_screenshot('screen_debug1.png', full: true) 
  page.save_page('page_debug1.html') ;
end

When (/^I do my basic test$/) do
  page.save_screenshot('screen_testpage0.png', full: true) 

  find('//div[@id="eins"]').first('//input[@type="text"]').fill_in( :with => 'Test1');
  page.save_screenshot('screen_testpage1.png', full: true) 


  find('//div[@id="zwei"]').first('//input[@type="text"]').fill_in( :with => 'Test2');
  page.save_screenshot('screen_testpage2.png', full: true) 


  puts all("//div[@id='zwei']/input[2]").inspect();
  # puts find("//div[@id='zwei']" > "//input[1]").inspect();

  # div2 = find('//div[@id="zwei"]' );
  # input2 = all('//input[@type="text"]')[1];
  # puts div2.inspect();
  # puts input2.inspect();
  # all("//input[2]")[0].fill_in( :with => 'Test2a')
  find("//div[@id='zwei']/input[2]").fill_in( :with => 'Test2a');
  # puts div2.all('//input[@type="text"]')[1].inspect();
  # div2.all('//input[@type="text"]')[1].fill_in( :with => 'Test2a')
  page.save_screenshot('screen_testpage2a.png', full: true) 

end

When (/^I choose Abfrage erstellen$/) do
  page.find('//a[@id="RepeaterFooterMenu_RepeaterFooterSubMenu_1_HyperLinkSubMenuItem_1"]').click();
  
end

When (/^I add new Filter$/) do
  click_on('ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_ImageButtonAddFilterRow')
end

When (/^set Erreger to Covid-19$/) do

  puts "open fields for Desease"
  puts "open menue"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_0_chosen"]').click();
  puts "choose Desease"
  page.find('//li[@data-option-array-index="2"]').click();
  puts "fill in Covid-19"
  page.save_screenshot('setErreger_0.png', full: true) 
  page.save_page('setErreger_0.html') ;

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_0_ListBoxFilterLevelMembers_0_chosen"]').first('//input[@value="Select options"][@type="text"]')
    puts "covid-19 gefunden";
    page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_0_ListBoxFilterLevelMembers_0_chosen"]').first('//input[@value="Select options"][@type="text"]').click
  end

  page.save_screenshot('setErreger_1.png', full: true) 
  page.save_page('setErreger_1.html') ;

  if page.find('//select[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_0_ListBoxFilterLevelMembers_0"]')

    page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_0_ListBoxFilterLevelMembers_0_chosen"]').find('//li[@data-option-array-index="7"]').click;

  page.save_screenshot('setErreger_2.png', full: true) 
  else
      puts "selectmenue nicht gefunden";
  end 
end

When (/^set Meldejahr to 2022$/) do
  puts "open fields for Meldejahr"
  puts "open menue"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_1_chosen"]').click();
  puts "choose Year of notification"
  find('//li[@title="Year of the calendar week in which the local health authority officially took notice of the case for the first time, either by reports or own investigations. For the 1. and 53. calender week, the year of the calender week may differ from the year of a given day."]').click();

  puts "fill in 2022"

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"]')

    puts "jahr gefunden";

    # does not work as expected
    # page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"] ').find('//input[@value="Select options"][@type="text"]').click
    all('//input[@value="Select options"][@type="text"]')[4].click;

  end

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"]')

    page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"]').find('//li[@data-option-array-index="1"]').click;

  else
      puts "selectmenue nicht gefunden";
  end 

end

When (/^set Meldejahr to 2023$/) do
  puts "open fields for Meldejahr"
  puts "open menue"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_1_chosen"]').click();
  puts "choose Year of notification"
  find('//li[@title="Year of the calendar week in which the local health authority officially took notice of the case for the first time, either by reports or own investigations. For the 1. and 53. calender week, the year of the calender week may differ from the year of a given day."]').click();

  puts "fill in 2023"

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"]')

    puts "jahr gefunden";

    # does not work as expected
    # page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"] ').find('//input[@value="Select options"][@type="text"]').click
    all('//input[@value="Select options"][@type="text"]')[4].click;

  end

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"]')

    page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"]').find('//li[@data-option-array-index="0"]').click;

  else
      puts "selectmenue nicht gefunden";
  end 

end


When (/^set place to SK Muenchen$/) do
  puts "open fields for place"
  puts "open menue"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_2_chosen"]').click();

  puts "choose State an territorial"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_2_chosen"]/div/ul/li[@data-option-array-index="8"]').click();

  puts "open"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_2_ListBoxFilterLevelMembers_2_chosen"]/ul/li/input').click();

  puts "choose SK Muenchen"
  page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_2_ListBoxFilterLevelMembers_2_chosen"]/div/ul/li[@data-option-array-index="82"]').click();

end


When (/^set Merkmale Zeilen to Altersgruppieren 5 Jahre Intervalle$/) do
  find("//div[@id='ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_DropDownListRowHierarchy_chosen']/a").click;

  if ("//div[@id='ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_DropDownListRowHierarchy_chosen']/div/ul/li[@data-option-array-index='18']")
    find("//div[@id='ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_DropDownListRowHierarchy_chosen']/div/ul/li[@data-option-array-index='18']").click;
  end
end

When (/^set Merkmale Spalten to Meldewoche$/) do
  find("//div[@id='ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_DropDownListColHierarchy_chosen']/a").click;

  if ("//div[@id='ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_DropDownListColHierarchy_chosen']/div/ul/li[@data-option-array-index='18']")
    find("//div[@id='ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_DropDownListColHierarchy_chosen']/div/ul/li[@data-option-array-index='5']").click;
  end

end


When (/^activate Leere Zeilen$/) do
  find('//input[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_CheckBoxNonEmpty"]').click
end

When (/^activate Inzidenzen$/) do
  find('//input[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_CheckBoxIncidence"]').click
end

When (/^click ZIP herunterladen$/) do
  click_on('ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_ButtonDownload');
  page.save_screenshot('screen_debug1.png', full: true) 
  page.save_page('page_debug1.html') ;
end

When (/^I click on "(.*?)"$/) do |linktext|
  print "klicke auf: ", linktext, "\n";
  click_link linktext
end  



Then (/^check for visible input fields$/) do
  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_0_chosen"]')
    puts "field for Reference definition gefunden"
  end

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_1_chosen"]')
    puts "field for year gefunden"
  end

  if page.find('//div[@id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_2_chosen"]')
    puts "field for place gefunden"
  end

  # id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_0_chosen"
  # id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_0_ListBoxFilterLevelMembers_0_chosen"

  # id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_DropDownListFilterHierarchy_1_chosen"
  # id="ContentPlaceHolderMain_ContentPlaceHolderAltGridFull_RepeaterFilter_RepeaterFilterLevel_1_ListBoxFilterLevelMembers_0_chosen"

end

Then (/^make BrowserPicture and save it as "(.*?)"$/) do |filename|
  page.save_screenshot(filename, full: true);
end

Then (/^save HTML-Page as "(.*?)"$/) do |filename|
  page.save_page(filename) ;
end

#proto
Given (/^xxxx$/) do
end

#proto
When (/^xxxx$/) do
end

#proto
Then (/^xxxx$/) do
end

