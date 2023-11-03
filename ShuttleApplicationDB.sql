

CREATE PROCEDURE public.add_passenger(IN p_suid bigint, IN p_street text, IN p_city text, IN p_state text, IN p_zip text, IN p_latitude double precision, IN p_longitude double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert the values into the 'passengers' table
    INSERT INTO passengers (suid, street, city, state, zip, latitude, longitude)
    VALUES (p_suid, p_street, p_city, p_state, p_zip,p_latitude, p_longitude);
END;
$$;


CREATE PROCEDURE public.add_students_to_shuttle()
    LANGUAGE plpgsql
    AS $$
DECLARE
    shuttle_latitude double precision;
    shuttle_longitude double precision;
    campus_bus_stop_longitude  double precision := -76.13133627075227; 
    campus_bus_stop_latitude double precision := 43.03789557301325; 
    num_students_to_take integer := 5; -- Limiting it to 5 passenger per shuttle for now
BEGIN
    -- Get the current shuttle location
    SELECT shuttleLatitude, shuttleLongitude INTO shuttle_latitude, shuttle_longitude
    FROM shuttleLocation
    LIMIT 1;
	
    -- Check if the shuttle is at the campus bus stop location
    IF shuttle_latitude = campus_bus_stop_latitude AND shuttle_longitude = campus_bus_stop_longitude THEN
	
        -- Take students from passengers table and add them to passengers_on_shuttle table
        INSERT INTO passengers_on_shuttle (suid, latitude, longitude)
        SELECT suid, latitude, longitude
        FROM passengers where suid NOT IN (select suid from passengers_on_shuttle)
        LIMIT num_students_to_take ;

        -- Remove the taken students from the passengers table
        DELETE FROM passengers
        WHERE suid IN (SELECT suid FROM passengers_on_shuttle);
    END IF;
END;
$$;


CREATE FUNCTION public.check_add_passenger(p_suid bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
BEGIN
   
    RETURN EXISTS (
        SELECT 1
        FROM passengers
        WHERE suid = $1
    );
END;
$_$;



CREATE FUNCTION public.get_all_passengers_on_shuttle() RETURNS SETOF point
    LANGUAGE plpgsql
    AS $$
DECLARE
    passenger_location point;
BEGIN
    FOR passenger_location IN (SELECT point(longitude, latitude) FROM passengers_on_shuttle) LOOP
        RETURN NEXT passenger_location;
    END LOOP;
    RETURN;
END;
$$;



CREATE FUNCTION public.get_all_passengers_onn_shuttle() RETURNS TABLE(longitude double precision, latitude double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.longitude, p.latitude FROM passengers_on_shuttle p;
END;
$$;



CREATE FUNCTION public.get_shuttle_location() RETURNS TABLE(longitude double precision, latitude double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT shuttleLongitude, shuttleLatitude
    FROM shuttleLocation
    LIMIT 1;
END;
$$;



CREATE FUNCTION public.get_shuttle_passenger_details() RETURNS TABLE(suid bigint, longitude double precision, latitude double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.suid, p.longitude, p.latitude FROM passengers_on_shuttle p;
END;
$$;



CREATE FUNCTION public.get_top_shuttle_passenger_details() RETURNS TABLE(suid bigint, longitude double precision, latitude double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT p.suid, p.longitude, p.latitude FROM passengers_on_shuttle p LIMIT 1;
END;
$$;



CREATE FUNCTION public.is_valid_suid(p_suid bigint) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_suid bigint;
BEGIN
    SELECT SUID INTO v_suid FROM student WHERE SUID = p_suid;
    
    IF v_suid IS NOT NULL THEN
        RETURN true;
    ELSE
        RETURN false;
    END IF;
END;
$$;



CREATE PROCEDURE public.remove_students_from_shuttle(IN p_suid bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Get the current shuttle location
    DELETE FROM public.passengers_on_shuttle
    WHERE suid = p_suid;
	
END;
$$;



CREATE PROCEDURE public.update_shuttle_location(IN p_latitude double precision, IN p_longitude double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN

	raise notice '%d %d',p_latitude, p_longitude;
    -- Check if a record exists in the shuttleLocation table
    IF EXISTS (SELECT 1 FROM shuttleLocation) THEN
        -- Update the existing record
        UPDATE shuttleLocation
        SET
		    shuttleLongitude = p_longitude,
            shuttleLatitude = p_latitude,
            updateTime = NOW(); -- You can use the current timestamp
    ELSE
        -- Insert a new record
        INSERT INTO shuttleLocation (shuttleLatitude, shuttleLongitude, updateTime)
        VALUES (p_latitude, p_longitude, NOW()); -- You can use the current timestamp
    END IF;
END;
$$;



CREATE TABLE public.passengers (
    suid bigint NOT NULL,
    street text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    zip text NOT NULL,
    latitude double precision,
    longitude double precision
);


CREATE TABLE public.passengers_on_shuttle (
    suid bigint NOT NULL,
    latitude double precision,
    longitude double precision
);


CREATE TABLE public.shuttlelocation (
    shuttlelatitude double precision NOT NULL,
    shuttlelongitude double precision NOT NULL,
    updatetime timestamp with time zone NOT NULL
);



CREATE TABLE public.student (
    suid bigint NOT NULL
);




INSERT INTO student (suid) VALUES (123450);
INSERT INTO student (suid) VALUES (123451);
INSERT INTO student (suid) VALUES (123452);
INSERT INTO student (suid) VALUES (123453);
INSERT INTO student (suid) VALUES (123454);
INSERT INTO student (suid) VALUES (123455);
INSERT INTO student (suid) VALUES (123456);
INSERT INTO student (suid) VALUES (123457);
INSERT INTO student (suid) VALUES (123458);
INSERT INTO student (suid) VALUES (123459);

