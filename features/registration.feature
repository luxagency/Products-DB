       Feature: Registration From
          In Order to recollect emails and names
          As an user
          I want to see the registration page

          Scenario: Registration Page
            Given I am on the registration page
            Then I should see "Name"
            Then I should see "email"
