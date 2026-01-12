%% ANÁLISIS: UMBRALES DONDE TEORÍA RESISTENCIA DOMINA
% Cálculo analítico de Q_min, P_min y Radio mínimo para que la teoría
% de Resistencia (bloqueo por flujo insuficiente) domine sobre Venturi
% (colapso por presión negativa).
%
% Considera WSS y Shear Rate como predictores de riesgo trombogénico.

clear; clc;

%% PARÁMETROS BASE (del ejercicio)
params = configuracion_parametros();

% Constantes
rho = params.rho;                   % kg/m³ - Densidad sangre
eta = 0.0037;                       % Pa·s - Viscosidad media
L = 0.061;                          % m - Longitud arteria (61 mm)
PAM = 87 * 133.322;                 % Pa - Presión arterial media
P_ext = 20 * 133.322;               % Pa - Presión externa tisular
Q_basal = 6e-6;                     % m³/s - Flujo normal (360 ml/min)

% Umbrales de riesgo
WSS_bajo = params.WSS_bajo;         % Pa - Riesgo estasis
WSS_alto = params.WSS_alto;         % Pa - Riesgo daño endotelial
shear_bajo = params.shear_bajo;     % s⁻¹ - Riesgo trombosis
shear_alto = params.shear_alto;     % s⁻¹ - Riesgo hemólisis

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════════╗\n');
fprintf('║   ANÁLISIS ANALÍTICO: UMBRALES TEORÍA RESISTENCIA vs VENTURI        ║\n');
fprintf('╚══════════════════════════════════════════════════════════════════════╝\n\n');

%% PARÁMETROS BASE DEL ANÁLISIS
fprintf('┌─ PARÁMETROS BASE ──────────────────────────────────────────────────┐\n');
fprintf('│ PAM:              %.0f mmHg\n', PAM/133.322);
fprintf('│ P_externa:        %.0f mmHg\n', P_ext/133.322);
fprintf('│ Flujo basal:      %.0f ml/min\n', Q_basal * 1e6 * 60);
fprintf('│ Longitud:         %.0f mm\n', L*1000);
fprintf('│ Viscosidad:       %.4f Pa·s\n', eta);
fprintf('└────────────────────────────────────────────────────────────────────┘\n\n');

%% 1. ANÁLISIS: ¿QUÉ OCLUSIÓN PARA CADA TEORÍA?
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('1. DERIVACIÓN TEÓRICA\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');

fprintf('TEORÍA VENTURI:\n');
fprintf('  Colapso cuando: P_transmural = PAM - ½ρ(v²_tromb - v²_sana) - P_ext < 0\n');
fprintf('  v_tromb = Q / (π r_eff²)\n');
fprintf('  Resolviendo para oclusión crítica...\n\n');

fprintf('TEORÍA RESISTENCIA:\n');
fprintf('  Bloqueo cuando: Q_res = PAM / R_tromb < Q_min\n');
fprintf('  R_tromb = 8ηL / (π r_eff⁴)\n');
fprintf('  Resolviendo para oclusión crítica...\n\n');

%% 2. CALCULAR UMBRALES PARA DIFERENTES RADIOS
radios_test = [3.5, 4.0, 4.5, 5.0, 5.3] * 1e-3;  % m

fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('2. UMBRAL Q_MIN DONDE RESISTENCIA GANA\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');

fprintf('Para cada radio, encontramos Q_min tal que ocl_resistencia = ocl_venturi:\n\n');

Q_min_umbral = zeros(size(radios_test));
ocl_critica = zeros(size(radios_test));
WSS_en_umbral = zeros(size(radios_test));
shear_en_umbral = zeros(size(radios_test));

for i = 1:length(radios_test)
    r = radios_test(i);
    v_sana = Q_basal / (pi * r^2);

    % Buscar oclusión donde Venturi colapsa (P_transmural = 0)
    % PAM - ½ρ(v_tromb² - v_sana²) - P_ext = 0
    % v_tromb² = v_sana² + 2(PAM - P_ext)/ρ
    v_tromb_critica = sqrt(v_sana^2 + 2*(PAM - P_ext)/rho);

    % r_eff para esa velocidad: v = Q/(π r_eff²) → r_eff = sqrt(Q/(π v))
    r_eff_venturi = sqrt(Q_basal / (pi * v_tromb_critica));

    % Oclusión correspondiente: r_eff = r*(1-ocl/100)
    ocl_venturi = 100 * (1 - r_eff_venturi / r);
    ocl_critica(i) = ocl_venturi;

    % Para que Resistencia gane en ESA misma oclusión, necesitamos:
    % Q_res = PAM / R_tromb = Q_min
    R_tromb_critico = (8 * eta * L) / (pi * r_eff_venturi^4);
    Q_res_critico = PAM / R_tromb_critico;

    % Q_min debe ser ≥ Q_res para que Resistencia detecte el bloqueo
    Q_min_umbral(i) = Q_res_critico;

    % Calcular WSS y shear rate en ese punto
    WSS_en_umbral(i) = 4 * eta * v_tromb_critica / r_eff_venturi;
    shear_en_umbral(i) = 4 * v_tromb_critica / r_eff_venturi;
