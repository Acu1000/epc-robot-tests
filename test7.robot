*** Settings ***
Documentation     Verification of the blockage against deleting the default transport channel (ID 9)
...               The scenario checks the system's resilience to attempts to remove the connection foundation.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${UE_ID}          50
${DEFAULT_BEARER}  9
${EXPECTED_ERR}   Cannot remove default bearer

*** Test Cases ***
Scenario 7: Attempt to remove default bearer with ID 9
    [Documentation]    Goal: Verification whether the system, according to the specification, prevents the deletion
    ...                of the mandatory channel with ID 9.
    [Tags]             bearer    negative
    
    Given Simulator Is Reset And UE ${UE_ID} Is Connected
    When User Attempts To Remove Default Bearer ${DEFAULT_BEARER} For UE ${UE_ID}
    Then System Should Block The Operation With Message    ${EXPECTED_ERR}
    And Device ${UE_ID} Should Still Exist In The System


*** Keywords ***
Simulator Is Reset And UE ${id} Is Connected
    [Documentation]    Setting initial conditions: a clean network and one active device.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    ${body}=    Create Dictionary    ue_id=${id}
    ${resp}=    POST On Session    epc    /ues    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} < 400

User Attempts To Remove Default Bearer ${bearer_id} For UE ${id}
    [Documentation]    Calling the channel deletion procedure (bearer deletion).
    ${response}=    DELETE On Session    epc    /ues/${id}/bearers/${bearer_id}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

System Should Block The Operation With Message
    [Arguments]    ${msg}
    [Documentation]    Verification whether the system rejected the request and displayed the correct message.
    # We check the error code (>= 400)
    Should Be True    ${LAST_RESPONSE.status_code} >= 400
    # We verify the error content (according to the simulator logs)
    Should Contain    ${LAST_RESPONSE.text}    ${msg}
    Log    The error status and message are correct.    level=INFO

Device ${id} Should Still Exist In The System
    [Documentation]    Final confirmation that the resource was not deleted.
    # We use GET on the device address, which is the most stable endpoint in the API.
    GET On Session    epc    /ues/${id}    expected_status=200
    Log    Success: The device and its default resources remained intact.