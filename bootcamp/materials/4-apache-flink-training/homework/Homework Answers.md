- Answer these questions
---
- What is the average number of web events of a session from a user on Tech Creator?

    This sql query return the average number of web events on hosts ending with techcreator.io per session window.

    ```sql
        select
            host,
            avg(num_web_events) as avg_web_events
        from
            processed_events_session_aggregated
        where
            host like '%.techcreator.io'
        group by host
        order by host
    ```


- Compare results between different hosts (zachwilson.techcreator.io, zachwilson.tech, lulu.techcreator.io)

    This sql statement identifies hosts mentioned in the question and provides average number of web events for comparison.
    ```sql
    select
        host,
        avg(num_web_events) as avg_web_events
    from
        processed_events_session_aggregated
    where
        host in ('zachwilson.techcreator.io', 'admin.zachwilson.tech', 'lulu.techcreator.io')
    group by host
    order by host
    ```