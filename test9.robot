*** Settings ***
Resource    keywords_biznesowe.resource

*** Test Cases ***
Scenario 9: Resetowanie symulatora do stanu początkowego
    [Documentation]    Weryfikacja resetu symulatora do stanu początkowego.
    [Tags]    reset    positive

    Given system jest gotowy
    And w systemie istnieją urządzenia UE o ID 1 i 2
    When resetuję symulator
    Then reset powinien zakończyć się sukcesem
    And lista urządzeń UE powinna być pusta