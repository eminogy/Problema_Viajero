%Teodoro Emiliano Noriega González 
%Control Inteligente 
%Grupo 4MM4
%15/01/2024
%Problema del viajero 

%Algoritmo Genético (GA):

%Definición: Es un método de optimización y búsqueda inspirado en la evolución biológica.
%Funcionamiento: Utiliza conceptos de selección natural, crossover (recombinación genética), 
%y mutación para evolucionar una población de soluciones hacia la obtención de soluciones óptimas o cercanas a óptimas.
%Aplicaciones: Se utiliza en problemas de optimización, búsqueda y selección de soluciones en espacios de búsqueda complejos.

%1. Inicialización: Se genera una población inicial de posibles rutas.
%2. Evaluación: Se evalúa la calidad de cada ruta en la población, calculando la distancia total recorrida.
%3. Selección: Se seleccionan rutas en función de su calidad. En este código, se seleccionan las mejores rutas de la población actual.
%4. Cruce (crossover): Se aplican operaciones de cruce entre rutas seleccionadas para generar nuevas rutas.
%5. Mutación: Se aplican operaciones de mutación a algunas rutas para introducir variabilidad.
%6. Reemplazo: Se reemplazan las rutas menos efectivas con las nuevas generadas.
%7. Iteración: Los pasos 2-6 se repiten durante un número específico de iteraciones.

function varargout = tspofs_ga(xy,dmat,popSize,numIter,showProg,showResult)
% La función tspofs_ga resuelve el Problema del Viajero utilizando un Algoritmo Genético (GA).

% Procesa las entradas e inicializa los valores predeterminados
nargs = 6;
for k = nargin:nargs-1
    switch k
        case 0
            % Si no se proporciona XY, se generan ubicaciones aleatorias
            xy = 10*rand(50,2);
        case 1
            % Si no se proporciona DMAT, se calcula a partir de XY
            N = size(xy,1);
            a = meshgrid(1:N);
            dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),N,N);
        case 2
            % Tamaño predeterminado de la población
            popSize = 100;
        case 3
            % Número predeterminado de iteraciones
            numIter = 1e4;
        case 4
            % Mostrar progreso por defecto
            showProg = 1;
        case 5
            % Mostrar resultados por defecto
            showResult = 1;
        otherwise
    end
end

%Esta sección maneja las entradas de la función y establece valores predeterminados si no se proporcionan.
%xy son las coordenadas de las ciudades, dmat es una matriz de distancias entre las ciudades.
%Si no se proporcionan xy o dmat, se generan aleatoriamente.
%popSize es el tamaño de la población del algoritmo genético, numIter es el número de iteraciones, y 
% showProg y showResult controlan la visualización.


% Verifica las entradas
[N,dims] = size(xy);
[nr,nc] = size(dmat);
if N ~= nr || N ~= nc
    error('Invalid XY or DMAT inputs!')
end
n = N - 1; % Ciudad de inicio separada

%Asegura que xy y dmat sean entradas válidas.
%n es el número de ciudades, tomando una ciudad como punto de inicio.

% Verificaciones de cordura
popSize = 4*ceil(popSize/4);
numIter = max(1,round(real(numIter(1))));
showProg = logical(showProg(1));
showResult = logical(showResult(1));

%Realiza ajustes para asegurarse de que popSize sea un múltiplo de 4, numIter sea al menos 1, 
%y convierte showProg y showResult en valores lógicos.
%En la sección de operadores genéticos, las rutas se seleccionan de cuatro en cuatro (for p = 4:4:popSize). 
%Cada conjunto de cuatro rutas es mutado para producir tres nuevas rutas. Si el tamaño de la población (popSize) no es un múltiplo de 4,
%podría haber problemas en la aplicación de estos operadores genéticos, 
%ya que no se garantizaría que haya un número adecuado de conjuntos de cuatro rutas.

% Inicializa la población
pop = zeros(popSize,n);
pop(1,:) = (1:n) + 1;
for k = 2:popSize
    pop(k,:) = randperm(n) + 1;
end

%Inicializa la población de rutas. Cada ruta representa un posible viaje 
%que visita cada ciudad exactamente una vez.

% Ejecuta el Algoritmo Genético (GA)
globalMin = Inf;
totalDist = zeros(1,popSize);
distHistory = zeros(1,numIter);
tmpPop = zeros(4,n);
newPop = zeros(popSize,n);
if showProg
    pfig = figure('Name','TSPOFS_GA | Current Best Solution','Numbertitle','off');
end
for iter = 1:numIter
    
    % Evalúa cada miembro de la población (Calcula la distancia total)
    for p = 1:popSize
        d = dmat(1,pop(p,1)); % Agrega la distancia desde la ciudad de inicio
        for k = 2:n
            d = d + dmat(pop(p,k-1),pop(p,k));
        end
        totalDist(p) = d;
    end

