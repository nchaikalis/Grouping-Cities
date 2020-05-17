CREATE OR REPLACE PROCEDURE GroupingProcedure
AS
BEGIN
DECLARE 
 c1 NUMBER; -- random gia to ID tou 1ou kedrou
 c2 NUMBER; -- random gia to ID tou 2ou kedrou
 center1 CITYPROJECT%ROWTYPE; -- 1o Kedro
 center2 CITYPROJECT%ROWTYPE; -- 2o Kedro
 temp CITYPROJECT%ROWTYPE; -- temp city gia na vriskw se poia omada anoikei k na tin kanw add stin List.
 distance1 NUMBER; --apostasi metaksi Lat Long gia center 1.
 distance2 NUMBER; --apostasi metaksi Lat Long gia center 2.
 newLat NUMBER; -- metavliti gia to neo Latitude.
 newLon NUMBER; -- metavliti gia to neo Longitude.
 TYPE teamList IS TABLE OF CITYPROJECT%ROWTYPE;
 omada1 teamList := teamList ();
 omada2 teamList := teamList ();
 i NUMBER := 1;
 BEGIN 
    -- Generate 2 randoms:
    c1 := RandomNumber1_15(); 
    c2 := RandomNumber1_15(); 
    -- An ta 2 randoms einai idia vriskw diaforetiko 2o:
    WHILE c2 = c1
    LOOP
       c2 := RandomNumber1_15(); 
    END LOOP;
    --Typwnw ta randoms. Ta randoms auta einai ta ID twn polewn pou tha einai ta Kedra.
    dbms_output.put_line('Random 1: ' || c1); 
    dbms_output.put_line('Random 2: ' || c2);
    
    --Vriskw poies polois einai ta random Kedra:
    Select * into center1 from CityProject where id = c1;
    Select * into center2 from CityProject where id = c2;
    dbms_output.put_line('1o Kedro: '|| center1.name);
    dbms_output.put_line('2o Kedro: '|| center2.name);
    
    --Add ta Kedra stis listes:
    omada1.EXTEND;
    omada1 (omada1.LAST) := center1;
    omada2.EXTEND;
    omada2 (omada2.LAST) := center2;

    -- Diaxorismos me vasi to random kedro se 2 listes:
    WHILE i <= 15
    LOOP
        Select * into temp from CityProject where id = i;
        IF temp.id != center1.id AND temp.id != center2.id THEN
            distance1 := SQRT(POWER((temp.Latitude - center1.Latitude), 2) + POWER((temp.Longitude - center1.Longitude), 2));
            distance2 := SQRT(POWER((temp.Latitude - center2.Latitude), 2) + POWER((temp.Longitude - center2.Longitude), 2));
            --dbms_output.put_line('distance1: '|| distance1);
            --dbms_output.put_line('distance2: '|| distance2);
            --dbms_output.put_line('i: '|| i);
            IF distance1 < distance2 THEN
                omada1.EXTEND;
                omada1 (omada1.LAST) := temp;
            ELSIF distance1 > distance2 THEN
                omada2.EXTEND;
                omada2 (omada2.LAST) := temp;
            END IF;
            
            -- Evresi neou kedrou gia omada 1:
            newLat := 0;
            newLon := 0;
            FOR l_row IN 1 .. omada1.COUNT
                LOOP
                    newLat := newLat + omada1 (l_row).Latitude;
                    newLon := newLon + omada1 (l_row).Longitude;
                END LOOP;
            newLat := newLat / omada1.count;
            newLon := newLon / omada1.count;
            BEGIN
                Select * into center1 from CityProject where Latitude = newLat and Longitude = newLon;
                DBMS_OUTPUT.put_line ('Neo Kedro tis omadas 1: ' || center1.name);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN null;
            END;
            
            -- Evresi neou kedrou gia omada 2:
            newLat := 0;
            newLon := 0;
            FOR l_row IN 1 .. omada2.COUNT
                LOOP
                    newLat := newLat + omada2 (l_row).Latitude;
                    newLon := newLon + omada2 (l_row).Longitude;
                END LOOP;
            newLat := newLat / omada2.count;
            newLon := newLon / omada2.count;
            BEGIN
                Select * into center2 from CityProject where Latitude = newLat and Longitude = newLon;
                DBMS_OUTPUT.put_line ('Neo Kedro tis omadas 2: ' || center2.name);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN null;
            END;
        END IF;
        i:= i + 1;
    END LOOP;

    -- Print tis Lists
    dbms_output.put_line('List 1: ');
    FOR l_row IN 1 .. omada1.COUNT
        LOOP
            DBMS_OUTPUT.put_line (omada1 (l_row).name);
        END LOOP;
    dbms_output.put_line('List 2: ');
    FOR l_row IN 1 .. omada2.COUNT
        LOOP
            DBMS_OUTPUT.put_line (omada2 (l_row).name);
        END LOOP;
        
    --Save se 2 pinakes tis 2 omades:
    DELETE FROM Group1;
    DELETE FROM Group2;
    commit;
     FOR l_row IN 1 .. omada1.COUNT
        LOOP
            INSERT INTO Group1 VALUES (omada1 (l_row).id, omada1 (l_row).name, omada1 (l_row).Latitude,omada1 (l_row).Longitude);
        END LOOP;
     FOR l_row IN 1 .. omada2.COUNT
        LOOP
            INSERT INTO Group2 VALUES (omada2 (l_row).id, omada2 (l_row).name, omada2 (l_row).Latitude,omada2 (l_row).Longitude);
        END LOOP;
 END;
 END GroupingProcedure;