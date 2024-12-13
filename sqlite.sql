
visitas {
	id text pk
	name text null
	check_in text null
	check_out text null
	secuencia integer null
	estado text null
	cliente_id text null
	cliente_name text null
	cliente_codigo text null
	cliente_estado text null
	cliente_lista_precios_id text null
	cliente_latitud real null
	cliente_longitud real null
	cliente_nota_comercial text null
	cliente_eje_clasificacion_id text null
	cliente_eje_potencial_id text null
	cliente_eje_territorial_id text null
	cliente_domicilio text null
}

productos {
	porciento_iva real null
	id text pk
	nombre text null
	codigo text null
	categoria text null
	marca text null
	formato text null
	peso real null
	venta_por_paquetes integer null
	venta_por_unidades integer null
	unidades_por_paquete real null
	iva_percibido real null
}

listas_precio {
	id text pk
	producto_id text null > productos.id
	lista_precio_id text null
	precio_paquete real null
	precio_unidad real null
}

promociones {
	id text pk
	nombre text null
	acciones_texto text null
	condiciones_texto text null
	agrupador text null
	folio text null
}

promociones_condiciones {
	id text pk
	promocion_id text null > promociones.id
	tipo text null
	valor real null
	operador text null
}

promociones_condiciones_productos {
	condicion_id text pk null > promociones_condiciones.id
	producto_id text null > productos.id
	promocion_id text null > promociones.id
}

promociones_clientes {
	promocion_id text pk null > promociones.id
	cliente_id text null
}

promociones_acciones {
	id text pk
	promocion_id text null > promociones.id
	cantidad real null
	es_total integer null
	unidad_medida text null
	tipo text null
}

promociones_acciones_productos {
	accion_id text pk null > promociones_acciones.id
	producto_id text null > productos.id
}

sugeridos {
	id text
}

