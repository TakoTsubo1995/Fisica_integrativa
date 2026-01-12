%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN_ANALISIS_ARTERIAL - Análisis Completo de Flujo en Arterias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPCIÓN:
%   Script principal que ejecuta todos los análisis de flujo arterial:
%   - Resistencias hidráulicas (Poiseuille)
%   - Velocidades sanguíneas
%   - Regímenes de flujo (Reynolds)
%   - Riesgo de aneurisma (WSS, shear rate, tensión)
%   - Riesgo de infarto (Venturi vs Resistencia)
%
% USO:
%   1. Modificar parámetros en: configuracion_parametros.m
%   2. Ejecutar este script
%   3. Revisar resultados en Command Window y figuras
%
% DEPENDENCIAS:
%   - configuracion_parametros.m
%   - Funciones en carpeta funciones/
%   - Funciones en carpeta visualizacion/
%
% Autores: Proyecto de Física - Análisis de Flujo Arterial
% Fecha: 2026-01-11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INICIALIZACIÓN

% Limpiar workspace y cerrar figuras
clear; clc;

% Cargar configuración
fprintf('Cargando configuración...\n');
params = configuracion_parametros();

% Cerrar figuras previas si está activado
if params.cerrar_figuras_previas
    close all;
end

% Añadir carpetas al path
addpath('funciones');
addpath('visualizacion');
addpath('utilidades');

%% GENERACIÓN DE GEOMETRÍA Y PROPIEDADES

fprintf('Generando geometría arterial...\n');

% Vectores de parámetros
r_art_s = linspace(params.radio_min, params.radio_max, params.num_radios);
l_art_s = linspace(params.longitud_min, params.longitud_max, params.num_longitudes);
tasa_ocl_r = linspace(params.ocl_radial_min, params.ocl_radial_max, params.num_ocl_radial);
tasa_ocl_l = linspace(params.ocl_longitudinal_min, params.ocl_longitudinal_max, params.num_ocl_long);

% Matrices 4D usando ndgrid
[R_ART_S, L_ART_S, OCL_R, OCL_L] = ndgrid(r_art_s, l_art_s, tasa_ocl_r, tasa_ocl_l);

% Radios efectivos con oclusión radial
r_art_trom = R_ART_S .* (1 - OCL_R/100);

% MODELO CORRECTO DE OCLUSIÓN LONGITUDINAL (Resistencias en Serie)
% OCL_L% de la longitud tiene trombo (radio reducido)
% (1-OCL_L%) de la longitud está sana (radio normal)
L_zona_sana = L_ART_S .* (1 - OCL_L/100);   % Longitud de zona sana
L_zona_tromb = L_ART_S .* (OCL_L/100);       % Longitud de zona con trombo

% Propiedades de la sangre
eta_sangre = linspace(params.eta_min, params.eta_max, params.num_radios);
eta_media = median(eta_sangre);
rho = params.rho;

% Flujo y presión
Q_art_n = linspace(params.Q_min, params.Q_max, params.num_radios);
PAM_art_f = linspace(params.PAM_min, params.PAM_max, params.num_radios);

fprintf('  Geometría generada: %dx%dx%dx%d matriz\n', size(R_ART_S));

%% EJERCICIO 1-2: RESISTENCIAS HIDRÁULICAS

fprintf('\n📊 EJERCICIO 1-2: Calculando resistencias...\n');

% Resistencias arterias sanas (Poiseuille)
R_ART_SANAS = (8 * eta_sangre(:) .* L_ART_S) ./ (pi * R_ART_S.^4);

% Resistencias con trombosis (MODELO DE RESISTENCIAS EN SERIE)
% R_total = R_zona_sana + R_zona_trombosada
R_zona_sana_val = (8 * eta_sangre(:) .* L_zona_sana) ./ (pi * R_ART_S.^4);
R_zona_tromb_val = (8 * eta_sangre(:) .* L_zona_tromb) ./ (pi * r_art_trom.^4);
R_zona_tromb_val(r_art_trom < 1e-6) = Inf; % Bloqueo completo

