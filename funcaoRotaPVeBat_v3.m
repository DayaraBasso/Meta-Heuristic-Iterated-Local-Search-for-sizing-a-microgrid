function [fo] = funcaoRotaPVeBat_v3(d, ordem_rota, Ta, Npv, Nbat, P_BAT)
%% Função para calcular o valor da função objetivo - FO

%% Parâmetros de entrada
% d = matriz de distância entre os nós
% ordem_rota = ordem de visita dos clientes sem o depósito
% ec = nó que corresponde a estação de carregamento
% Ta = temperatura ambiente
% Npv = numero de painéis fotovoltaicos
% Nbat = numero de bancos de bateria
% P_BAT = potencia de cada banco de bateria


% Parâmetros
fo_media = 0;
taxa_juros = 0.1; % 10% de taxa de juros para trazer o valor presente
vida_util = 10; % Vida útil da bateria do VE (anos)
dias_ano = 252; % Dias úteis do ano (dias)
alpha = (1-(1+taxa_juros)^(-vida_util))/taxa_juros; % taxa de juros do valor presente
beta1 = 1e3; % penaliza para o tempo de carga
beta2 = -10; % fator de bonificação para o carregamento do banco de baterias pelos painéis
beta3 = 1e4; % penalização para caso ultrapasse o tempo máximo de atendimento
beta4 = 1e6; %penalização para caso o soc restante seja maior que a potência do VE em si
beta5 = 1e6; % penalização caso nao haja potência suficiente na microrrede p carregar o VE
beta6 = 1e6; % penalização caso os paineis nao carreguem a baterias
beta7 = 1e6; % penalização caso o SOC seja menor que o SOC min

