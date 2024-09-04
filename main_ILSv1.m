function [n_iteracoes, n_viz_best, n_vizinhos, solucao_inicial, v_sol, T] = main_ILSv1(Ta, ec, P_BAT)
%% script principal da meta-heurística ILS

% inicialização das variáveis
% pen = 1e6;
max_iter = 100;
i = 0;
h = 1;
q = 1;

%variavéis auxiliares para gerar gráficos


%%  GERAR SOL. INICIAL S0
% S0 = solução inicial = solução corrente
% GERAÇÃO ALEATÓRIA


d = readmatrix('dados_rosana_certo.xlsx'); % lendo os dados de distância  %ec = 9
n = length(d);  % tamanho da matriz de distância
rota_ale = randperm(n);   %gerando uma rota aleatória
rota_inicial = rota_ale(rota_ale ~=1);   %tirando o 1 da rota aleatória (1 é sempre o primeiro e último ponto)
Npv_inicial = randi(100);  %gerando um número de painéis aleatório
Nbat_inicial = randi(100); %gerando um número de baterias aleatório
% rota_inicial = so
% rt(rota_ale(rota_ale ~=1));   %tirando o 1 da rota aleatória (1 é sempre o primeiro e último ponto)
% Npv_inicial = 0;  %gerando um número de painéis aleatório
% Nbat_inicial = 0; %gerando um número de baterias aleatório
incumbente = funcaoRotaPVeBat_v3(d, rota_inicial, Ta, Npv_inicial, Nbat_inicial, P_BAT); % calulando o valor da fo para solução inicial
solucao_inicial = [rota_inicial, Npv_inicial, Nbat_inicial, incumbente];  % vetor solução inicial
fo_solucao_inicial = incumbente;

tic; % para calcular o tempo computacional

%% busca local em S0
% S = busca local (S0) = melhor vizinho de S0
[rota_corrente, Npv_corrente , Nbat_corrente, incumbente, conjunto_sol_lc_s0, vetor_incumbente, conjunto_nbat, conjunto_npv, cont] = localsearch(d, rota_inicial, Ta, Npv_inicial, Nbat_inicial, P_BAT);
n_iteracoes = cont(1); % armazenando o nº de iterações nessa busca local
n_viz_best= cont(2); % armazenando o nº de vizinhos que foram visitados nesta busca local
n_vizinhos = cont(3);

%% gerar S1 = perturbação em S0
% rota_p = rota perturbada, Npv_p = nº painéis pv perturbado [....]
vetor_p = incumbente; % vetor para armazenar as incumbentes
vetor_incumbente_p = incumbente; %vetor auxiliar para armazenar as incumbentes


% enquanto o número máximo de iterações e se não houver melhoria, aplica
% sucessivas operações de perturbação e busca local
while i < max_iter ||h == 1
    h = 0; % variável auxiliar para verificar a melhoria
    cont = 0; % contador de iterações e vizinhos visitados

    %aplica perturbação na solução S
    [rota_p, Npv_p , Nbat_p, fo_p] = perturbation(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT);
    
    %busca o melhor vizinho da solução perturbada
    [rota_melhor_vizp, Npv_melhor_vizp , Nbat_melhor_vizp, fo_melhor_vizp, conjunto_sol_melhorviz, vetor_incumbente, conjunto_nbat_p, conjunto_npv_p, cont] = localsearch(d, rota_p, Ta, Npv_p, Nbat_p, P_BAT);
    n_iteracoes = n_iteracoes + cont(1); %junta os valores de iteração anterior com o novo
    n_viz_best= n_viz_best + cont(2); % junta os valores de vizinhos com o novo
    n_vizinhos= n_vizinhos + cont(3);

    % vetores para armazenar o conjunto de soluções
    conjunto_p = cat(1,[fo_p conjunto_sol_melhorviz]);
    conjunto_bat = cat(1,[Nbat_p conjunto_nbat conjunto_nbat_p]);
    conjunto_pv = cat(1,[Npv_p conjunto_npv conjunto_npv_p]);

    %junta tudo em um vetor para armazenar toda solução visitada
    vetor_p = cat(1, [vetor_p conjunto_p]);
  
    % atualizar incumbente e valores do vetor solução se encontra uma
    % solução vizinha melhor que a incumbente atual
    if fo_melhor_vizp < incumbente
        incumbente = fo_melhor_vizp;
        rota_corrente = rota_melhor_vizp;
        Npv_corrente = Npv_melhor_vizp;
        Nbat_corrente = Nbat_melhor_vizp;

        %vetor incumbente é para armazenar quando tem um melhor vizinho e a incumbente é atualizada
        vetor_incumbente_p(i+1) = fo_melhor_vizp;
        
        % se há melhoria na fo, altera o valor da variável auxiliar para
        % sair do loop
        h = 1; 
    end

    % salva os valores finais
    rota_solfinal = rota_corrente;
    NPV_solfinal = Npv_corrente;
    Nbat_solfinal = Nbat_corrente;
    i = i + 1;   % atualiza o passo
