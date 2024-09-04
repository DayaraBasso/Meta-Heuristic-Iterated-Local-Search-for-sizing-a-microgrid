

function [Npv_melhor, fo_melhor, vp] = vizinho_npv(rota_corrente, ec, Ta, Npv_corrente, Nbat_corrente, P_BAT, fo_corrente)
    
%%% Npv_corrente = nº de painéis fotovoltaicos de entrada 
%%% Npv_viz_mais = nº de pv vizinho  para mais de Npv_corrente
%%% Npv_viz_menos = nº de pv vizinho para menos  de Npv_corrente
%%% Npv_melhor = melhor vizinho do Npv_corrente
%%% fo_melhor = valor da função objetivo do Npv_melhor 


% inicia as variáveis
    Npv_melhor = Npv_corrente;
    fo_melhor = fo_corrente;
    vp = 0;

    % se o limite superior não for violado, há espaço para aumentar o número de painéis 
    if Npv_corrente < 100
        Npv_viz_mais = Npv_corrente + 1;
        fo_mais = funcaoRotaPVeBat_v3(rota_corrente, ec, Ta, Npv_viz_mais, Nbat_corrente, P_BAT);
        vp = vp + 1;

        % se a fo deste vizinho acima for melhor que a corrente, atualiza
        if fo_mais < fo_melhor
            Npv_melhor = Npv_viz_mais;
            fo_melhor = fo_mais;
        end
    end
  
    % se o limite inferior nao for violado, há espaço para diminuir o número de painéis    
    if Npv_corrente >= 1
        Npv_viz_menos = Npv_corrente - 1;
        fo_menos = funcaoRotaPVeBat_v3(rota_corrente, ec, Ta, Npv_viz_menos, Nbat_corrente, P_BAT);
        vp = vp + 1;
        % se a fo deste vizinho abaixo for melhor que a corrente, atualiza
        if fo_menos < fo_melhor
            Npv_melhor = Npv_viz_menos;
            fo_melhor = fo_menos;
        end
    end
end