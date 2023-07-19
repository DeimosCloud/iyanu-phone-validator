#!/bin/bash
set -e

# Connect to postgres database and create user and database for validator
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ${VALIDATOR_USER} WITH PASSWORD '${VALIDATOR_PASSWORD}';
	CREATE DATABASE ${VALIDATOR_DB};
	GRANT ALL PRIVILEGES ON DATABASE ${VALIDATOR_DB} TO ${VALIDATOR_USER};
    GRANT pg_read_all_data TO ${VALIDATOR_USER};
    GRANT pg_write_all_data TO ${VALIDATOR_USER};
EOSQL

# Seed the validator database with data
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$VALIDATOR_DB" <<-EOSQL
    BEGIN TRANSACTION;
    CREATE TABLE customer (id int, name varchar(50), phone varchar(50));
    INSERT INTO customer VALUES(0,'Walid Hammadi','(212) 6007989253');
    INSERT INTO customer VALUES(1,'Yosaf Karrouch','(212) 698054317');
    INSERT INTO customer VALUES(2,'Younes Boutikyad','(212) 6546545369');
    INSERT INTO customer VALUES(3,'Houda Houda','(212) 6617344445');
    INSERT INTO customer VALUES(4,'Chouf Malo','(212) 691933626');
    INSERT INTO customer VALUES(5,'soufiane fritisse ','(212) 633963130');
    INSERT INTO customer VALUES(6,'Nada Sofie','(212) 654642448');
    INSERT INTO customer VALUES(7,'Edunildo Gomes Alberto ','(258) 847651504');
    INSERT INTO customer VALUES(8,'Walla''s Singz Junior','(258) 846565883');
    INSERT INTO customer VALUES(9,'sevilton sylvestre','(258) 849181828');
    INSERT INTO customer VALUES(10,'Tanvi Sachdeva','(258) 84330678235');
    INSERT INTO customer VALUES(11,'Florencio Samuel','(258) 847602609');
    INSERT INTO customer VALUES(12,'Solo Dolo','(258) 042423566');
    INSERT INTO customer VALUES(13,'Pedro B 173','(258) 823747618');
    INSERT INTO customer VALUES(14,'Ezequiel Fenias','(258) 848826725');
    INSERT INTO customer VALUES(15,'JACKSON NELLY','(256) 775069443');
    INSERT INTO customer VALUES(16,'Kiwanuka Budallah','(256) 7503O6263');
    INSERT INTO customer VALUES(17,'VINEET SETH','(256) 704244430');
    INSERT INTO customer VALUES(18,'Jokkene Richard','(256) 7734127498');
    INSERT INTO customer VALUES(19,'Ogwal David','(256) 7771031454');
    INSERT INTO customer VALUES(20,'pt shop 0901 Ultimo ','(256) 3142345678');
    INSERT INTO customer VALUES(21,'Daniel Makori','(256) 714660221');
    INSERT INTO customer VALUES(22,'shop23 sales','(251) 9773199405');
    INSERT INTO customer VALUES(23,'Filimon Embaye','(251) 914701723');
    INSERT INTO customer VALUES(24,'ABRAHAM NEGASH','(251) 911203317');
    INSERT INTO customer VALUES(25,'ZEKARIAS KEBEDE','(251) 9119454961');
    INSERT INTO customer VALUES(26,'EPHREM KINFE','(251) 914148181');
    INSERT INTO customer VALUES(27,'Karim Niki','(251) 966002259');
    INSERT INTO customer VALUES(28,'Frehiwot Teka','(251) 988200000');
    INSERT INTO customer VALUES(29,'Fanetahune Abaia','(251) 924418461');
    INSERT INTO customer VALUES(30,'Yonatan Tekelay','(251) 911168450');
    INSERT INTO customer VALUES(31,'EMILE CHRISTIAN KOUKOU DIKANDA HONORE ','(237) 697151594');
    INSERT INTO customer VALUES(32,'MICHAEL MICHAEL','(237) 677046616');
    INSERT INTO customer VALUES(33,'ARREYMANYOR ROLAND TABOT','(237) 6A0311634');
    INSERT INTO customer VALUES(34,'LOUIS PARFAIT OMBES NTSO','(237) 673122155');
    INSERT INTO customer VALUES(35,'JOSEPH FELICIEN NOMO','(237) 695539786');
    INSERT INTO customer VALUES(36,'SUGAR STARRK BARRAGAN','(237) 6780009592');
    INSERT INTO customer VALUES(37,'WILLIAM KEMFANG','(237) 6622284920');
    INSERT INTO customer VALUES(38,'THOMAS WILFRIED LOMO LOMO','(237) 696443597');
    INSERT INTO customer VALUES(39,'Dominique mekontchou','(237) 691816558');
    INSERT INTO customer VALUES(40,'Nelson Nelson','(237) 699209115');
    COMMIT;