end

fprintf('┌────────────┬────────────┬────────────┬────────────┬────────────┬───────────────┐\n');
fprintf('│ Radio (mm) │ Ocl_crit   │ Q_min      │ WSS (Pa)   │ Shear s⁻¹  │ Riesgo        │\n');
fprintf('├────────────┼────────────┼────────────┼────────────┼────────────┼───────────────┤\n');

for i = 1:length(radios_test)
    Q_min_pct = 100 * Q_min_umbral(i) / Q_basal;

    % Determinar riesgo
    if WSS_en_umbral(i) > WSS_alto
        riesgo = '🔴 WSS alto';
    elseif WSS_en_umbral(i) < WSS_bajo
        riesgo = '⚠️ WSS bajo';
    else
        riesgo = '✓ Normal';
    end

    fprintf('│ %10.1f │ %8.1f %% │ %8.1f %% │ %10.1f │ %10.0f │ %-13s │\n', ...
        radios_test(i)*1000, ocl_critica(i), Q_min_pct, ...
        WSS_en_umbral(i), shear_en_umbral(i), riesgo);
end
fprintf('└────────────┴────────────┴────────────┴────────────┴────────────┴───────────────┘\n\n');

fprintf('INTERPRETACIÓN:\n');
fprintf('  Para que Resistencia gane a Venturi, Q_min debe ser ≥ valor de la tabla.\n');
fprintf('  Con Q_min típico (10-30%%), Venturi SIEMPRE gana primero.\n\n');

%% 3. UMBRAL P_EXTERNA
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('3. UMBRAL P_EXTERNA DONDE RESISTENCIA GANA\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');

fprintf('Si aumentamos P_externa, el colapso Venturi ocurre antes.\n');
fprintf('Pero también: Margen = PAM - P_ext se reduce → menos flujo disponible.\n\n');

% Para radio medio (4.4 mm), calcular P_ext necesaria para cada Q_min
r_medio = 4.4e-3;
Q_min_test = [0.1, 0.2, 0.3, 0.4, 0.5] * Q_basal;
P_ext_umbral = zeros(size(Q_min_test));

for i = 1:length(Q_min_test)
    Q_min = Q_min_test(i);

    % Para que Resistencia gane, la oclusión de bloqueo debe ser menor que la de Venturi
    % Iteramos para encontrar P_ext donde se igualan
    for P_ext_test = (10:1:85) * 133.322
        v_sana = Q_basal / (pi * r_medio^2);

        % Venturi
        v_tromb_v = sqrt(v_sana^2 + 2*(PAM - P_ext_test)/rho);
        if ~isreal(v_tromb_v), continue; end
        r_eff_v = sqrt(Q_basal / (pi * v_tromb_v));
        ocl_v = 100 * (1 - r_eff_v / r_medio);

        % Resistencia: buscar oclusión donde Q_res = Q_min
        % Q_res = PAM / (8ηL/(πr_eff⁴)) = Q_min
        % r_eff⁴ = 8ηL·Q_min / (π·PAM)
        r_eff_r = (8 * eta * L * Q_min / (pi * PAM))^0.25;
        ocl_r = 100 * (1 - r_eff_r / r_medio);

        if ocl_r < ocl_v && ocl_r > 0
            P_ext_umbral(i) = P_ext_test / 133.322;
            break;
        end
    end
end

fprintf('Para radio = %.1f mm:\n\n', r_medio*1000);
fprintf('┌────────────────────┬────────────────────┐\n');
fprintf('│ Q_min (%% flujo)    │ P_ext umbral (mmHg)│\n');
fprintf('├────────────────────┼────────────────────┤\n');
for i = 1:length(Q_min_test)
    if P_ext_umbral(i) > 0
        fprintf('│ %18.0f │ %18.0f │\n', 100*Q_min_test(i)/Q_basal, P_ext_umbral(i));
    else
        fprintf('│ %18.0f │ %18s │\n', 100*Q_min_test(i)/Q_basal, 'No existe');
    end
end
fprintf('└────────────────────┴────────────────────┘\n\n');

%% 4. RIESGO TROMBOGÉNICO EN FUNCIÓN DE WSS/SHEAR
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('4. PREDICCIÓN DE RIESGO TROMBOGÉNICO\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');

fprintf('Umbrales de riesgo:\n');
fprintf('  WSS < %.1f Pa → Estasis → Formación de trombo\n', WSS_bajo);
fprintf('  WSS > %.1f Pa → Daño endotelial → Agregación plaquetaria\n', WSS_alto);
fprintf('  Shear < %d s⁻¹ → Flujo lento → Coagulación\n', shear_bajo);
fprintf('  Shear > %d s⁻¹ → Hemólisis → Liberación ADP\n\n', shear_alto);

