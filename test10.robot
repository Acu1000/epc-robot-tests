*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Incorrect bearer id test

    Given System Jest Zresetowany
    And Stworzono UE z ID 60
    And Stworzono Bearer z ID 5 Dla UE 60
    And Stworzono Bearer z ID 6 Dla UE 60
    And Rozpoczeto Nadawanie z UE 60 z Bearerem 5
    And Rozpoczeto Nadawanie z UE 60 z Bearerem 6

    # Powinno byc zastapiane zatrzymaniem bez podania id bearera (zatrzymanie wszystkich)
    # ale wyglada na to ze nie ma endpointa do takiego inputu
    When Zatrzymano Nadawanie z UE 60 z Bearerem 5
    And Zatrzymano Nadawanie z UE 60 z Bearerem 6

    Then Nie Ma Ruchu z UE 60 z Bearerem 5

*** Keywords ***
System Jest Zresetowany
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    Status Should Be    200    ${response}

Stworzono UE z ID ${ue_id}
    ${data}=    Create Dictionary    ue_id=${ue_id}
    ${response}=    POST On Session    epc    /ues    json=${data}
    Status Should Be    200    ${response}

Stworzono Bearer z ID ${bear_id} Dla UE ${ue_id}
    ${data}=    Create Dictionary    bearer_id=${bear_id}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers    json=${data}
    Status Should Be    200    ${response}

Rozpoczeto Nadawanie z UE ${ue_id} z Bearerem ${bear_id}
    ${data}=    Create Dictionary    protocol=tcp    kbps=50
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/${bear_id}/traffic    json=${data}
    Status Should Be    200    ${response}

Zatrzymano Nadawanie z UE ${ue_id} z Bearerem ${bear_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id}/bearers/${bear_id}/traffic
    Status Should Be    200    ${response}

Nie Ma Ruchu z UE ${ue_id} z Bearerem ${bear_id}
    ${response}=    GET On Session    epc    /ues/${ue_id}/bearers/${bear_id}/traffic
    Status Should Be    200    ${response}
    ${values}=    Get Value From Json    ${response.json()}    $.protocol

    ${is_empty}=    Run Keyword And Return Status
    ...    Should Be Empty    ${values}

    ${is_null}=    Run Keyword And Return Status
    ...    Should Be Equal    ${values}[0]    ${None}

    Should Be True    ${is_empty} or ${is_null}