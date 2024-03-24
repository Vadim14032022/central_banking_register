# Физическая модель

---

Таблица `members`:

| Название        | Описание           | Тип данных     | Ограничение   |
|-----------------|--------------------|----------------|---------------|
| `memid`         | Идентификатор      | `INTEGER`      | `PRIMARY KEY` |
| `surname`       | Фамилия клиента    | `VARCHAR(200)` | `NOT NULL`    |
| `firstname`     | Имя клиента        | `VARCHAR(200)` | `NOT NULL`    |
| `address`       | Адрес клиента      | `VARCHAR(300)` | `NOT NULL`    |
| `zipcode`       | Почтовый индекс    | `INTEGER`      | `NOT NULL`    |
| `telephone`     | Номер телефона     | `VARCHAR(20)`  | `NOT NULL`    |
| `recommendedby` | Кем рекомендован   | `INTEGER`      | `FOREIGN KEY` |
| `joindate`      | Дата присоединения | `TIMESTAMP`    | `NOT NULL`    |

Таблица `facilities`:

| Название             | Описание                                         | Тип данных     | Ограничение   |
|----------------------|--------------------------------------------------|----------------|---------------|
| `facid`              | Идентификатор                                    | `INTEGER`      | `PRIMARY KEY` |
| `name`               | Имя                                              | `VARCHAR(100)` | `NOT NULL`    |
| `membercost`         | Стоимость бронирования для членов                | `NUMERIC`      | `NOT NULL`    |
| `guestcost`          | Стоимость бронирования для гостей                | `NUMERIC`      | `NOT NULL`    |
| `initialoutlay`      | Первоначальная стоимость строительства           | `NUMERIC`      | `NOT NULL`    |
| `monthlymaintenance` | Предполагаемые ежемесячные расходы на содержание | `NUMERIC`      | `NOT NULL`    |

Таблица `bookings`:

| Название    | Описание                        | Тип данных  | Ограничение   |
|-------------|---------------------------------|-------------|---------------|
| `bookid`    | Идентификатор брони             | `INTEGER`   | `PRIMARY KEY` |
| `facid`     | Идентификатор объекта           | `INTEGER`   | `FOREIGN KEY` |
| `memid`     | Идентификатор члена             | `INTEGER`   | `FOREIGN KEY` |
| `starttime` | Начало брони                    | `TIMESTAMP` | `NOT NULL`    |
| `slots`     | количество получасовых «слотов» | `INTEGER`   | `NOT NULL`    |

---
Таблица `members`:
```postgresql
CREATE TABLE cd.members(
   memid          INTEGER                NOT NULL,
   surname        CHARACTER VARYING(200) NOT NULL,
   firstname      CHARACTER VARYING(200) NOT NULL,
   address        CHARACTER VARYING(300) NOT NULL,
   zipcode        INTEGER                NOT NULL,
   telephone      CHARACTER VARYING(20)  NOT NULL,
   recommendedby  INTEGER,
   joindate       TIMESTAMP              NOT NULL,

   CONSTRAINT members_pk PRIMARY KEY (memid),

   CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
       REFERENCES cd.members(memid) ON DELETE SET NULL
);
```
Таблица `facilities`:
```postgresql
CREATE TABLE cd.facilities(
   facid               INTEGER                NOT NULL, 
   name                CHARACTER VARYING(100) NOT NULL, 
   membercost          NUMERIC                NOT NULL, 
   guestcost           NUMERIC                NOT NULL, 
   initialoutlay       NUMERIC                NOT NULL, 
   monthlymaintenance  NUMERIC                NOT NULL, 
   
   CONSTRAINT facilities_pk PRIMARY KEY (facid)
);
```
Таблица `bookings`:
```postgresql
CREATE TABLE cd.bookings(
   bookid     INTEGER   NOT NULL, 
   facid      INTEGER   NOT NULL, 
   memid      INTEGER   NOT NULL, 
   starttime  TIMESTAMP NOT NULL,
   slots      INTEGER   NOT NULL,
   
   CONSTRAINT bookings_pk PRIMARY KEY (bookid),
   
   CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
   
   CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);
```