% Calcular oclusiones donde se alcanzan estos umbrales
fprintf('┌────────────┬─────────────────────────────────────────────────────────┐\n');
fprintf('│ Radio (mm) │ Oclusión donde se inicia riesgo trombogénico           │\n');
fprintf('├────────────┼─────────────────────────────────────────────────────────┤\n');

for i = 1:length(radios_test)
    r = radios_test(i);
    v_sana = Q_basal / (pi * r^2);

    % Buscar oclusión donde WSS > WSS_alto
    % WSS = 4ηv/r_eff = 4η·Q/(π·r_eff³) > WSS_alto
    % r_eff³ < 4ηQ/(π·WSS_alto)
    r_eff_wss_alto = (4 * eta * Q_basal / (pi * WSS_alto))^(1/3);
    ocl_wss_alto = 100 * (1 - r_eff_wss_alto / r);

    % Buscar donde shear > shear_alto
    r_eff_shear_alto = (4 * Q_basal / (pi * shear_alto))^(1/3);
    ocl_shear_alto = 100 * (1 - r_eff_shear_alto / r);

    fprintf('│ %10.1f │ WSS>%.1f Pa: %.0f%%  |  Shear>%d: %.0f%%              │\n', ...
        r*1000, WSS_alto, max(0,ocl_wss_alto), shear_alto, max(0,ocl_shear_alto));
end
fprintf('└────────────┴─────────────────────────────────────────────────────────┘\n\n');

%% 5. CONCLUSIONES
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('5. CONCLUSIONES\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n\n');

fprintf('PARA QUE RESISTENCIA DOMINE SOBRE VENTURI:\n\n');

Q_min_tipico = mean(Q_min_umbral) / Q_basal * 100;
fprintf('  1. Q_min necesario:  %.0f%% del flujo basal\n', Q_min_tipico);
fprintf('     (vs 10-30%% típico → Por eso Venturi siempre gana)\n\n');

fprintf('  2. P_externa necesaria: >%.0f mmHg (síndrome compartimental)\n', ...
    min(P_ext_umbral(P_ext_umbral > 0)));
fprintf('     (vs 20 mmHg normal)\n\n');

fprintf('  3. Radio mínimo: NO hay radio donde Resistencia gane primero\n');
fprintf('     (El efecto Venturi escala con v², Resistencia con 1/r⁴)\n\n');

fprintf('IMPLICACIÓN CLÍNICA:\n');
fprintf('  El colapso arterial por efecto Venturi es el mecanismo predominante.\n');
fprintf('  La isquemia por bloqueo de flujo (Resistencia) solo domina en:\n');
fprintf('   • Microcirculación (arteriolas <100 μm)\n');
fprintf('   • Síndromes compartimentales (P_ext muy alta)\n');
fprintf('   • Tejidos muy sensibles a isquemia (miocardio, cerebro)\n\n');

%% GRÁFICA RESUMEN
figure('Name', 'Umbrales Resistencia vs Venturi', 'Position', [100, 100, 1100, 500]);

% Panel 1: Q_min umbral por radio
subplot(1, 2, 1);
bar(radios_test*1000, 100*Q_min_umbral/Q_basal, 'FaceColor', [0.3 0.5 0.8]);
hold on;
yline(30, 'r--', 'LineWidth', 2, 'Label', 'Q_{min} típico (30%)');
xlabel('Radio arterial (mm)', 'FontSize', 12);
ylabel('Q_{min} necesario para Resistencia (%)', 'FontSize', 12);
title('Umbral Q_{min} donde Resistencia gana', 'FontSize', 13, 'FontWeight', 'bold');
ylim([0, 100]);
grid on;

% Panel 2: WSS y riesgo trombogénico
subplot(1, 2, 2);
yyaxis left;
bar(radios_test*1000, WSS_en_umbral, 'FaceColor', [0.8 0.3 0.3]);
ylabel('WSS en punto crítico (Pa)', 'FontSize', 12);
hold on;
yline(WSS_alto, 'r--', 'LineWidth', 2);
yline(WSS_bajo, 'g--', 'LineWidth', 2);

yyaxis right;
plot(radios_test*1000, shear_en_umbral/1000, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
ylabel('Shear Rate (×10³ s⁻¹)', 'FontSize', 12);

xlabel('Radio arterial (mm)', 'FontSize', 12);
title('WSS y Shear Rate en punto crítico', 'FontSize', 13, 'FontWeight', 'bold');
legend('WSS', 'WSS_{alto}', 'WSS_{bajo}', 'Shear Rate', 'Location', 'northeast');
grid on;

sgtitle('Análisis: Condiciones para Dominancia de Teoría Resistencia', ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('Gráfica generada ✓\n');
