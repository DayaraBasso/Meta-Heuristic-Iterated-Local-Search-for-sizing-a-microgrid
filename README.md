Meta Heurística Busca Local Iterada para o dimensionamento de uma microrrede híbrida de alimentação de uma estação de recarga veículos elétricos de comunidades remotas. 

Elaborado por: Dayara Pereira Basso 

Orientação: John Fredy Franco Baquero

Processo FAPESP: 2021/14389-3


Método implementado no MATLAB.

Arquivo "Dissertação Dayara v10.pdf" é o documento de análise dos resultados;

Arquivo "dados_rosana_certo.xlsx" são os dados de distância entre os nós;

Arquivo "funcaoRotaPVeBat_v3.m" é a função objetivo de avaliação das soluções geradas pela meta heurística;

Arquivo "localsearch.m" faz a busca local nos vizinhos da solução;

Arquivos "vizinho_bat.m", "vizinho_npv.m" e "vizinho_rota.m" geram vizinhos do número de baterias, número de painéis fotovoltaicos e da rota, respectivamente;

Arquivo "perturbation.m" faz a perturbação na solução corrente;

Arquivo "main_ILSv1.m" é o script principal que executa todas as funções anteriores e encontra a solução do problema.

Arquivo "teste_media.m" executa um número de vezes a função do script principal e faz a média dos valores encontrados.