% laço de repetição para calcular o valor esperado da FO (uma para cada perfil PV) e fazer a
% média
for w = 1:3

    %% dados do sistema e variáveis
    rota = [1 ordem_rota 1]; %define a rota saindo e voltaindo do depósito
    t = d/50;  %tempo de percurso entre os nós em horas
    fo_pen = 0;  %inicia a FO penalizada em 0 em todo passo
    d_percorrida = 0; % variável para contar a distância percorrida
    d_falta = 0;    % variável para contar a distância que falta percorrer quando visita a EC
    t_aux = 8;  %  tempo de percurso com o horário iniciado em 8h da manhã 
    t_carga = 0;  % variável auxiliar para contar o tempo de carga do VE
    t_cheg = 0; %variavel que representa o tempo que chega na ec
    tal = 0;  % variável auxiliar para aproximar a hora t_aux a um valor inteiro
    k = 2; % variável auxiliar para contar o índice dos vetores de impressão
    delta = 0.3; %consumo de bateria por km (kwh/km)
    custo_d = 0.2; %custo de percorrer uma unidade de distância

    %%   DADOS
    %----------------------------------------
    % dados dos clientes
    Tmax = 18;  % tempo máximo de atendimento dos clientes
    N = length(rota); % número de clientes
    dep = 1;     %nó que corresponde ao depósito
    ec = 9;      %nó que corresponde a estação de carregamento

    % dados do veículo elétrico
    P_VE = 60; %potência da bateria do VE em kWh
    P_VE_M = 10; % potência máxima de carregamento do VE em kW
    soc = P_VE;  %estado de carga inicial do VE recebe a Pot max do VE carregado (kWh)
    soc_falta = 0; % variável auxiliar para calcular o quanto de bat falta p/ completar a rota
    soc_min = 0.1*soc; % estado de carga minimo
    vetor_soc = 0;  % vetor soc para armazenar os valores ao longo da rota
    vetor_soc(1,1) = soc;  %  iniciando o vetor soc com o valor da autonomia
    %E_carga_VE = 0; % energia de carregamento do VE
    vetor_carga = zeros(1,24); % vetor para armazenar os valores de soc para impressão
    E_carga_VE_2 = 0;

    %% dados da bateria
    custo_bat = 8000; %(R$)
    cap_bat = Nbat * P_BAT;  % capacidade total das baterias
    efic_descarga = 0.95;    % eficiência de descarga da bateria
    P_D_BAT = 0; % inicialização da variavel auxiliar de potencia de descarga da bat
    P_C_BAT = 0;  % inicialização da variavel auxiliar de potencia de carga
    E_BAT = ones(24,1);  %vetor de energia disponível da bateria no início

    %% dados dos paineis
    custo_pv = 500; %(U$$)
    Noct = 44; % temperatura que o painel chega em 800 W/m2
    Voc = 41.6;  % tensão de circuito aberto
    Isc = 18.32;  % corrente de curto circuito
    Kv = -0.25;  % coeficiente de temperatura para a tensão
    Ki = 0.04; % coeficiente de temperatura para a corrente
    Vmppt = 34.7; % tensão  em ponto de máxima potência
    Imppt = 17.3;  % corrente em ponto de máxima potência
    



    %perfil fotovoltaico (irradiação): #hora do dia #alta #média #baixa
    PV_F = [0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.04   0.0067   0.0037
        0.18   0.0529   0.0251
        0.37   0.1754   0.1134
        0.55   0.2348   0.2133
        0.71   0.2730   0.0719
        0.84   0.3926   0.0909
        0.94   0.3966   0.0946
        0.99   0.5400   0.0669
        0.99   0.5820   0.1214
        0.95   0.6627   0.2144
        0.83   0.4575   0.1745
        0.54   0.3937   0.0989
        0.38   0.2062   0.1393
        0.09   0.0935   0.0505
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000
        0.00   0.0000   0.0000];


    FF = Vmppt * Imppt / (Voc * Isc); % fator de forma
    Tc = Ta + (Noct - 20) / 0.8 * PV_F(:,w);  % temperatura na celula fotovoltaica
    Ic = PV_F(:,w) .* (Isc + Ki * (Tc - 25) ); % corrente fornecida pela celula fotovoltaica
    Vc = Voc + Kv * Tc; % tensão fornecida pela célula fotovoltaica
    EPV = Npv * FF * Vc .* Ic / 1000; % calculo da energia fotovoltaica
    E_disp_PV = 0; % inicialização da variável de energia disponível pelos painéis
    E_disp = EPV; %por enquanto a energia disponível vem apenas dos painéis


    %% laço grande para percorrer a rota
    for i = 1 : N - 1
        m = rota(i);      % m é para correr o índice do ponto de partida
        n = rota(i+1);    % n é para correr o índice do destino

        if m == ec % se o índice atual for correspondente a ec
            t_cheg=round(t_aux); % hora em que chega na ec aproximada
           
            % calcula a distância que falta percorrer visitar os outros nós
            for j = i : N - 1
                d_falta = d_falta + d(rota(j), rota(j+1)); % calcula a distância que falta
                soc_falta = (d_falta * delta) + soc_min;   % calcula a energia q falta
 
              % penaliza caso o estado de carga da bateria necessário para completar a rota for maior que a potencia do VE  
                if soc_falta > P_VE 
                    fo_pen = fo_pen + (soc_falta - P_VE) * beta4;
                end
            end

            %se a autonomia neste ponto for menor a distância que falta
            %percorrer pra terminar a rota, o veículo deve carregar até possuir
            %autonomia suficiente para terminar a rota e voltar ao depósito

            if soc < soc_falta && t_aux < Tmax
                t_carga = t_aux; % definindo para calcular depois o tempo q ficou carregando
                tal = round(t_aux); % aproxima a hora que chega na ec pq perfil é horário
                E_BAT = ones(24,1)*cap_bat; % inicializa vetor da bateria
                E_BAT(tal,1) = cap_bat; % inicializa E_BAT na posição da hora  q chega na EC com cap máxima

                % carrega pelo tempo que precisar até completar o soc_falta
                % e até o hora máxima que tem irradiação
                while soc < soc_falta && tal <= Tmax
                    P_D_BAT = 0;  % potência de descarga da bateria
                    P_C_BAT = 0;  % potência de carga da bateria

                    % se a E_disp nessa hora pelo PV for menor que o que falta pra completar a rota usa energia da bateria
                    if E_disp(tal) < soc_falta - soc
                        P_D_BAT =  P_VE_M - E_disp(tal);  % pot de desc da bat vai receber a P de carregamento max do VE menos a disponível pelo PV
                    elseif E_disp(tal) >= soc_falta - soc   % caso contrário, a energia do PV é > q o necessário p carregar o VE, então carrega a bateria
                        P_C_BAT = E_disp(tal) - (soc_falta - soc); % pot de carga da bat recebe o que sobra do carregamento do VE
                    end

                    %se a energia da bat nesse momento for menor que a pot de descarga da bat, atualiza com a energia da bat
                    if E_BAT(tal) < P_D_BAT/efic_descarga
                        P_D_BAT = E_BAT(tal);
                    end

                    % se a energia da bat mais a pot de carga for maior q
                    % a cap máx da bat, atualiza a energia da bat (para o caso
                    % em que foi carregado a bat pelos pvs)
                    if E_BAT(tal) + P_C_BAT*efic_descarga > cap_bat
                        E_BAT(tal) = cap_bat;
                        P_C_BAT = 0;
                    end

                    % calcula a energia total da bateria no próximo passo:
                    % energia do passo anterior + potencia de carga(qnt carregou) - potência de descarga (qnt descarregou para o VE)
                    E_BAT(tal+1) = E_BAT(tal) + P_C_BAT*efic_descarga - P_D_BAT/efic_descarga;
                    soc = soc + E_disp(tal) + P_D_BAT/efic_descarga; % atualiza o soc com PV e BAT
                    E_carga_VE = P_D_BAT/efic_descarga + E_disp(tal); % calcula a energia q usou pra carregar o VE