R_ART_TROMB = R_zona_sana_val + R_zona_tromb_val;
R_ART_TROMB(r_art_trom < 1e-6) = Inf; % Bloqueo completo (r < 1 micrón = imposible)

fprintf('  Resistencias calculadas ✓\n');

% Estadísticas
R_sanas_min = min(R_ART_SANAS(:));
R_sanas_max = max(R_ART_SANAS(:));
R_tromb_valid = R_ART_TROMB(isfinite(R_ART_TROMB) & R_ART_TROMB > 0);
R_tromb_min = min(R_tromb_valid);
R_tromb_max = max(R_tromb_valid);

fprintf('  R_sanas: %.2e - %.2e Pa·s/m³\n', R_sanas_min, R_sanas_max);
fprintf('  R_tromb: %.2e - %.2e Pa·s/m³\n', R_tromb_min, R_tromb_max);
fprintf('  Factor máximo de aumento: %.0fx\n', R_tromb_max/R_sanas_min);

% Visualización
if params.mostrar_figuras && params.graficar_resistencias
    fprintf('  Generando gráficas de resistencias...\n');
    graficar_resistencias(r_art_s, l_art_s, tasa_ocl_r, R_ART_SANAS, R_ART_TROMB);
end


%% EJERCICIO 3: ANÁLISIS DE VELOCIDADES

fprintf('\n📊 EJERCICIO 3: Analisis de velocidades...\n');

Q_promedio = median(Q_art_n);

% Áreas
A_ART_S = pi * R_ART_S(:, 1, 1, 1).^2;
A_ART_TROMB = squeeze(pi * r_art_trom(:, 1, :, 1).^2);
A_ART_TROMB(A_ART_TROMB < 1e-12) = NaN;  % Área < 1 μm² = bloqueo total

% Velocidades
v_sanas = Q_promedio ./ A_ART_S;
v_tromb = Q_promedio ./ A_ART_TROMB;
v_tromb(v_tromb > 50) = NaN;  % Velocidades > 50 m/s (180 km/h) = físicamente imposible

fprintf('  Velocidades calculadas ✓\n');
fprintf('  v_sanas: %.2f - %.2f cm/s\n', min(v_sanas)*100, max(v_sanas)*100);
fprintf('  v_tromb: %.2f - %.2f cm/s\n', min(v_tromb(:), [], 'omitnan')*100, max(v_tromb(:), [], 'omitnan')*100);

% Visualización
if params.mostrar_figuras && params.graficar_velocidades
    fprintf('  Generando gráficas de velocidades...\n');
    graficar_velocidades(r_art_s, tasa_ocl_r, v_sanas, v_tromb);
end

%% EJERCICIO 4: RÉGIMEN DE FLUJO (REYNOLDS)

fprintf('\n📊 EJERCICIO 4: Análisis de Reynolds...\n');

% Diámetros
D_sanas = 2 * r_art_s(:);
r_efectivos = squeeze(r_art_trom(:, 1, :, 1));
r_efectivos(r_efectivos < 1e-6) = NaN;  % Evitar divisiones por cero (r < 1 micrón = imposible)
D_tromb = 2 * r_efectivos;

% Reynolds
Re_sanas = (rho .* v_sanas .* D_sanas) / eta_media;
Re_tromb = (rho .* v_tromb .* D_tromb) / eta_media;

fprintf('  Re_sanas (mediana): %.0f\n', median(Re_sanas));
fprintf('  Re_tromb (mediana): %.0f\n', median(Re_tromb(:), 'omitnan'));

% Radios críticos para transición de régimen
% Re = ρvD/η = 2ρQ/(πrη) → r_crit = 2ρQ/(πη·Re_crit)
radio_lam = (2 * rho * Q_promedio) / (pi * eta_media * params.Re_laminar);
radio_turb = (2 * rho * Q_promedio) / (pi * eta_media * params.Re_turbulento);

fprintf('  Radio crítico transición (Re=2000): %.3f mm\n', radio_lam*1000);
fprintf('  Radio crítico turbulencia (Re=4000): %.3f mm\n', radio_turb*1000);

% Visualización
if params.mostrar_figuras && params.graficar_reynolds
    fprintf('  Generando gráficas de Reynolds...\n');
    graficar_reynolds(r_art_s, tasa_ocl_r, Re_sanas, Re_tromb, params);
