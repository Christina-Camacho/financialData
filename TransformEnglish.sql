RENAME TABLE `order` TO `orders`;
DROP TABLE `order`;
ALTER TABLE district
CHANGE COLUMN `A2` `district name` VARCHAR(255),
CHANGE COLUMN `A3` `region` VARCHAR(255),
CHANGE COLUMN `A4` `noOfInhabitants` INT,
CHANGE COLUMN `A5` `<499` INT,
CHANGE COLUMN `A6` `500-1999` INT,
CHANGE COLUMN `A7` `2000-9999` INT,
CHANGE COLUMN `A8` `>10000` INT,
CHANGE COLUMN `A9` `noOfCities` INT,
CHANGE COLUMN `A10` `ratioInhabitants` INT,
CHANGE COLUMN `A11` `avgSalary` INT,
CHANGE COLUMN `A12` `unemploymentRate95` INT,
CHANGE COLUMN `A13` `unemploymentRate96` INT,
CHANGE COLUMN `A14` `noEnterpreneursPer1000` INT,
CHANGE COLUMN `A15` `noOfCrime95` INT,
CHANGE COLUMN `A16` `noOfCrime96` INT;

ALTER TABLE loan
CHANGE COLUMN `status` `loanStatus` VARCHAR(2);
;


ALTER TABLE trans MODIFY type VARCHAR(50);
ALTER TABLE trans MODIFY operation VARCHAR(50);
ALTER TABLE trans MODIFY k_symbol VARCHAR(50);
ALTER TABLE account MODIFY frequency VARCHAR(50);
ALTER TABLE disp MODIFY type VARCHAR(50);
ALTER TABLE orders MODIFY k_symbol VARCHAR(50);



UPDATE trans
    SET type = CASE
        WHEN type = 'PRIJEM' THEN 'credit'
        WHEN type = 'VYDAJ' THEN 'withdrawal'
        WHEN type = 'VYBER' THEN 'withdrawal'
    END
    WHERE type IN ('PRIJEM', 'VYDAJ', 'VYBER');
  
UPDATE trans
    SET operation = CASE
        WHEN operation = 'VKLAD' THEN 'deposit'
        WHEN operation = 'PREVOD Z UCTU' THEN 'Transfer_from_account'
        WHEN operation = 'PREVOD NA UCET' THEN 'Transfer_to_account'
        WHEN operation = 'VYBER' THEN 'cash_withdrawal'
        WHEN operation = 'VYBER KARTOU' THEN 'credit_card_withdrawal'
    END
    WHERE operation IN ('VKLAD', 'PREVOD Z UCTU', 'PREVOD NA UCET', 'VYBER', 'VYBER KARTOU');

UPDATE trans
SET k_symbol = CASE
    WHEN k_symbol = 'SIPO' THEN 'bills'
    WHEN k_symbol = 'UVER' THEN 'loans'
    WHEN k_symbol = 'POJISTNE' THEN 'insurance'
    WHEN k_symbol = 'LEASING' THEN 'leasing'
    WHEN k_symbol = 'SLUZBY' THEN 'internal_services'
    WHEN k_symbol = 'DUCHOD' THEN 'pension'
    WHEN k_symbol = 'UROK' THEN 'interest_credited'
    WHEN k_symbol = 'SANKC. UROK' THEN 'penalty_interest'
    ELSE k_symbol
END;

UPDATE account
    SET frequency = CASE
        WHEN frequency = 'POPLATEK MESICNE' THEN 'monthly_issuance'
        WHEN frequency = 'POPLATEK TYDNE' THEN 'weekly_issuance'
        WHEN frequency = 'POPLATEK PO OBRATU' THEN 'issuance_after_transaction'
    END
    WHERE frequency IN ('POPLATEK MESICNE', 'POPLATEK TYDNE', 'POPLATEK PO OBRATU');
  
UPDATE disp
    SET type = CASE
        WHEN type = 'DISPONENT' THEN 'AUTHORIZED_PERSON'
        WHEN type = 'OWNER' THEN 'OWNER'
    END;

UPDATE orders
SET k_symbol = CASE
    WHEN k_symbol = 'SIPO' THEN 'bill_payment'
    WHEN k_symbol = 'UVER' THEN 'loan'
    WHEN k_symbol = 'POJISTNE' THEN 'insurance'
    when k_symbol = 'LEASING' THEN 'leasing'
END;