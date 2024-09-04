
function [rota_p, Npv_p , Nbat_p, fo_p] = perturbation(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT)
%% pertubação em s
k = 0.5; % fator para aumentar o número de painéis e baterias

%% perturbação em todos os valores da solução
rota_p = ptb_rota(rota_corrente);
Npv_p = Npv_corrente + round(k*Npv_corrente);
Nbat_p = Nbat_corrente + round(k*Nbat_corrente);
fo_p = funcaoRotaPVeBat_v3(d, rota_p, Ta, Npv_p, Nbat_p, P_BAT);

end


function [rota_p] = ptb_rota(rota)
% rota = rota de entrada a ser perturbada
% rota_p = rota de saida que foi perturbada
%Para fazer isso, foi implementado uma operação para troca de pares da rota, frequentemente utilizada no problema comum de roteamento de veículos. Além disso, foi implementado um algoritmo de perturbação geral que aleatoriamente muda os valores que compõem o dimensionamento da microrrede e neste mesmo algoritmo uma técnica para inversão da rota. São aplicadas aleatoriamente ao todo 4 operações de perturbação na solução ótima local, visando dar um salto na vizinhança, assim como demonstra a Figura 7.
%A priori, o Algoritmo 6 demonstra como foi implementado uma perturbação separada para rota, em que se recebe uma rota inicial, rota, e gerada uma rota perturbada, rota_P. São escolhidos aleatoriamente dois números entre o tamanho da rota, para servir como troca de nós, w e y. Se w=y, ou vice-versa, adicionar mais um termo e então fazer a troca de pares com um passo a frente, isto é, o cliente que seria visitado na posição y-1 será realocado para ser visitado em w-1, e w-1 será visitado na ordem de y-1. A Figura 11 representa um exemplo de como este algoritmo procede.

% inicializa as variáveis
rota_p = rota;

% escolhe um número aleatório de 1 até o tamanho da rota para compor o par
% de índices que será invertido
w = randi(size(rota));
y = randi(size(rota));
% % 
% % % verifica se os índices não são iguais, se forem iguais nao haverá troca de
% % %pares
if w ~= y
    % faz a troca de pares
    rota_p(w) = rota(y);
    rota_p(y) = rota(w);
end

end





   
