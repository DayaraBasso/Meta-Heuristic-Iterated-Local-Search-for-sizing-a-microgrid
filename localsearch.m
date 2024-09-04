function [rota_nova, Npv_nova, Nbat_nova, fo_melhor_viz, conjunto_sol, vetor_incumbente, conjunto_nbat, conjunto_npv, cont] = localsearch(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT)

% inicialização de variáveis 
conjunto_sol = 0;
conjunto_nbat = 0;
conjunto_npv = 0;
vetor_incumbente = 0;
n_viz_best = 0;
i = 1;
rota_nova = rota_corrente;
Npv_nova = Npv_corrente;
Nbat_nova = Nbat_corrente;
a = 1;

 % laço para fazer busca local em todos os vizinhos até não encontrar um
 % vizinho melhor
while a == 1
    a = 0;
    
    % inicializa a incumbente com os valores da solução corrente
    fo_corrente = funcaoRotaPVeBat_v3(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT);
    fo_melhor_viz = fo_corrente;

    % aplica a função para encontrar o melhor vizinho da rota corrente
    [rota_melhor, fo_melhor_rota, vr] = vizinho_rota(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT, fo_corrente);

    % atualiza a incumbente se essa solução for melhor que a anterior
    if fo_melhor_rota < fo_melhor_viz
        a = 1;
        n_viz_best = n_viz_best + 1; % atualiza um contador para ver quantos vizinhos está visitando
        fo_melhor_viz  = fo_melhor_rota;
        rota_nova = rota_melhor;
        Npv_nova = Npv_corrente;
        Nbat_nova = Nbat_corrente;
    end

    % aplica a função para encontrar o melhor vizinho do número de painéis
    [Npv_melhor, fo_melhor_NPV, vp] = vizinho_npv(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT, fo_corrente);
      
    % atualiza a incumbente se essa solução for melhor que a anterior
    if fo_melhor_NPV < fo_melhor_viz
        a = 1;
        n_viz_best = n_viz_best + 1; % atualiza um contador para ver quantos vizinhos está visitando
        fo_melhor_viz = fo_melhor_NPV;
        rota_nova = rota_corrente;
        Npv_nova = Npv_melhor;
        Nbat_nova  = Nbat_corrente;
    end

    % aplica a função para encontrar o melhor vizinho do número de baterias
    [Nbat_melhor, fo_melhor_Nbat, vb] = vizinho_bat(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT, fo_corrente);
    
    % atualiza a incumbente se essa solução for melhor que a anterior
    if fo_melhor_Nbat < fo_melhor_viz
        a = 1;
        n_viz_best = n_viz_best + 1; % atualiza um contador para ver quantos vizinhos está visitando
        fo_melhor_viz = fo_melhor_Nbat;
        rota_nova = rota_corrente;
        Npv_nova = Npv_corrente;
        Nbat_nova = Nbat_melhor;
    end

%     conjunto_sol(i) = fo_melhor_viz;
%     conjunto_nbat(i) = Nbat_nova;
%     conjunto_npv(i) = Npv_nova;

    % atualizando caso entre em um vizinho melhor
    if a == 1
        rota_corrente = rota_nova;
        Npv_corrente= Npv_nova;
        Nbat_corrente = Nbat_nova;
        [v_sol] = [rota_corrente, Npv_corrente, Nbat_corrente, fo_melhor_viz];
        vetor_incumbente(i) = fo_melhor_viz;
        i = i+1;
    end

end

vizinhos = vr + vp + vb;

% um vetor para armazenar quantas iterações houveram e o nº de vizinhos
% visitados
cont = cat(1, [i-1 n_viz_best vizinhos]);


% figure 
% plot(conjunto_sol, '-s', 'LineWidth',2,'MarkerSize',5,'MarkerEdgeColor','auto')
% title('Conjunto de Soluções')
% xlabel ('Iteração')
% ylabel('Valor da FO')
% str = {'Melhor Soluçao'};

end