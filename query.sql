WITH NominaAgg AS (
    SELECT 
        idtrabajador,
        SUM(sbruto) AS sbruto,
        SUM(indemnizacion) AS indemnizacion,
        SUM(anticipos) AS anticipos,
        SUM(seguromedico) AS seguromedico,
        SUM(irpf) AS irpf,
        SUM(liquido) AS liquido,
        SUM(ssempresa) AS ssempresa,
        SUM(seguros) AS seguros,
        SUM(sespecie) AS sespecie,
        SUM(prestamos) AS prestamos,
        SUM(embargos) AS embargos,
        SUM(sstrabajador) AS sstrabajador,
        SUM(costeempresa) AS costeempresa,
        SUM(finiquito) AS finiquito
    FROM tra_nominas
    -- Filtrado en primera CTE para tra_nominas para reducir la cantidad de datos
    WHERE anio = 2024 AND mes = 3
    GROUP BY idtrabajador
),
MaxServicio AS (
    SELECT 
        s.idtrabajador,
        MAX(s.id) AS valor
    FROM tra_servicios s
    -- Check con la tabla de nóminas previa agregación para filtrar por fechas y trabajador (asumiendo que tra_servicios no tiene campos de fecha)
    WHERE EXISTS (SELECT 1 FROM NominaAgg n WHERE n.idtrabajador = s.idtrabajador AND anio = 2024 AND mes = 3)
    GROUP BY idtrabajador
)
SELECT
    n.idtrabajador,
    p.id,
    p.titulo,
    p.cecoproyecto,
    n.sbruto,
    n.indemnizacion,
    n.anticipos,
    n.seguromedico,
    n.irpf,
    n.liquido,
    n.ssempresa,
    n.seguros,
    c.cecocliente,
    n.sespecie,
    n.prestamos,
    n.embargos,
    n.sstrabajador,
    n.costeempresa,
    n.finiquito,
    c.id,
    c.nombre
FROM NominaAgg n
-- Asegurar que los datos obedecen al último servicio (max id en tra_servicios), left cambiado a inner por performance y redundancia (siempre hay un max id)
INNER JOIN tra_servicios s ON n.idtrabajador = s.idtrabajador
INNER JOIN MaxServicio ms ON s.id = ms.valor
INNER JOIN proyectos p ON s.proyecto = p.id
INNER JOIN clientes c ON p.cliente_id = c.id
