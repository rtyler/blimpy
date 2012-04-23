Feature: Create a Blimpfile in the current working directory
  As a Blimpy user
  In order to get started as quickly as possible
  The 'init' command should create a skeleton Blimpfile in the current directroy


  Scenario: Clean working directory
    Given I have no Blimpfile in my current directory
    When I run `blimpy init`
    Then a file named "Blimpfile" should exist
