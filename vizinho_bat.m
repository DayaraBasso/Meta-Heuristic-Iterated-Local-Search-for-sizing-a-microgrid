function [Nbat_melhor, fo_melhor, vb] = vizinho_bat(d, rota_corrente, Ta, Npv_corrente, Nbat_corrente, P_BAT, fo_corrente)
    
%%% Nbat_corrente = nº de bancos de bateria de entrada 
%%% Nbat_viz_mais = nº de bancos de bateria vizinho para mais de Nbat_corrente
%%% Nbat_viz_menos = nº de bancos de bateroa vizinho para menos de Nbat_corrente
%%% Nbat_melhor = melhor vizinho da Nbat_corrente
%%% fo_melhor = valor da função objetivo da Nbat_melhor 
 
    % inicializa os valores de saída, caso nenhum vizinho seja melhor que o
    % corrente
    Nbat_melhor = Nbat_corrente;
    fo_melhor = fo_corrente;
    vb = 0;
    % se o limite superior não for violado, há espaço para aumentar o
    % número de baterias
    if Nbat_corrente <100
        Nbat_viz_mais = Nbat_corrente + 1;
        fo_mais = funcaoRotaPVeBat_v3(d, rota_corrente, Ta, Npv_corrente, Nbat_viz_mais, P_BAT);
        vb = vb + 1;

        % se a fo deste vizinho acima for melhor que a corrente, atualiza
        if fo_mais < fo_melhor
            Nbat_melhor = Nbat_viz_mais;
            fo_melhor = fo_mais;
        end
    end
  
    % se o limite superior não for violado, há espaço para aumentar o
    % número de baterias
    if Nbat_corrente > 1
        Nbat_viz_menos = Nbat_corrente - 1;
        fo_menos = funcaoRotaPVeBat_v3(d, rota_corrente, Ta, Npv_corrente, Nbat_viz_menos, P_BAT);
        vb = vb + 1;

        % se a fo deste vizinho acima for melhor que a corrente, atualiza
        if fo_menos < fo_melhor
            Nbat_melhor = Nbat_viz_menos;
            fo_melhor = fo_menos;
        end
    end
end
