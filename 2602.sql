**Schema (MySQL v9)**

    CREATE TABLE customers (
      id NUMERIC PRIMARY KEY,
      name CHARACTER VARYING(255),
      street CHARACTER VARYING(255),
      city CHARACTER VARYING(255),
      state CHAR(2),
      credit_limit NUMERIC
    );
    
    INSERT INTO customers (id, name, street, city, state, credit_limit)
    VALUES
      (1, 'Pedro Augusto da Rocha', 'Rua Pedro Carlos Hoffman', 'Porto Alegre', 'RS', 700.00),
      (2, 'Antonio Carlos Mamel', 'Av. Pinheiros', 'Belo Horizonte', 'MG', 3500.50),
      (3, 'Luiza Augusta Mhor', 'Rua Salto Grande', 'Niteroi', 'RJ', 4000.00),
      (4, 'Jane Ester', 'Av 7 de setembro', 'Erechim', 'RS', 800.00),
      (5, 'Marcos Antônio dos Santos', 'Av Farrapos', 'Porto Alegre', 'RS', 4250.25);

---

**Query #1**

    SELECT name
    FROM customers
    WHERE state = 'RS';

| name                      |
| ------------------------- |
| Pedro Augusto da Rocha    |
| Jane Ester                |
| Marcos Antônio dos Santos |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/mf42idE1tQe8D2CYDbwvkx/1)