%                     E_carga_VE_2 = E_carga_VE + E_carga_VE_2
                    E_disp_PV = sum(E_disp) - sum(E_disp(1:t_cheg-1));  % calcula a energia disp no PV dps que o VE chega
                    tal = tal + 1; % atualiza o passo
                    k = k+1;  % atualiza o passo

                end

                %atualiza o tempo
                t_aux = tal - (soc - soc_falta)/(E_disp(tal-1) + E_BAT(tal-1)); %+ (E_disp(tal - 1) - E_BAT(tal-1)))
                t_carga = t_aux - t_carga;
                % o soc só é atualizado se a energia disponível do PV + bat é suficiente
                % caso não seja suficiente, penaliza
                if E_disp_PV + cap_bat < soc_falta
                    fo_pen = fo_pen + (soc_falta - (E_disp_PV + cap_bat)) * beta5;
                    vetor_soc(k) = soc;
                % caso seja suficiente, atualiza o soc com o necessário p completar a rota
               % elseif(E_disp_PV + cap_bat >= soc_falta)
                end

                % penaliza a FO caso os painéis nao sejam suficientes para carregar a bateria
                if sum(E_disp) < cap_bat
                    fo_pen = fo_pen + (cap_bat - sum(E_disp)) * beta6;
                end

                soc = soc_falta;
                vetor_soc(k) = soc;
                k = k+1; % atualiza o passo de impressão

            end

            % laço pra carregar a bateria com energia vinda do PV qnd o VE
            % não está
         
             for hor = 2:24
               % if hor >= 2 && hor < 24
                if hor>=round(t_cheg +(t_carga)+1) && P_C_BAT < cap_bat %limitado a capacidade da bateria e só carrega quando o VE nao tiver
                    P_C_BAT = E_disp(hor)*efic_descarga + P_C_BAT ; %pot de carga da bat recebe o que sobra do carregamento do VE
                    %E_BAT(hor) = E_BAT(hor-1) + E_disp(hor)*efic_descarga;
                    E_BAT(hor) = E_BAT(hor-1) + P_C_BAT;
                    fo_pen = fo_pen + beta2*P_C_BAT;  % adiciona bonificação caso a bat esteja carregando pelos PVs
                
                    % limita o carregamento até a cap máxima
                    if E_BAT(hor)>cap_bat
                        E_BAT(hor)=cap_bat;
                    end
                end
                % end
            end
        
        end  %fim do laço do nó da estação de carregamento


        %calcula a distância, soc e tempo
        d_percorrida = d_percorrida + d(m,n);
        t_aux = t_aux + t(m,n);
        soc = soc - d(m,n)*delta;
        vetor_soc(k) = soc;
        fo_pen = fo_pen + t_carga * beta1; %penaliza a fo levemente p o tempo de carga
        k = k+1;

        

        %caso a autonomia em algum ponto da rota for menor ou igual a zero,
        %significa que o VE está parado no meio da rota e a solução é
        %infactível - valor da função objetivo muito penalizada
        if soc < soc_min 
             fo_pen = fo_pen + (soc_min - soc) * beta7;
        end

        %penaliza de acordo com o atraso acima do tempo limite
        if t_aux > Tmax && m ~= ec
            fo_pen = fo_pen + beta3 * (t_aux - Tmax);
        end
    end  %fim do laço para percorrer toda a rota

    %%
    % calcula o custo de investimento na função objetivo
    fo_pen = fo_pen +  (Npv * custo_pv) + (Nbat * custo_bat) + dias_ano * alpha * d_percorrida * custo_d;
    fo_media = fo_media + fo_pen;
    w = w + 1;  % atualiza o passo para calcular a função objetivo média

