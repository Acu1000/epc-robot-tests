*** Settings ***
Documentation     Verification that the system blocks stopping non-existing data transfer.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}          http://localhost:8000
${UE_ID}             10
${DEFAULT_BEARER}    9
${EXPECTED_ERR}      not found

*** Test Cases ***
Scenario 16: Attempt to stop non-existing data transfer
    [Documentation]    Goal: Verification whether the system prevents stopping traffic that was never started.
    [Tags]             traffic    negative

    Given Simulator Is Reset And UE ${UE_ID} Is Connected
    When User Attempts To Stop Data Transfer For UE ${UE_ID}
    Then System Should Block The Operation With Message    ${EXPECTED_ERR}
    And Device ${UE_ID} Should Still Exist In The System


*** Keywords ***
Simulator Is Reset And UE ${id} Is Connected
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

User Attempts To Stop Data Transfer For UE ${id}
    ${response}=    DELETE On Session    epc    /ues/${id}/bearers/${DEFAULT_BEARER}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Block The Operation With Message
    [Arguments]    ${msg}
    Should Be True    ${LAST_RESPONSE.status_code} >= 400
    Should Contain    ${LAST_RESPONSE.text}    ${msg}

Device ${id} Should Still Exist In The System
    GET On Session    epc    /ues/${id}    expected_status=200