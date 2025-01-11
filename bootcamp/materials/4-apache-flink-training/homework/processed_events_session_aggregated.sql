-- This DDL defined a table where session aggregaed results are stored.

CREATE TABLE processed_events_session_aggregated (
            event_time TIMESTAMP(3),
            ip VARCHAR,
            host VARCHAR,
            num_web_events BIGINT
        );
