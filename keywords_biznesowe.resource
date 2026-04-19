*** Settings ***
Resource    keywords_api.resource

*** Keywords ***
Given system jest gotowy
    Utwórz sesję API

When próbuję dodać urządzenie UE o ID ${ue_id}
    Dodaj urządzenie UE    ${ue_id}

Then system powinien odrzucić operację
    Status odpowiedzi powinien być 422

And system powinien poinformować o przekroczeniu maksymalnego ID
    Odpowiedź powinna zawierać komunikat o zbyt dużym ID

And istnieje urządzenie UE o ID ${ue_id}
    Dodaj urządzenie UE    ${ue_id}
    Status odpowiedzi powinien być sukcesem

When próbuję rozpocząć transfer danych dla UE ${ue_id}
    Uruchom transfer danych    ${ue_id}

Then transfer danych powinien zostać uruchomiony poprawnie
    Status odpowiedzi powinien być sukcesem

And w systemie istnieją urządzenia UE o ID ${ue_id_1} i ${ue_id_2}
    Dodaj urządzenie UE    ${ue_id_1}
    Dodaj urządzenie UE    ${ue_id_2}
    Lista urządzeń UE nie powinna być pusta

When resetuję symulator
    Wykonaj reset symulatora

Then reset powinien zakończyć się sukcesem
    Status resetu powinien być sukcesem

And lista urządzeń UE powinna być pusta
    Lista urządzeń UE powinna być pusta technicznie