end

% para o contador de tempo
toc;
T = toc;




%% GERAÇÃO DE GRÁFICOS E ANÁLISES DOS RESULTADOS

v_sol = [rota_solfinal, NPV_solfinal, Nbat_solfinal, incumbente];
% [PV_F, E_disp, E_BAT, vetor_soc] = grafico_variaveis(rota_solfinal, ec, Ta, perfil, NPV_solfinal, Nbat_solfinal, P_BAT);
%conjunto_sol = cat(1, [conjunto_sol_corrente conjunto_fo_p conjunto_sol_melhorviz incumbente]) 

%junta todos os valores das fo's das soluções visitadas
conjunto_sol = cat(1, [fo_solucao_inicial conjunto_sol_lc_s0 vetor_p]);
%junta todos os valores de quando a incumbente foi atualizada
conjunto_incumbente = cat(1, [vetor_incumbente vetor_incumbente_p]);

%% laços de impressão

if incumbente <= 1.05e5
    rota_solfinal
    NPV_solfinal
    Nbat_solfinal
    incumbente
    % for j=1:length(conjunto_sol)
    %     if conjunto_sol(j) == incumbente
    %         xtx = j;
    %         ytx = incumbente;
    %     end

   


    % --------------------------------------------------
    % IMPRIME TODAS AS SOLUÇÕES
    figure
    plot(conjunto_sol, 'b-', 'LineWidth',1)
    % yline(1e6, 'r-', 'linewidth',2)
    xlabel ('Número de soluções visitadas')
    ylabel('Valor da função objetivo (R$)')
    legend('Valor da função objetivo (R$) em cada solução visitada')
    % str = {'Melhor Solução'};
    % text(xtx, ytx, str, FontSize=10)


    %-------------------------------------------
    % IMPRIME O NÚMERO DE BATERIAS
    % 
    % tamainho_conjunto_bat= 1:1:length(conjunto_bat);
    % q = 0;
    % for q=1:length(conjunto_bat)
    %     if conjunto_bat(q) == Nbat_solfinal
    %         xbat = q;
    %     end
    %     q = q + 1;
    % end
    % 
    % figure
    % plot(tamainho_conjunto_bat, conjunto_bat,'m-','linewidth',2)
    % hold on
    % set(gca,'box','on');
    % set(gca,'XGrid','on')
    % ylabel('Quantidade de baterias');
    % xlabel('Número de vizinhos testados');
    % % strbat = {'Solução ótima BAT'};
    % % text(xbat, Nbat_solfinal, strbat, FontSize=10)
    % legend('Número de bancos de baterias')
    % 
    % 
    % %-------------------------------------------
    % % IMPRIME O NÚMERO DE PAINÉIS
    % 
    % q = 0;
    % tamainho_conjunto_pv= 1:1:length(conjunto_pv);
    % for q=1:length(conjunto_pv)
    %     if conjunto_pv(q) == NPV_solfinal
    %         xpv = q;
    %     end
    %     q = q + 1;
    % end

    % figure
    % plot(tamainho_conjunto_pv, conjunto_pv,'g-','linewidth',2)
    % hold on
    % set(gca,'box','on');
    % set(gca,'XGrid','on')
    % ylabel('Quantidade de painéis fotovoltaicos');
    % xlabel('Número de vizinhos testados');
    % % strpv = {'Solução ótima PV'};
    % % text(xpv, NPV_solfinal, strpv, FontSize=10)
    % legend('Número de painéis fotovoltaicos')

end 
end



