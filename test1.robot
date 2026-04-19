*** Settings ***
Resource    keywords_biznesowe.resource

*** Test Cases ***
Scenario 1: Próba dodania UE z ID większym niż dozwolone
    [Documentation]    Cel: Weryfikacja, czy system blokuje dodanie urządzenia UE z ID większym niż 100.
    [Tags]    attach    negative    boundary

    Given system jest gotowy
    When próbuję dodać urządzenie UE o ID 101
    Then system powinien odrzucić operację
    And system powinien poinformować o przekroczeniu maksymalnego ID