end

vetor_soc_1 = vetor_soc(vetor_soc ~=0);   %tirando o 1 da rota aleatória (1 é sempre o primeiro e último ponto)
vetor_soc_1(1,length(vetor_soc_1)+1) = 0;

vetor_carga(t_cheg+1) = soc_falta;

% calcula o valor da função objetivo esperado
fo = fo_media/3;

PV_F_medio = sum(PV_F,2)/3;
Tc = Ta + (Noct - 20) / 0.8 * PV_F_medio;  % temperatura na celula fotovoltaica
Ic = PV_F_medio .* (Isc + Ki * (Tc - 25) ); % corrente fornecida pela celula fotovoltaica
Vc = Voc + Kv * Tc; % tensão fornecida pela célula fotovoltaica
EPV = Npv * FF * Vc .* Ic / 1000;
E_disp_plot = EPV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% plot de figuras

% % figure
% % plot(PV_F,'linewidth',2)
% % xticks(0:2:24)
% % title('Perfis de Irradiação Solar') 
% % xlabel('Hora')
% % ylabel('Wh/m2')
% % legend('Alta Irradiação', 'Média Irradiação', 'Baixa Irradiação')
% % valor_penalizacao = fo_pen/3
% % valor_investimento = (Npv * custo_pv) + (Nbat * custo_bat)
% % valor_operacao_d = dias_ano * alpha * d_percorrida * custo_d
% % distancia_percorrida = d_percorrida
% % tempo_de_carga = t_carga
% % soc_falta
% 
% % figure
% % plot(E_disp_plot,'g', 'linewidth',2)
% % xticks(0:2:24)
% % hold on
% % plot(E_BAT, 'b', 'linewidth',2)
% % hold on
% % xlabel('Hora')
% % ylabel('kWh')
% % legend('Energia fotovoltaica', 'Energia do banco de baterias')
% % hold off
% 
% % figure
% % plot(vetor_soc_1, 'k-*', 'linewidth',2)
% % xlabel('Estado de carga (SOC) do VE em cada visita')
% % ylabel('kWh')
% 
% figure
% plot(E_disp_plot,'g', 'linewidth',2)
% xticks(0:2:24)
% hold on
% plot(E_BAT, 'b', 'linewidth',2)
% hold on
% title('Energia disponível na microrrede') 
% xlabel('Hora')
% ylabel('kWh')
% legend('Fotovoltaica', 'Baterias')
% % bar(vetor_soc_1)
% % xticks(10:1:24)
% % xlabel('Estado de carga (SOC) do VE em cada visita')
% % ylabel('kWh')
% 
% A = zeros(24,2);
% A(:,1) = E_disp_plot';
% A(:,2) = E_BAT';
% A(:,3) = vetor_carga'/3;
% 
% figure
% bar(A, 'stacked')
% xticks(0:2:24)
% xlabel('Hora')
% ylabel('kWh')
% legend('Energia fotovoltaica', 'Energia das baterias', 'Energia de carregamento do VE')
% xlabel('Hora')
% ylabel('kWh')

end