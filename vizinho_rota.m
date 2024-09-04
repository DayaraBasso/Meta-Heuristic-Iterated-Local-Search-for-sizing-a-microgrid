
function [rota_melhor, fo_melhor, vr] = vizinho_rota(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT, fo_corrente)

%%% rota_corrente = rota de entrada 
%%% rota_viz = rota vizinha à rota corrente
%%% rota_melhor = melhor vizinho da rota corrente
%%% fo_melhor = valor da função objetivo da rota_melhor 

fo_melhor = fo_corrente;
rota_melhor = rota_corrente;
N = length(rota_corrente);
vr = 0;

% laço para percorrer os indices da rota e trocar o nó i com o j
for i = 1 : N-1
    for j = i+1 : N
        rota_viz = rota_corrente;
        rota_viz(i) = rota_corrente(j);
        rota_viz(j) = rota_corrente(i);
        fo_viz = funcaoRotaPVeBat_v3(d, rota_viz, Ta, Npv_corrente, Nbat_corrente, P_BAT);
        vr = vr + 1;
        % atualiza o valor da fo da melhor vizinha
        if fo_viz < fo_melhor
            fo_melhor = fo_viz;
            rota_melhor = rota_viz;
        end
    end
end

end

