- Answer these questions
---
- What is the average number of web events of a session from a user on Tech Creator?

    This sql query return the average number of web events by a user on tech creator per session window. Currently it is 3.22 ~= 3 events.

    ```sql
    select
        avg(num_web_events) as avg_web_events
    from
        processed_events_session_aggregated
    where
        host like '%.techcreator.io';
    ```


- Compare results between different hosts (zachwilson.techcreator.io, zachwilson.tech, lulu.techcreator.io)

    This sql statement identifies hosts mentioned in the question and provides average number of web events for comparison.
    Current comparison is as follows:
    | host | average_web_events |
    | ---- | ----- |
    | admin.zachwilson.tech | 1.50 |
    | lulu.techcreator.io | 2.58 |
    | zachwilson.techcreator.io | 3.09 |

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