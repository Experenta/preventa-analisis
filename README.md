# Base de datos
## NUGO Preventa
#### Movil


Podriamos empezar a describir la base de en el estado en el que esta ahora, pero primero es importante empezar a describir las consultas que se estan haciendo hacia Salesforce para obtener los objetos y los datos que necesitamos.


### Consultas

##### Avance del dia
Aqui asumimos que userId es el id del usuario que estamos sincronizando y que esta autenticado actualmente en la aplicacion movil.

Esta consulta se hace hacia el endpoint /services/data/v50.0/queryAll 
endonde el query se pasa como urlparams.
```sql
SELECT 
    id,
    id,
    name,
    Inicio_de_dia__c,
    Device_Id__c,
    Fin_de_dia__c,
    Fecha__c,
    Modulo__c,
    Modulo__r.Fuerza_de_venta__r.Portafolio_de_Productos__c,
    Pais__c,
    Compania__c,
    Sucursal__c
FROM Avance_del_dia__c
WHERE Fecha__c = CURRENT_DATE
                AND (OwnerId = :userId OR Vendedor_volante__c = :userId);
```
###### Productos
Una vez ya tenemos los avances del dia, podemos hacer la consulta para obtener los productos que se van a vender en ese dia ya que esta nos devuelve la lista del portafolio de productos disponibles para ese avance del dia.

```sql
SELECT 
    id,
    Producto__c,
    Producto__r.SKU__c,
    Producto__r.name,
    Venta_por_unidades__c,
    Producto__r.Categoria__c,
    Producto__r.Marca__c,
    Producto__r.Formato__c,
    Producto__r.Categoria__r.name,
    Producto__r.Marca__r.name,
    Producto__r.Formato__r.name,
    Producto__r.de_IVA__c,
    Producto__r.de_IVA_Percibido__c,
    Producto__r.Unidades_Por_Paquete__c,
    Producto__r.Peso__c
FROM Producto_de_Portafolio__c
WHERE Portafolio_de_Productos__c = :portafolioProductosId
```


###### Clientes

Esta consulta nos devuelve absolutamente todos los clientes que estan asignados a este modulo, con el proposito de en caso que de que haga una visita a un cliente que no estaba asignado a la lista de visitas , esten disponibles para poder crear una visita a demanda.


ModuloId lo sacamos de la consulta anterior de avance del dia.
```sql

SELECT 
    id,
    name,
    cliente__r.id,
    cliente__r.name,
    cliente__r.Latitud__c,
    cliente__r.Longitud__c,
    cliente__r.Lista_de_precios__c,
    cliente__r.Codigo_Cliente__c,
    cliente__r.Status__c,
    cliente__r.Marcas_sin_comprar__c,
    cliente__r.Eje_Potencial__c,
    cliente__r.NG_4_Id__c,
    cliente__r.Subgiro__c,
    cliente__r.Calle_de_facturacion__c
FROM Asignacion_de_modulo__c 
WHERE Modulo__c = :moduloId

```


###### Visitas
Esta consulta nos devuelve todas las visitas que se han asignado al avance del dia de este vendedor.

La variable avancedelDiaId lo sacamos de la consulta anterior de avance del dia.
```sql
SELECT 
    id,
    name,
    cliente__r.id,
    cliente__r.name,
    cliente__r.Latitud__c,
    cliente__r.Longitud__c,
    cliente__r.Lista_de_precios__c,
    cliente__r.Codigo_Cliente__c,
    cliente__r.Status__c,
    cliente__r.Marcas_sin_comprar__c,
    cliente__r.Eje_Potencial__c,
    cliente__r.NG_4_Id__c,
    cliente__r.Subgiro__c,
    cliente__r.Calle_de_facturacion__c,
    Check_In__c,
    Check_Out__c,
    Secuencia__c,
    Avance_del_dia__r.Modulo__r.Fuerza_de_venta__r.Portafolio_de_Productos__c
FROM Visita__c 
WHERE Avance_del_dia__c = :avanceDelDiaId

```
La respuesta de esta consulta contiene tambien informacion de los clientes. Por lo tanto dentro de la aplicacion ya que anteriormente hemos obtenido la lista de los clientes, simplemente relacionamos los datos de esta consulta con los clientes que ya estan actualmente en la base de datos de la aplicacion.

Y en el caso de que no exista el cliente que viene dentro de esta consulta(la cual parece ser imposible), va a crear un nuevo registro en la tabla de clientes con la informacion que contiene esta consulta.



###### Lista de precios

Cada cliente tiene una lista de precios que se le asigna. Puede o no puede ser diferente para cada cliente. Hay una logica anterior para cada cliente que debemos de seguir para construir la consulta.

Este es el pseudocodigo que debemos de seguir para construir la consulta:

```dart
List<String> listaDePrecios = [];
for (cliente in clientes) {
    if(cliente.listaDePrecios in listaDePrecios){
        continue;
    }
    listaDePrecios.add(cliente.listaDePrecios);
}
```
Por lo que al final tenemos una lista de listas de precios que los clientes tienen asignado, en las que no se repiten la misma lista de precios en caso de que exista varios clientes con la misma lista de precios.

Ahora que tenemos la lista de listas de precios, podemos hacer la consulta para obtener los precios que se van a vender en ese dia.

Ejemplo de la consulta:

