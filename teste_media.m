function [fo_t, Nbat_t, Npv_t, media_fo, media_Npv, media_Nbat, media_tempo, media_niter, media_nvizbest, media_nvizinhos] = teste_media(Ta, ec, P_BAT)
%% função para rodar 100 vezes a meta-heurística ILS, ver a média e encontrar a melhor solução

% inicialização das variáveis
fo_t = 0;
pen = 1e6;
Nbat_t = 0;
Npv_t = 0;
T_t = 0;
max_iter = 100;
tic;

% laço para rodar 100 vezes a ILS
for i=1:max_iter
    [n_iteracoes, n_viz_best, n_vizinhos, ~, v_sol, T] = main_ILSv1(Ta,ec,P_BAT); % salva o vetor solução e o tempo computacional
    N = length(v_sol); % salva o tamanho do vetor solução
    fo_t(i) = v_sol(N); % o úlitmo valor do vetor solução é o valor da fo
    Nbat_t(i) = v_sol(N-1); % o penúltimo valor do vetor solução é o nº de baterias
    Npv_t(i) = v_sol(N-2);  % o antepenúltimo valor do vetor solução é o nº de painéis
    n_iter(i) = n_iteracoes;
    n_vizinhos_best(i) = n_viz_best;
    n_viz(i) = n_vizinhos;
    T_t = T_t + T;  % soma o tempo total de cada iteração para rodar a ILS
    T_tt(i) = T;
    i = i + 1;    % atualiza o passo

end

% laço para encontrar a melhor solução dentre as 100 
for j = 1:max_iter
    if fo_t(j) == min(fo_t)
        BS = [Npv_t(j) Nbat_t(j) fo_t(j)]; % salva um vetor best solution contendo o menor valor da FO e os valores de Nbat e Npv para essa FO
    end
    j = j +1;  %atualiza o passo
end 

% calcula os valores médios
media_fo = sum(fo_t)/max_iter;
media_Npv = round(sum(Npv_t)/max_iter);
media_Nbat = round(sum(Nbat_t)/max_iter);
media_tempo = T_t/max_iter;
media_niter = round(sum(n_iter)/max_iter);
media_nvizbest= round(sum(n_vizinhos_best)/max_iter);
media_nvizinhos = round(sum(n_viz)/max_iter);


T_t
BS
x_plot = 1:1:max_iter;
sz = 50;
c = linspace(1,10,length(x_plot));

%%1 impressao do Npv em função da FO OK
figure
scatter(Npv_t, fo_t,sz,c, 'filled')
% yline(pen, 'r-', 'linewidth',1)
xlabel ('Quantidade de painéis fotovoltaicos')
ylabel('Valor da função objetivo (R$)')
% legend('Número de Painéis Fotovoltaicos')

% %%1 impressao do Nbat em função da FO OK
figure
scatter(Nbat_t, fo_t,sz,c, 'filled')
% yline(pen, 'r-', 'linewidth',1)
xlabel ('Quantidade de baterias')
ylabel('Valor da função objetivo (R$)')
% legend('Número de Baterias') 

%%% 2 impressao da de Nbat em função de FO OK
% figure
% scatter(Npv_t, fo_t, 'filled')
% hold on
% scatter(Nbat_t, fo_t, 'filled')
% yline(pen, 'r-', 'linewidth',1)
% xlabel ('Dimensionamento da Microrrede')
% ylabel('Valor da Função Objetivo (U$$)')
% legend('Número de Painéis Fotovoltaicos','Número de Baterias', 'Infactibilidade')

%%% 3 impressao da fo em função de x
figure
semilogy(x_plot, fo_t, 'b-','linewidth',2)
% yline(pen, 'r-', 'linewidth',1)
xlabel ('Execução de Verificação')
ylabel('Valor da função objetivo (R$)')
legend('Valor da função objetivo (R$)', 'Infactibilidade')

%%% 4 impressão do Nbat e Npv juntos
% figure
% hold on
% plot(x_plot, Npv_t, 'g-','linewidth',1)
% plot(x_plot, Nbat_t, 'm-','linewidth',1)
% xlabel ('Execução de Verificação')
% ylabel('Dimensionamento da microrrede')
% legend('Número de painéis fotovoltaicos', 'Número de baterias')

% %%% 5 impressão do Nbat e Npv em função da FO juntas
% figure 
% plot(Npv_t, fo_t, 'g-','linewidth',1)
% hold on
% xlabel('Dimensionamento da microrrede')
% ylabel('Valor da Função Objetivo (U$$)')
% legend('Número de painéis fotovoltaicos')

% %%% 5 impressão do Nbat e Npv em função da FO juntas
% figure 
% plot(Nbat_t, fo_t, 'g-','linewidth',1)
% hold on
% xlabel('Dimensionamento da microrrede')
% ylabel('Valor da Função Objetivo (U$$)')
% legend('Número de painéis fotovoltaicos')

%%% 4 impressão do Nbat e Npv juntos
figure
hold on
scatter(Npv_t, Nbat_t,sz,c, 'MarkerEdgeColor',[0 .5 .5],'MarkerFaceColor',[0 .7 .7],'LineWidth',1.5)
hold on
scatter(BS(1), BS(2), 'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0],'LineWidth',1.5)
xlabel ('Número de painéis fotovoltaicos')
ylabel('Número de baterias')
title('Dimensionamento da microrrede')
legend('Painéis fotovoltaicos X Baterias', 'Melhor solução encontrada')



%%% 6 impressão do número de vizinhos e do número de iterações da ILS em cada
% rodada
figure
hold on
plot(x_plot, n_viz,	'*-','linewidth',1)
hold on
plot(x_plot, n_iter,'o-','linewidth',1)
% hold on
% plot(x_plot, n_vizinhos_best,'o-','linewidth',1)
legend('Número de vizinhos em cada ILS', 'Número de iterações em cada ILS')
xlabel('Execução de verificação')
ylabel('Quantidade em cada execução da ILS')


figure
plot(x_plot,T_tt, 'r-', 'LineWidth',2)
xlabel ('Iteração da ILS')
ylabel('Tempo de execução (s)')
% legend('Valor da Função Objetivo (U$$) em cada solução visitada')

end