-- CreateTable
CREATE TABLE "Usuario" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "nombre" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "contrasena" TEXT NOT NULL,
    "estadoSesion" TEXT
);

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