%Inicia el bucle principal del algoritmo genético.
%Calcula la distancia total de cada ruta en la población.

    % Encuentra la mejor ruta en la población
    [minDist,index] = min(totalDist);
    distHistory(iter) = minDist;
    if minDist < globalMin
        globalMin = minDist;
        optRoute = pop(index,:);
        if showProg
            % Grafica la mejor ruta
            figure(pfig);
            rte = [1 optRoute];
            if dims > 2
                plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-', ...
                    xy(1,1),xy(1,2),xy(1,3),'ro');
            else
                plot(xy(rte,1),xy(rte,2),'r.-',xy(1,1),xy(1,2),'ro');
            end
            title(sprintf('Total Distance = %1.4f, Iteration = %d',minDist,iter));
        end
    end

%Encuentra la mejor ruta en la población actual.
%Si la nueva mejor ruta es mejor que la global, actualiza la mejor ruta global.
%Si showProg es verdadero, visualiza la mejor ruta encontrada.

 % Operadores del Algoritmo Genético
randomOrder = randperm(popSize); % Genera un orden aleatorio para la población
for p = 4:4:popSize
    rtes = pop(randomOrder(p-3:p),:); % Selecciona rutas según el orden aleatorio
    dists = totalDist(randomOrder(p-3:p)); % Calcula distancias totales de las rutas seleccionadas
    [ignore,idx] = min(dists); %#ok
    bestOf4Route = rtes(idx,:); % Obtiene la mejor ruta de las seleccionadas
    routeInsertionPoints = sort(ceil(n*rand(1,2))); % Selecciona puntos de inserción aleatorios
    I = routeInsertionPoints(1);
    J = routeInsertionPoints(2);
    for k = 1:4 % Mutación de la mejor ruta para obtener tres nuevas rutas
        tmpPop(k,:) = bestOf4Route;
        switch k
            case 2 % Flip (inversión de la ruta)
                tmpPop(k,I:J) = tmpPop(k,J:-1:I);
            case 3 % Swap (intercambio de dos ciudades)
                tmpPop(k,[I J]) = tmpPop(k,[J I]);
            case 4 % Slide (desplazamiento de un segmento de la ruta)
                tmpPop(k,I:J) = tmpPop(k,[I+1:J I]);
            otherwise % No hacer nada
        end
    end
    newPop(p-3:p,:) = tmpPop; % Reemplaza las rutas originales con las mutadas en la nueva población
end
pop = newPop; % Actualiza la población original con la nueva población mutada
end

%Aplica operadores genéticos para generar nuevas rutas a partir de las mejores rutas seleccionadas.
%randomOrder determina el orden en que se aplican los operadores genéticos.
%bestOf4Route es la mejor ruta seleccionada de un grupo de 4 rutas aleatorias.
%routeInsertionPoints determina dos puntos de inserción aleatorios para la mutación.
%Se inspira en el concepto de mutación en la evolución biológica, donde se producen cambios aleatorios en los genes de un organismo.
%Realización de la mutación: Dependiendo de la estrategia de mutación, puede haber diferentes formas de alterar la ruta.
% Algunas estrategias comunes incluyen:

%Flip (Inversión): Se invierte el orden de las ciudades entre dos puntos.
%Swap (Intercambio): Se intercambian dos ciudades en la ruta.
%Slide (Deslizamiento): Se desplaza un segmento de la ruta a una nueva posición.


if showResult
    % Grafica los resultados del Algoritmo Genético
    figure('Name','TSPOFS_GA | Results','Numbertitle','off');
    subplot(2,2,1);
    pclr = ~get(0,'DefaultAxesColor');
    if dims > 2, plot3(xy(:,1),xy(:,2),xy(:,3),'.','Color',pclr);
    else plot(xy(:,1),xy(:,2),'.','Color',pclr); end
    title('City Locations');
    subplot(2,2,2);
    imagesc(dmat([1 optRoute],[1 optRoute]));
    title('Distance Matrix');
    subplot(2,2,3);
    rte = [1 optRoute];
    if dims > 2
        plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-', ...
            xy(1,1),xy(1,2),xy(1,3),'ro');
    else
        plot(xy(rte,1),xy(rte,2),'r.-',xy(1,1),xy(1,2),'ro');
    end
    title(sprintf('Total Distance = %1.4f',minDist));
    subplot(2,2,4);
    plot(distHistory,'b','LineWidth',2);
    title('Best Solution History');
    set(gca,'XLim',[0 numIter+1],'YLim',[0 1.1*max([1 distHistory])]);
end

%Visualiza los resultados del algoritmo genético.
%La primera gráfica muestra las ubicaciones de las ciudades.
%La segunda muestra la matriz de distancias.
%La tercera muestra la mejor ruta encontrada.
%La cuarta muestra la evolución de la mejor solución a lo largo de las iteraciones.

% Devuelve los resultados
if nargout
    varargout{1} = optRoute;
    varargout{2} = minDist;
end

%Devuelve la mejor ruta (optRoute) y la distancia total mínima (minDist) como salidas de la función.