```sql
SELECT 
    id,
    name,
    Producto__c,
    CurrencyIsoCode,
    Precio_Botella__c,
    Precio_Paquete__c,
    Lista_de_precios__c
FROM Entrada_lista_de_precios__c 
WHERE Lista_de_precios__c IN (
    'a0J5g000000XZaKEAW',
    'a0J5g000000XZaLEAW',
    'a0J5g000000XZaMEAW',
    'a0J5g000000XZaNEAW'
)
    AND Fecha_inicio__c <= TODAY 
    AND (Fecha_fin__c >= TODAY OR Fecha_fin__c = null)
```

Esta consulta nos devuelve precios para los productos que ya estan guardados, asi que nosotros simplemente hacemos la relacion entre estos precios y los productos que ya se encuentran en la base de datos.




### Estructura de la base de datos local.

> ⚠️ **Nota importante sobre la base de datos local**
>
>  La base de datos local es la base de datos que se encuentra en el dispositivo del vendedor. Ademas , ya que seguimos en etapa de desarollo, esta sujeta a cambios y se encuentra incompleta.

>Tambien hay que tomar en cuenta que este SQL siguiente es para sqlite, por lo que no se puede usar en la base de datos de Salesforce, y puede ser incompatible con otros motores de base de datos.

```sql

-- CreateTable
CREATE TABLE "Modulo" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fuerzaVentaId" TEXT NOT NULL,
    CONSTRAINT "Modulo_fuerzaVentaId_fkey" FOREIGN KEY ("fuerzaVentaId") REFERENCES "FuerzaDeVenta" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "AvanceDelDia" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "inicioDia" DATETIME NOT NULL,
    "deviceId" TEXT NOT NULL,
    "finDia" DATETIME,
    "fecha" DATETIME NOT NULL,
    "pais" TEXT NOT NULL,
    "compania" TEXT NOT NULL,
    "sucursal" TEXT NOT NULL,
    "moduloId" TEXT NOT NULL,
    CONSTRAINT "AvanceDelDia_moduloId_fkey" FOREIGN KEY ("moduloId") REFERENCES "Modulo" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "FuerzaDeVenta" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "portafolioProductos" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "ProductoPrecio" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "Name" TEXT NOT NULL,
    "Precio_Botella__c" REAL NOT NULL,
    "Precio_Paquete__c" REAL NOT NULL,
    "CurrencyIsoCode" TEXT NOT NULL,
    "Lista_de_precios__c" TEXT NOT NULL,
    "Producto__c" TEXT NOT NULL,
    CONSTRAINT "ProductoPrecio_Producto__c_fkey" FOREIGN KEY ("Producto__c") REFERENCES "ProductoPortafolio" ("productoId") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "ProductoPortafolio" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "productoId" TEXT NOT NULL,
    "SKU__c" TEXT NOT NULL,
    "Name" TEXT NOT NULL,
    "Categoria__c" TEXT NOT NULL,
    "Marca__c" TEXT NOT NULL,
    "Formato__c" TEXT NOT NULL,
    "de_IVA__c" REAL NOT NULL,
    "de_IVA_Percibido__c" REAL NOT NULL,
    "Unidades_Por_Paquete__c" REAL NOT NULL,
    "Peso__c" REAL NOT NULL,
    "Venta_por_unidades__c" BOOLEAN NOT NULL,
    CONSTRAINT "ProductoPortafolio_Categoria__c_fkey" FOREIGN KEY ("Categoria__c") REFERENCES "ProductoCategoria" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductoPortafolio_Marca__c_fkey" FOREIGN KEY ("Marca__c") REFERENCES "ProductoMarca" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductoPortafolio_Formato__c_fkey" FOREIGN KEY ("Formato__c") REFERENCES "ProductoFormato" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "ProductoCategoria" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "Name" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "ProductoMarca" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "Name" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "ProductoFormato" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "Name" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "Visita" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "checkIn" DATETIME,
    "checkOut" DATETIME,
    "secuencia" REAL NOT NULL,
    "avanceDelDiaId" TEXT NOT NULL,
    "clienteId" TEXT NOT NULL,
    CONSTRAINT "Visita_avanceDelDiaId_fkey" FOREIGN KEY ("avanceDelDiaId") REFERENCES "AvanceDelDia" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Visita_clienteId_fkey" FOREIGN KEY ("clienteId") REFERENCES "Cliente" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Cliente" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "latitud" TEXT,
    "longitud" TEXT,
    "listaDePrecios" TEXT,
    "codigoCliente" TEXT,
    "status" TEXT,
    "marcasSinComprar" TEXT,
    "ejePotencial" TEXT,
    "ng4Id" TEXT,
    "subgiro" TEXT,
    "calleFacturacion" TEXT
);

-- CreateIndex
CREATE UNIQUE INDEX "Modulo_fuerzaVentaId_key" ON "Modulo"("fuerzaVentaId");

-- CreateIndex
CREATE UNIQUE INDEX "AvanceDelDia_fecha_key" ON "AvanceDelDia"("fecha");

-- CreateIndex
CREATE UNIQUE INDEX "ProductoPortafolio_productoId_key" ON "ProductoPortafolio"("productoId");

-- CreateIndex
CREATE UNIQUE INDEX "ProductoCategoria_Name_key" ON "ProductoCategoria"("Name");

-- CreateIndex
CREATE UNIQUE INDEX "ProductoMarca_Name_key" ON "ProductoMarca"("Name");

-- CreateIndex
CREATE UNIQUE INDEX "ProductoFormato_Name_key" ON "ProductoFormato"("Name");

-- CreateIndex
CREATE UNIQUE INDEX "Cliente_codigoCliente_key" ON "Cliente"("codigoCliente");

```


En este repositorio se encuentra un archivo para mysql workbench en el cual pueden ver la estructura de la base de datos local y diagrama de entidades.