end

%% EJERCICIO 5: RIESGO DE ANEURISMA

fprintf('\n📊 EJERCICIO 5: Análisis de riesgo de aneurisma...\n');

% Calcular WSS, shear rate, tensión
[WSS_sanas, WSS_tromb, shear_rate_sanas, shear_rate_tromb, sigma_sanas, sigma_tromb] = ...
    analisis_wss_shear(v_sanas, v_tromb, r_art_s, r_efectivos, eta_media, PAM_art_f, params);

% Visualización
if params.mostrar_figuras && params.graficar_wss
    fprintf('  Generando gráficas de riesgo de aneurisma...\n');
    graficar_riesgo_aneurisma(r_art_s, tasa_ocl_r, WSS_sanas, WSS_tromb, ...
        shear_rate_sanas, shear_rate_tromb, sigma_sanas, sigma_tromb, params);
end

%% EJERCICIO 6: RIESGO DE INFARTO

fprintf('\n📊 EJERCICIO 6: Análisis de riesgo de infarto...\n');

% Análisis Venturi vs Resistencia
[ocl_critica_venturi, ocl_critica_resistencia, mapa_mecanismo, P_transmural, Q_resultante, analisis_detallado] = ...
    analisis_venturi_resistencia(v_sanas, v_tromb, r_art_s, r_efectivos, ...
    R_ART_SANAS, R_ART_TROMB, PAM_art_f, Q_art_n, tasa_ocl_r, rho, params);

% Visualización
if params.mostrar_figuras && params.graficar_infarto
    fprintf('  Generando gráficas de riesgo de infarto...\n');
    graficar_riesgo_infarto(r_art_s, tasa_ocl_r, ocl_critica_venturi, ocl_critica_resistencia, ...
        mapa_mecanismo, P_transmural, Q_resultante, Q_art_n, params);
end

% Análisis paramétrico (opcional)
if params.graficar_parametrico
    fprintf('\n  Ejecutando análisis paramétrico...\n');
    analisis_parametrico(v_sanas, v_tromb, r_art_s, r_efectivos, R_ART_SANAS, R_ART_TROMB, ...
        PAM_art_f, Q_art_n, tasa_ocl_r, rho, params);
end

%% EJERCICIO 7: ANÁLISIS ADIMENSIONAL (NUEVO)

if params.graficar_adimensional && params.mostrar_figuras
    fprintf('\n📊 EJERCICIO 7: Análisis de números adimensionales...\n');
    eta_media = median(linspace(params.eta_min, params.eta_max, params.num_radios));
    [numeros_adim, ~] = analisis_adimensional(v_sanas, v_tromb, r_art_s, r_efectivos, ...
        Q_art_n, PAM_art_f, eta_media, params);
end

%% EJERCICIO 8: ANÁLISIS DE SENSIBILIDAD (NUEVO)

if params.graficar_sensibilidad && params.mostrar_figuras
    fprintf('\n📊 EJERCICIO 8: Análisis de sensibilidad paramétrica...\n');
    [resultados_sens, ~] = analisis_sensibilidad(r_art_s, l_art_s, tasa_ocl_r, params);
end

%% FINALIZACIÓN

fprintf('\n========================================\n');
fprintf('   ANÁLISIS COMPLETADO ✓\n');
fprintf('========================================\n');
fprintf('Total de figuras generadas: %d\n', length(findall(0, 'Type', 'figure')));

if params.guardar_resultados
    fprintf('Guardando resultados...\n');
    guardar_resultados(params);
    fprintf('  Resultados guardados en: %s/\n', params.carpeta_resultados);
end

fprintf('\nPara modificar parámetros, editar: configuracion_parametros.m\n');
fprintf('========================================\n\n');

%% VISUALIZACIÓN INTERACTIVA COMPLETA (Broche de Oro)

if params.mostrar_figuras
    fprintf('\n🎨 ========== BROCHE DE ORO ==========\n');
    fprintf('Generando dashboards interactivos...\n\n');
    visualizacion_interactiva_completa(r_art_s, l_art_s, tasa_ocl_r, params);
end

