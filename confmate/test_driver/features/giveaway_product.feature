Feature: Giveaway a Product
    Scenario: Applying a product related to a certain conference
        Given the user is on the "ProductsPage"
        When the user taps on a product
        And the user taps the "ApplyForButton"
        And the user fills out a small "ApplianceForm" with "This is a Test Form"
        And the user presses "ContinueButton"
        Then the app adds the user to the candidates list for that specific product

    Scenario: Promoting/recommending products on the conference
        Given the host is on the "ProductsPage"
        When the host taps the "MyProductsTab"
        And the host taps on a product
        And the host picks an attendee
        And the host taps the "ConfirmGiveButton"
        Then the app creates a new product