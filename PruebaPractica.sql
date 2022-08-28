# Sebastian Alfonso Tapia Berenguela - Prueba Practica Ingeniero de Datos - EntreKids.
# 27/08/2022
#La base de datos para esta prueba tendra por nombre 'prueba' y es donde realizare el inserto de tablas en base al modelo.
#Destacar que el modelo lo realize en el en un diagrama EER y luego inserte el script abajo.
CREATE database prueba;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


CREATE SCHEMA IF NOT EXISTS `prueba` DEFAULT CHARACTER SET utf8 ;
USE `prueba` ;

-- -----------------------------------------------------
-- Table `prueba`.`transanccion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`transanccion` (
  `id` INT(11) NOT NULL,
  `total` INT(11) NOT NULL,
  `created` DATETIME NOT NULL,
  `estado` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

/*Aqui me equivoque al nombrar la tabla 'Transaccion' desde el diagrama EER pero la actualice al costado en
en el navegador de las BD y Tablas */

-- -----------------------------------------------------
-- Table `prueba`.`proveedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`proveedor` (
  `id` INT(11) NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `prueba`.`actividad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`actividad` (
  `id` INT NOT NULL,
  `proveedor_id` INT(11) NULL,
  `nombre` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `proveedor_id_idx` (`proveedor_id` ASC) VISIBLE,
  CONSTRAINT `proveedor_id`
    FOREIGN KEY (`proveedor_id`)
    REFERENCES `mydb`.`proveedor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `prueba`.`actividad_evento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`actividad_evento` (
  `id` INT(11) NOT NULL,
  `actividad_id` INT(11) NULL,
  `fecha_inicio` DATETIME NOT NULL,
  `fechar_termino` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `actividad_id_idx` (`actividad_id` ASC) VISIBLE,
  CONSTRAINT `actividad_id`
    FOREIGN KEY (`actividad_id`)
    REFERENCES `mydb`.`actividad` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `prueba`.`item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`item` (
  `id` INT(11) NOT NULL,
  `evento_id` INT(11) NULL,
  `transaccion_id` INT(11) NULL,
  `cantidad` INT(11) NOT NULL,
  `created` DATETIME NOT NULL,
  `updated` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `evento_id_idx` (`evento_id` ASC) VISIBLE,
  INDEX `transaccion_id_idx` (`transaccion_id` ASC) VISIBLE,
  CONSTRAINT `evento_id`
    FOREIGN KEY (`evento_id`)
    REFERENCES `mydb`.`actividad_evento` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `transaccion_id`
    FOREIGN KEY (`transaccion_id`)
    REFERENCES `mydb`.`transanccion` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `prueba`.`paquete`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`paquete` (
  `id` INT(11) NOT NULL,
  `item_id` INT(11) NULL,
  `estado` VARCHAR(255) NOT NULL,
  `created` DATETIME NOT NULL,
  `updated` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `item_id_idx` (`item_id` ASC) VISIBLE,
  CONSTRAINT `item_id`
    FOREIGN KEY (`item_id`)
    REFERENCES `mydb`.`item` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `prueba`.`entrada`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `prueba`.`entrada` (
  `id` INT(11) NOT NULL,
  `codigo` VARCHAR(255) NOT NULL,
  `fecha_acceso` DATETIME NULL,
  `created` DATETIME NOT NULL,
  `updated` DATETIME NOT NULL,
  `item_id` INT(11) NULL,
  `estado` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_entrada_item1_idx` (`item_id` ASC) VISIBLE,
  CONSTRAINT `fk_entrada_item1`
    FOREIGN KEY (`item_id`)
    REFERENCES `mydb`.`item` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

# Recree la base de datos modelada

-- -------------------------------------------------------------------------------------------------------

-- RESPUESTAS--

/*
# PREGUNTA 1
Basándose en el modelo de la imagen 1, obtener la venta por proveedor, haciendo 
distinción si es un evento o un producto ordenada por el total vendido en dinero 
de mayor a menor mediante una consulta SQL. */

# Asumí que la tabla 'transiccion' seria la venta y dentro esta tabla el campo 'total' es el total de dinero
# Utilizando Inner joins uní las tablas mediante sus id, para luego mostrar una tabla final el nombre del proveedor
# el total vendido ordenado de mayor a menor. 
# Respecto a incorporar una distinción para ver si es un evento o producto, incorpore los id de ambos ya que no identifique
# cuando es cada uno.

SELECT proveedor.nombre AS 'Proveedor', transaccion.total AS 'Total_Vendido' , 
	   actividad_evento.actividad_id AS 'Evento_id' , item.id AS 'producto_id'

FROM proveedor inner join actividad ON proveedor.id = actividad.proveedor_id 
			   inner join actividad_evento ON actividad.proveedor_id = actividad_evento.actividad_id
               inner join item ON actividad_evento.actividad_id = item.evento_id
               inner join transaccion ON item.transaccion_id = transaccion.id 
               
ORDER BY transaccion.total DESC;               

-- -----------------------------------------------------------------------------------------------------

/*
# PREGUNTA 2
Teniendo en cuenta el modelo anterior, idee un proceso que tenga que ser ejecutado cada cierto 
tiempo (automatización) y que obtenga información “relevante”. La respuesta debe ser de forma de 
descripción/narración. */

/*
Para el proceso se desarrollará un script que asocie las tablas Transacción e Item; este Script sera un Trigger que 
dejara un proceso almacenado, el cual se dispara en el momento en el que la tabla Ítem reciba algún INSERT, DELETE 
o un UPDATE dentro del campo 'cantidad'.
Es decir, la tabla Transacción posee un campo 'total' que viene de la cantidad de Ítems que se encuentren
en la tabla Ítem, si en la tabla Item la cantidad de ítems es modificada, el total de la tabla Transacción
se recalculará  en un nuevo total, de esta forma la tabla estará disponible y actualizada
en caso que se necesite algún reporte y se evitara la necesidad de que alguien deba entrar a modificar datos manuales 
en la tabla Transiccion. Tambien habra un Trigger que guarde las acciones ocurridas en la tabla Item cada vez que se modifique
Para poder llevar a cabo esto con una mayor exactitud e eficiencia y mejor manejo de datos, se necesitaran conocer otros 
datos faltantes como lo es el precio de un item y las veces que fue solicitado en la transaccion.
*/

-- ------------------------------------------------------------------------------------------------------------------

/*
# PREGUNTA 3
Basado en la respuesta anterior con pseudocódigo o código simple escribir la solución a lo planteado. 
Obvie conexiones a la base de datos, inicialización de librerías, etc. */

# Creacion de tabla "registros" donde se almacenara cada accion que se haga en la tabla "item"

CREATE TABLE `prueba`.`registros`(
  `id` INT NOT NULL AUTO_INCREMENT,
  `accion` VARCHAR(45) NULL,
  `fecha` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`));

# Trigger para guardar registros que ocurran en la tabla "item"

DELIMITER //
CREATE TRIGGER accionesTrigger AFTER UPDATE ON item
FOR EACH ROW BEGIN
	INSERT INTO registros (accion) VALUE (' HA OCURRIDO UN REGISTRO ' );
END //
DELIMITER ;
/*    
Para llevar acabo el Trigger completo, se necesitan valores como la cantidad por el precio unitario
para poder conseguir el valor y reemplarlo en la tabla transiccion. Una opcion podria haber sido alterar las tablas 
para de estar forma poder agregar los campos necesarios a transiccion e item, pero como no si eso esta permitido, trabajare 
con los datos presentes e intentare realizer los mas cercano al trigger
*/
DELIMITER //
CREATE TRIGGER calculo AFTER UPDATE ON item
FOR EACH ROW BEGIN
DECLARE stock int;	
SET stock = (SELECT cantidad FROM item WHERE NEW.transaccion_id = transaccion.id);
UPDATE transaccion SET total = (SELECT SUM(cantidad) FROM item WHERE item.transaccion_id = transaccion.id);
END //
DELIMITER ;
