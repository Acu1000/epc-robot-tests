*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Incorrect bearer id test

    Given Blank Simulation
    And Stworzono UE z ID 60
    And Created Bearer With ID 5 For UE 60
    And Created Bearer With ID 5 For UE 60
    And Began Broadcasting From UE 60 Via Bearer 5
    And Began Broadcasting From UE 60 Via Bearer 6

    # The program seems to lack input for stop broadcast without giving bearer id
    When Stopped Broadcasting From UE 60 Via Bearer 5
    And Stopped Broadcasting From UE 60 Via Bearer 6

    Then No Traffic From 60 Via Bearer 5
    And No Traffic From 60 Via Bearer 6

*** Keywords ***
Blank Simulation
    Create Session    epc    ${BASE_URL}
    ${response}=    POST On Session    epc    /reset
    Status Should Be    200    ${response}

UE With ID ${id} Connected
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

Created Bearer With ID ${bear_id} For UE ${ue_id}
    ${data}=    Create Dictionary    bearer_id=${bear_id}
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers    json=${data}
    Status Should Be    200    ${response}

Began Broadcasting From UE ${ue_id} Via Bearer ${bear_id}
    ${data}=    Create Dictionary    protocol=tcp    kbps=50
    ${response}=    POST On Session    epc    /ues/${ue_id}/bearers/${bear_id}/traffic    json=${data}
    Status Should Be    200    ${response}

Stopped Broadcasting From UE ${ue_id} Via Bearer ${bear_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id}/bearers/${bear_id}/traffic
    Status Should Be    200    ${response}

No Traffic From ${ue_id} Via Bearer ${bear_id}
    ${response}=    GET On Session    epc    /ues/${ue_id}/bearers/${bear_id}/traffic
    Status Should Be    200    ${response}
    ${values}=    Get Value From Json    ${response.json()}    $.protocol

    ${is_empty}=    Run Keyword And Return Status
    ...    Should Be Empty    ${values}

    ${is_null}=    Run Keyword And Return Status
    ...    Should Be Equal    ${values}[0]    ${None}

    Should Be True    ${is_empty} or ${is_null}