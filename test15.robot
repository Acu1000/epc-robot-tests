*** Settings ***
Documentation     Scenario 15: Verification of the JSON response structure.
...               The test aims to ensure that the API returns correctly formatted JSON objects 
...               with the expected schema and data types.
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000

*** Test Cases ***
Scenario 15 - Verify JSON response structure for UE list
    [Documentation]    Goal: Verify that requesting the list of devices returns a valid
    ...                JSON format containing the 'ues' array, as per the specification.
    [Tags]             api    json    positive
    
    Given Simulator Is Reset And Example Devices Are Connected
    When User Requests The List Of Connected Devices
    Then The System Should Return A Valid JSON Format
    And The JSON Should Contain The Expected Array Structure


*** Keywords ***
Simulator Is Reset And Example Devices Are Connected
    [Documentation]    Resets the environment and connects two sample devices.
    Create Session    epc    ${BASE_URL}
    POST On Session    epc    /reset    expected_status=any
    
    ${body1}=    Create Dictionary    ue_id=10
    ${body2}=    Create Dictionary    ue_id=20
    POST On Session    epc    /ues    json=${body1}    expected_status=any
    POST On Session    epc    /ues    json=${body2}    expected_status=any

User Requests The List Of Connected Devices
    [Documentation]    Fetches the current state of the network (list of all UEs).
    ${response}=    GET On Session    epc    /ues    expected_status=200
    Set Test Variable    ${LAST_RESPONSE}    ${response}

The System Should Return A Valid JSON Format
    [Documentation]    Checks if the response headers define the content as JSON and attempts to parse it.
    ${content_type}=    Get From Dictionary    ${LAST_RESPONSE.headers}    Content-Type
    Should Contain    ${content_type}    application/json    msg=ERROR: The Content-Type header is not application/json!
    
    # Evaluating the JSON will throw an error if the format is corrupted
    ${json_data}=    Evaluate    $LAST_RESPONSE.json()
    Set Test Variable    ${JSON_DATA}    ${json_data}

The JSON Should Contain The Expected Array Structure
    [Documentation]    Validates the schema: checks if the 'ues' key exists and is of type list.
    Dictionary Should Contain Key    ${JSON_DATA}    ues    msg=ERROR: The JSON response is missing the required 'ues' root key!
    
    # We evaluate if the value under the 'ues' key is a Python list (which corresponds to a JSON array)
    ${is_list}=    Evaluate    isinstance($JSON_DATA['ues'], list)
    Should Be True    ${is_list}    msg=ERROR: The 'ues' field must be an array (list)!