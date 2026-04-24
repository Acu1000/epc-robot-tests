*** Settings ***
Documentation     Verification of simulator reset to initial state.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}    http://localhost:8000

*** Test Cases ***
Scenario 9: Reset simulator to initial state
    [Documentation]    Verification that simulator reset clears all UE devices.
    [Tags]             reset    positive

    Given Simulator API Session Is Created
    And UEs with IDs 1 and 2 exist in the system
    When User Resets The Simulator
    Then Reset Should Complete Successfully
    And UE List Should Be Empty


*** Keywords ***
Simulator API Session Is Created
    Create Session    epc    ${BASE_URL}

UEs with IDs ${id1} and ${id2} exist in the system
    ${body1}=    Create Dictionary    ue_id=${id1}
    ${resp1}=    POST On Session    epc    /ues    json=${body1}    expected_status=any
    Should Be True    ${resp1.status_code} < 400

    ${body2}=    Create Dictionary    ue_id=${id2}
    ${resp2}=    POST On Session    epc    /ues    json=${body2}    expected_status=any
    Should Be True    ${resp2.status_code} < 400

User Resets The Simulator
    ${response}=    POST On Session    epc    /reset    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Reset Should Complete Successfully
    Should Be True    ${LAST_RESPONSE.status_code} == 200 or ${LAST_RESPONSE.status_code} == 204

UE List Should Be Empty
    ${response}=    GET On Session    epc    /ues    expected_status=any
    ${json}=    Evaluate    $response.json()
    Length Should Be    ${json["ues"]}    0