*** Settings ***
Resource    keywords_biznesowe.resource

*** Test Cases ***
Scenario 5: Rozpoczęcie transferu danych dla poprawnego UE
    [Documentation]    Weryfikacja rozpoczęcia transferu danych dla poprawnego UE
    [Tags]    traffic    positive

    Given system jest gotowy
    And istnieje urządzenie UE o ID 10
    When próbuję rozpocząć transfer danych dla UE 10
    Then transfer danych powinien zostać uruchomiony poprawnie