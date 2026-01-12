# Proyecto: Análisis de Flujo en Arterias

## Descripción

Versión optimizada y modular del análisis completo de flujo sanguíneo en arterias femorales, incluyendo:
- Cálculo de resistencias hidráulicas (Poiseuille)
- Análisis de velocidades en arterias sanas y con trombosis
- Determinación de regímenes de flujo (Reynolds)
- Evaluación de riesgo de aneurisma (WSS, shear rate, tensión de pared)
- Predicción de riesgo de infarto (Venturi vs Resistencia)

---

## 🚀 Uso Rápido

1. **Abrir** `configuracion_parametros.m`
2. **Modificar** los valores deseados
3. **Ejecutar** `main_analisis_arterial.m`
4. **Revisar** resultados en Command Window y figuras

---

## 📁 Estructura del Proyecto

```
ejercicio_fisica/
├── main_analisis_arterial.m          ← EJECUTAR AQUÍ
├── configuracion_parametros.m        ← MODIFICAR PARÁMETROS AQUÍ
├── funciones/
│   ├── analisis_wss_shear.m
│   ├── analisis_venturi_resistencia.m
│   ├── analisis_parametrico.m
│   ├── analisis_adimensional.m       ← NUEVO (Re, Eu, Wo, De)
│   └── analisis_sensibilidad.m       ← NUEVO (Tornado, superficies)
├── visualizacion/
│   ├── graficar_velocidades.m        (Mejorado: 3D, gradientes)
│   ├── graficar_reynolds.m           (Mejorado: Moody, zonas)
│   ├── graficar_resistencias.m       (Mejorado: analogía eléctrica)
│   ├── graficar_riesgo_aneurisma.m   (Mejorado: semáforos)
│   ├── graficar_riesgo_infarto.m     (Mejorado: zonas peligro)
│   └── visualizacion_interactiva_completa.m
├── respaldos/                         ← Versiones anteriores
└── README.md (este archivo)
```

---

## ⚙️ Configuración de Parámetros

Editar `configuracion_parametros.m`:

### Geometría Arterial
```matlab
params.radio_min = 3.45e-3;    % Radio mínimo (m)
params.radio_max = 5.3e-3;     % Radio máximo (m)
params.num_radios = 100;       % Puntos de muestreo
```

### Umbrales de Riesgo
```matlab
params.WSS_bajo = 0.4;         % WSS bajo (Pa) - Riesgo aneurisma
params.WSS_alto = 2.5;         % WSS alto (Pa) - Daño endotelial
params.Re_laminar = 2000;      % Reynolds para flujo laminar
params.Re_turbulento = 4000;   % Reynolds para flujo turbulento
```

### Análisis de Infarto
```matlab
params.Q_minimo_porcentaje = 30;  % % flujo mínimo viable
params.P_externa_mmHg = 20;       % Presión tisular (mmHg)
```

### Análisis Avanzados (NUEVOS)
```matlab
params.graficar_adimensional = true;   % Números Re, Eu, Wo, De
params.graficar_sensibilidad = true;   % Análisis de sensibilidad
params.frecuencia_cardiaca = 1.2;      % Hz (para Womersley)
```

### Opciones de Visualización
```matlab
params.mostrar_figuras = true;         % Mostrar gráficas
params.graficar_velocidades = true;    % Ejercicio 3
params.graficar_reynolds = true;       % Ejercicio 4
params.graficar_wss = true;            % Ejercicio 5
params.graficar_infarto = true;        % Ejercicio 6
params.graficar_parametrico = true;    % Análisis adicional
```

---

## 📊 Ejercicios Incluidos

### Ejercicio 1-2: Resistencias Hidráulicas
- Cálculo usando ecuación de Poiseuille
- Comparación arterias sanas vs con trombosis
- **Nuevo**: Analogía eléctrica visual, superficie 3D

### Ejercicio 3: Velocidades Sanguíneas
- Análisis de velocidad en función de geometría
- Mapas de velocidad con oclusión
- **Nuevo**: Perfil parabólico 3D, gradientes de velocidad

### Ejercicio 4: Regímenes de Flujo
- Número de Reynolds
- Clasificación: laminar, transición, turbulento
- **Nuevo**: Diagrama de Moody simplificado, zonas coloreadas

### Ejercicio 5: Riesgo de Aneurisma
- Wall Shear Stress (WSS)
- Shear Rate (tasa de corte)
- Tensión de pared (Ley de Laplace)
- **Nuevo**: Índice de riesgo combinado, semáforos

### Ejercicio 6: Riesgo de Infarto
- Teoría 1: Efecto Venturi (colapso arterial)
- Teoría 2: Resistencia extrema (bloqueo)
- **Nuevo**: Semáforos de riesgo, diagrama de decisión

### Ejercicio 7: Análisis Adimensional (NUEVO)
- Número de Reynolds (Re) - Régimen de flujo
- Número de Euler (Eu) - Presión vs inercia
- Número de Womersley (α) - Efectos pulsátiles
- Número de Dean (De) - Flujo secundario
- Diagrama radar normalizado

### Ejercicio 8: Análisis de Sensibilidad (NUEVO)
- Tornado plots de parámetros dominantes
- Superficies de respuesta 3D
- Índices de sensibilidad local

---

## 🔧 Personalización Avanzada

### Añadir Nueva Visualización
1. Crear función en `visualizacion/`
2. Añadir parámetro en `configuracion_parametros.m`
3. Llamar desde `main_analisis_arterial.m`

### Modificar Análisis
1. Editar función correspondiente en `funciones/`
2. Mantener estructura de inputs/outputs
3. Documentar cambios en comentarios

---

## 📝 Notas Importantes

- **No modificar** archivos fuera de `configuracion_parametros.m` a menos que sepas lo que haces
- Todos los valores deben estar en **unidades SI**
- Las figuras se cierran automáticamente al inicio (configurable)
- Los resultados se muestran en Command Window con formato legible

---

## 🎓 Aprendizajes Clave

Conceptos físicos implementados:
- Ecuación de Poiseuille (flujo laminar)
- Ecuación de Bernoulli (efecto Venturi)
- Número de Reynolds (régimen de flujo)
- Wall Shear Stress (estrés en pared arterial)
- Ley de Laplace (tensión de pared)

---

## 👥 Autores

Proyecto de Física - Análisis de Flujo Arterial  
Fecha: 2026-01-11

---

## 📚 Referencias

Ver `implementation_plan.md` para detalles de implementación.

---

**¡IMPORTANTE!** Para ejecutar el análisis completo, simplemente ejecutar:
```matlab
main_analisis_arterial
```
