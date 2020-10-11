DROP SCHEMA IF EXISTS anime_airing_reminder CASCADE;
CREATE SCHEMA IF NOT EXISTS anime_airing_reminder;
DROP TABLE IF EXISTS anime_airing_reminder.token CASCADE;
CREATE TABLE IF NOT EXISTS anime_airing_reminder.token
(
    uid           SERIAL       NOT NULL,
    token_string  VARCHAR(255) NOT NULL,
    validity_date TIMESTAMPTZ,
    is_used       BOOLEAN      NOT NULL DEFAULT FALSE,
    use_date      TIMESTAMPTZ,
    creation_date TIMESTAMPTZ  NOT NULL DEFAULT now(),
    created_by    VARCHAR(8)   NOT NULL,
    update_date   TIMESTAMPTZ,
    updated_by    VARCHAR(8)

);
-- create
DROP TABLE IF EXISTS anime_airing_reminder.user CASCADE;
CREATE TABLE IF NOT EXISTS anime_airing_reminder.user
(
    uid               SERIAL       NOT NULL,
    username          VARCHAR(30)  NOT NULL,
    email             VARCHAR(50)  NOT NULL,
    password          VARCHAR(255) NOT NULL,
    token_uid         INTEGER      NOT NULL,
    is_admin          BOOLEAN      NOT NULL DEFAULT FALSE,
    unique_identifier VARCHAR(8),
    creation_date     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    created_by        VARCHAR(8)   NOT NULL,
    update_date       TIMESTAMPTZ,
    updated_by        VARCHAR(8)
);
DROP TABLE IF EXISTS anime_airing_reminder.source CASCADE;
CREATE TABLE IF NOT EXISTS anime_airing_reminder.source
(
    uid           SERIAL      NOT NULL,
    name          VARCHAR(50) NOT NULL,
    website       TEXT,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by    VARCHAR(8)  NOT NULL,
    update_date   TIMESTAMPTZ,
    updated_by    VARCHAR(8)
);
DROP TABLE IF EXISTS anime_airing_reminder.reminder CASCADE;
CREATE TABLE IF NOT EXISTS anime_airing_reminder.reminder
(
    uid             SERIAL      NOT NULL,
    title           TEXT        NOT NULL,
    airing_datetime TIMESTAMPTZ NOT NULL,
    source_uid      INTEGER     NOT NULL,
    nbr_of_episode  INTEGER     NOT NULL DEFAULT 12,
    creation_date   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by      VARCHAR(8)  NOT NULL,
    update_date     TIMESTAMPTZ,
    updated_by      VARCHAR(8)
);
DROP TABLE IF EXISTS anime_airing_reminder.user_reminder;
CREATE TABLE IF NOT EXISTS anime_airing_reminder.user_reminder
(
    user_uid      INTEGER     NOT NULL,
    reminder_uid  INTEGER     NOT NULL,
    creation_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by    VARCHAR(8)  NOT NULL
);
-- TRIGGER --
CREATE OR REPLACE FUNCTION anime_airing_reminder.check_value_created_by() RETURNS TRIGGER AS
$$
DECLARE
    user_exist BOOLEAN;
BEGIN
    IF (new.created_by != 'SYS') THEN
        SELECT exists(SELECT * FROM anime_airing_reminder.user WHERE unique_identifier = new.created_by)
        INTO user_exist;
        IF (NOT user_exist) THEN
            RAISE EXCEPTION 'unique identifier % for column created_by in table %.% is not allowed',new.created_by,tg_table_schema,tg_table_name;
        END IF;
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION anime_airing_reminder.check_value_updated_by() RETURNS TRIGGER AS
$$
DECLARE
    user_exist BOOLEAN;
BEGIN
    IF (new.updated_by != 'SYS') THEN
        SELECT exists(SELECT * FROM anime_airing_reminder.user WHERE unique_identifier = new.updated_by)
        INTO user_exist;
        IF (NOT user_exist) THEN
            RAISE EXCEPTION 'unique identifier % for column created_by in table %.% is not allowed',new.updated_by,tg_table_schema,tg_table_name;
        END IF;
    END IF;
    RETURN new;
END
$$ LANGUAGE plpgsql;
CREATE TRIGGER token_created_by
    BEFORE INSERT
    ON anime_airing_reminder.token
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_created_by();
CREATE TRIGGER token_updated_by
    BEFORE UPDATE
    ON anime_airing_reminder.token
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_updated_by();
CREATE TRIGGER user_created_by
    BEFORE INSERT
    ON anime_airing_reminder.user
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_created_by();
CREATE TRIGGER user_updated_by
    BEFORE UPDATE
    ON anime_airing_reminder.user
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_updated_by();
CREATE TRIGGER source_created_by
    BEFORE INSERT
    ON anime_airing_reminder.source
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_created_by();
CREATE TRIGGER source_updated_by
    BEFORE UPDATE
    ON anime_airing_reminder.source
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_updated_by();
CREATE TRIGGER reminder_created_by
    BEFORE INSERT
    ON anime_airing_reminder.reminder
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_created_by();
CREATE TRIGGER reminder_updated_by
    BEFORE UPDATE
    ON anime_airing_reminder.reminder
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_updated_by();
CREATE TRIGGER user_reminder_created_by
    BEFORE INSERT
    ON anime_airing_reminder.user_reminder
    FOR EACH ROW
EXECUTE PROCEDURE anime_airing_reminder.check_value_created_by();