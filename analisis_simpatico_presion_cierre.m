%% ANÁLISIS: EFECTO SIMPÁTICO EN PRESIÓN DE CIERRE ARTERIAL
% Script corregido con valores fisiológicos realistas
%
% La presión crítica de cierre (CCP) en arterias es típicamente:
% - Reposo: 5-15 mmHg
% - Simpático leve: 15-25 mmHg
% - Simpático intenso: 30-50 mmHg

clear; clc;

%% PARÁMETROS FIJOS (del ejercicio)
r_arterial = 4.4e-3;        % m - Radio arterial medio (4.4 mm)
P_externa = 20;             % mmHg - Presión tisular externa
PAM = 87;                   % mmHg - Presión arterial media

%% PRESIONES CRÍTICAS DE CIERRE (valores fisiológicos)
% Basados en literatura: CCP típica varía de 5-50 mmHg según tono vascular

% Componentes de la CCP:
% CCP = Zero-flow pressure ≈ P_externa + Tono_vascular

% Tono vascular (contribución del músculo liso):
tono_reposo = 5;            % mmHg - Músculo relajado
tono_leve = 15;             % mmHg - Simpático leve
tono_moderado = 25;         % mmHg - Simpático moderado
tono_intenso = 40;          % mmHg - Simpático intenso (shock)

condiciones = {'Normal (reposo)', 'Simpático leve', 'Simpático moderado', 'Simpático intenso'};
tonos = [tono_reposo, tono_leve, tono_moderado, tono_intenso];

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════════════╗\n');
fprintf('║     EFECTO SIMPÁTICO EN PRESIÓN DE CIERRE ARTERIAL                  ║\n');
fprintf('╠══════════════════════════════════════════════════════════════════════╣\n');
fprintf('║ Radio arterial:    %.1f mm                                           ║\n', r_arterial*1000);
fprintf('║ Presión externa:   %.0f mmHg                                          ║\n', P_externa);
fprintf('║ PAM:               %.0f mmHg                                          ║\n', PAM);
fprintf('╚══════════════════════════════════════════════════════════════════════╝\n\n');

fprintf('┌────────────────────────┬──────────────┬───────────────┬─────────────┐\n');
fprintf('│ Condición              │ Tono vascular│ P_cierre      │ Margen      │\n');
fprintf('│                        │ (mmHg)       │ (mmHg)        │ (mmHg)      │\n');
fprintf('├────────────────────────┼──────────────┼───────────────┼─────────────┤\n');

for i = 1:length(condiciones)
    % Presión de cierre = P_externa + Tono vascular
    P_cierre = P_externa + tonos(i);

    % Margen de seguridad: PAM - P_cierre
    margen = PAM - P_cierre;

    % Indicador de riesgo
    if margen > 40
        estado = '✓ Seguro  ';
    elseif margen > 20
        estado = '⚠ Alerta  ';
    else
        estado = '🔴 RIESGO ';
    end

    fprintf('│ %-22s │ %10.0f   │ %11.0f   │ %8.0f %s│\n', ...
        condiciones{i}, tonos(i), P_cierre, margen, estado);
end

fprintf('└────────────────────────┴──────────────┴───────────────┴─────────────┘\n');

%% ANÁLISIS
fprintf('\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('ANÁLISIS:\n');
fprintf('═══════════════════════════════════════════════════════════════════════\n');
fprintf('\n');
fprintf('• Presión Crítica de Cierre (CCP):\n');
fprintf('  CCP = P_externa + Tono_vascular\n');
fprintf('\n');
fprintf('• Con activación SIMPÁTICA:\n');
fprintf('  - Noradrenalina → Contracción músculo liso → ↑ Tono vascular\n');
fprintf('  - ↑ Tono = ↑ CCP (mayor presión necesaria para flujo)\n');
fprintf('\n');
fprintf('• Margen de perfusión = PAM - CCP:\n');
fprintf('  - Margen > 40 mmHg: Perfusión garantizada\n');
fprintf('  - Margen 20-40 mmHg: Riesgo en extremidades\n');
fprintf('  - Margen < 20 mmHg: Riesgo de isquemia\n');
fprintf('\n');

%% GRÁFICA
figure('Name', 'Efecto Simpático en Presión de Cierre', 'Position', [100, 100, 900, 500]);

% Panel 1: Presión de cierre vs Tono vascular
subplot(1, 2, 1);
tono_rango = linspace(0, 50, 100);
P_cierre_rango = P_externa + tono_rango;

plot(tono_rango, P_cierre_rango, 'r-', 'LineWidth', 2.5);
hold on;
yline(PAM, 'b--', 'LineWidth', 2, 'Label', 'PAM');
fill([0 50 50 0], [PAM PAM 0 0], [0.2 0.8 0.2], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
fill([0 50 50 0], [120 120 PAM PAM], [0.9 0.3 0.3], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Marcar puntos de las condiciones
for i = 1:length(tonos)
    P_cierre = P_externa + tonos(i);
    plot(tonos(i), P_cierre, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
end

xlabel('Tono Vascular (mmHg)', 'FontSize', 12);
ylabel('Presión de Cierre (mmHg)', 'FontSize', 12);
title('P_{cierre} vs Tono Simpático', 'FontSize', 13, 'FontWeight', 'bold');
legend('P_{cierre}', 'PAM', 'Vaso abierto', 'Vaso cerrado', 'Location', 'northwest');
grid on;
xlim([0, 50]);
ylim([0, 120]);

% Panel 2: Diagrama de barras
subplot(1, 2, 2);
P_cierres = P_externa + tonos;

b = bar(categorical(condiciones), P_cierres, 'FaceColor', 'flat');
hold on;
yline(PAM, 'b--', 'LineWidth', 2, 'Label', 'PAM');

% Colorear barras según riesgo
colores = [0.2 0.7 0.2; 0.7 0.9 0.2; 0.9 0.7 0.2; 0.9 0.3 0.2];
for i = 1:length(P_cierres)
    b.CData(i,:) = colores(i,:);
end

ylabel('Presión de Cierre (mmHg)', 'FontSize', 12);
title('Comparación por Nivel Simpático', 'FontSize', 13, 'FontWeight', 'bold');
grid on;
ylim([0, 100]);

sgtitle('Efecto de la Activación Simpática en la Presión de Cierre Arterial', ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('Gráfica generada ✓\n');
