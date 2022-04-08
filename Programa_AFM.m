function varargout = Programa_AFM(varargin)
% PROGRAMA_AFM MATLAB code for Programa_AFM.fig
%      PROGRAMA_AFM, by itself, creates a new PROGRAMA_AFM or raises the existing
%      singleton*.
%
%      H = PROGRAMA_AFM returns the handle to a new PROGRAMA_AFM or the handle to
%      the existing singleton*.
%
%      PROGRAMA_AFM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRAMA_AFM.M with the given input arguments.
%
%      PROGRAMA_AFM('Property','Value',...) creates a new PROGRAMA_AFM or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before Programa_AFM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Programa_AFM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Programa_AFM

% Last Modified by GUIDE v2.5 31-Mar-2022 22:18:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Programa_AFM_OpeningFcn, ...
    'gui_OutputFcn',  @Programa_AFM_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Programa_AFM is made visible.
function Programa_AFM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Programa_AFM (see VARARGIN)

% Choose default command line output for Programa_AFM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%Definição das condições iniciais do programa
set(handles.ConstS2,'Enable','off');
set(handles.VoltRadioButtonY,'Value', 1);
set(handles.idaOuVolta,'Value', 1);


% UIWAIT makes Programa_AFM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Programa_AFM_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ImportData1.
function ImportData1_Callback(hObject, eventdata, handles)
% hObject    handle to ImportData1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.txt', 'MultiSelect', 'on');
if isequal(file,0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path,file)]);
end

%Enviando o valor da variável pelo guidata

handles.file = file;
guidata(hObject,handles)

% --- Executes on button press in StartButton1.
function StartButton1_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = handles.file; %Recebe o valor da variável do guidata

if get(handles.AmpereRadioButtonY,'Value') ~= 1    %Verifica se o usuário escolheu Volt
    ConstS = get(handles.ConstS,'Value');
    
elseif get(handles.AmpereRadioButtonY, 'Value') == 1  %Verifica se o usuário escolheu Ampere
    ConstS = get(handles.ConstS2,'Value');
end

ConstK = get(handles.ConstK,'Value');
graph_direction = get(handles.GraphDirection,'String');  %Recebe a string do sentido do gráfico

txtIndex = 1;

txtSize = length(file); %Variável responsável por receber o número de arquivos selecionados

%Colocando título nas duas colunas da matriz
K_Force_matrix(1,1) = "K Amostra";
K_Force_matrix(1,2) = "Força de Adesão";
line_K_F_matrix = 2; %Variável responsável por mudar a minha da matriz que salva os Ks e Forças

%Pegando os dados do .txt e alimentando o vetor
j = 1;
while txtIndex <= txtSize
    
    auxChangeLine = true;
    i = 1;
    
    mFile = fopen(string(file(txtIndex)),'r'); %Atenção o indice do file deve ser omitido quando houver somente 1 .txt ficando somente file sem e ñ file(x)
    TakeLineThenStep = fgetl(mFile); %Muda de linha no arquivo .txt
    
    while auxChangeLine  %While responsável em pegar cada elemento do .txt e salvar em um vetor
        
        TakeLineThenStep = fgetl(mFile);
       
        if TakeLineThenStep ~= -1  %Essa condição verifica se chegou ao final do arquivo .txt
            %Variável i são as linhas da matriz, j são as colunas
            %Coluna 1 referente ao .txt 1 coluna 2 referente ao .txt 2...
            stringNum = regexp(TakeLineThenStep, '\t', 'split'); %Muda de linha no arquivo .txt e separa as strings do vetor
            NumXaxis(i,j) = str2double(stringNum(1)); %Seleciono o índice do vetor onde está a string que necessito e salvo em outro vetor
            NumYaxis(i,j) = str2double(stringNum(2));
        else
            auxChangeLine = false;
        end
     
        i = i + 1;
    end
    txtIndex = txtIndex + 1;
    j = j + 1;
end

%Laço necessário para remover os zeros adicionados nas colunas quando uma
%delas é maior que a outra, o que causa problemas por inserir valores
%inexistentes no arquivo inicial.
for i=1:length(NumXaxis)
    aux = i + 3;
    if NumXaxis(i:aux,1) == 0
        NumXaxis(i:length(NumXaxis),1) = nan;
        NumYaxis(i:length(NumYaxis),1) = nan;
        break
    elseif NumXaxis(i:aux,2) == 0
        NumXaxis(i:length(NumXaxis),2) = nan;
        NumYaxis(i:length(NumYaxis),2) = nan;
        break
    end
end

txtIndex = 1; %Volto o valor da variável para usar no segundo loop
    
ida_e_volta = get(handles.ida_e_volta,'Value');
    
    if ida_e_volta == false
        
        %Aplicando o offset no gráfico eixo Y        
        NumYaxis = Offset(NumYaxis); %Função que aplica o offset
        
    else  
        %Teste para saber se é o gráfico de ida
        %Em seguida é somado o quanto de offset é necessário.
        if NumYaxis(1,1) < NumYaxis(length(NumYaxis)/4,1)
           NumAux = NumYaxis(1:length(NumYaxis));
           offset = Offset(NumAux);
           NumYaxis = NumYaxis + offset;
        elseif NumYaxis(1,2) < NumYaxis(length(NumYaxis)/4,2)
            NumAux = NumYaxis(1:length(NumYaxis));
            offset = Offset(NumAux);
            NumYaxis = NumYaxis + offset;
        end       
    end
    
    %Convertendo os submultiplos de Volt
    if(get(handles.nVRadioButtonY,'Value'))
        NumXaxis = NumXaxis * 10^9;
        NumYaxis = NumYaxis * 10^9;
    end
    if(get(handles.mVRadioButtonY,'Value'))
        NumXaxis = NumXaxis * 10^3;
        NumYaxis = NumYaxis * 10^3;
    end
    
    %Convertendo de Volt para nN
    K = ConstK; %N/m
    S = ConstS; %N/V
    NumYaxis = NumYaxis * K * S;
    
    %Convertendo de Volt para nm
    NumXaxis = NumXaxis * S;
    
    %Obtendo a força de adesão
    MinYaxis = min(NumYaxis);  %Encontra o ponto de mínimo no Array
    % set(handles.AdhesionForce,'string',num2str(MinYaxis)); %Envia para a tela o valor de mínimo
    
    %Salvando a força de adesão dos ensaios da amostra em uma matriz
    
    AF_Matrix = MinYaxis;  %Salvando em uma matriz os valores de K
    
    %Encontrando a média da Força de Adesão e a enviando  para o usuário
    
    AF_Mean = (sum(AF_Matrix)/length(AF_Matrix)); %Média dos valores da matriz
    set(handles.AdhesionForce,'string',num2str(AF_Mean));
    
    %Obtendo a Constante Elástica do conjunto alavanca amostra (K)
    
    flipY = flip(NumYaxis); %Invertendo o array das coordenadas Y,X para que o indice 1 seja a coordenada da origem
    flipX = flip(NumXaxis);
    
    for i=1:1:length(MinYaxis)
        
        minimumIndex(i) = find(flipY(1:length(flipY),i) == MinYaxis(i),1,'last');  %Obtendo a posição do ponto de mínimo no array NumYaxis
        lastIndex(i) = minimumIndex(length(minimumIndex)); %Indice do último número do ponto mínimo
        IndexStart(i) = lastIndex(i) + 20; %Pequena distância do ponto de mínimo para evitar oscilações no início da reta
        IndexAnd(i) = length(NumYaxis); %Último índice do array

        Yend(i) = flipY(IndexAnd(i));
        Ystart(i) = flipY(IndexStart(i));
        Xend(i) =  flipX(IndexAnd(i));
        Xstart(i) =  flipX(IndexStart(i));

        kSample(i) = abs((Yend(i) - Ystart(i))/(Xend(i) - Xstart(i))); %Calculando a inclinação da reta

        %set(handles.ElastConstSample,'string',kSample); %Enviando para o usuário a inclinação da reta

        %Salvando os valores de K dos ensaios das amostras em uma matriz

        line_K = 1;
        K_Matrix(line_K,1) = kSample(i);  %Salvando em uma matriz os valores de K
        line_K = line_K + 1;
    
        %Salvando NumXaxis e NumYaxis em uma matriz
        sizeX = size(NumXaxis);
        sizeX = sizeX(1);
        sizeY = size(NumYaxis);
        sizeY = sizeY(1);
        identationMatrix(1:sizeX(1),1) = NumXaxis(1:sizeX(1),i);  %Preencho a matriz coluna 1 e linhas até o tamanho do arrayX
        identationMatrix(1:sizeY(1),2) = NumYaxis(1:sizeY(1),i);  %Preencho a matriz coluna 2 e linhas até o tamanho do arrayY

        %Salvando em uma matriz os valores de K e as Forças de todas as identações

        K_Force_matrix(line_K_F_matrix, 1) = kSample(i); %A mudança de linha na matriz segue o número referente a que arquivo está sendo processado no loop
        K_Force_matrix(line_K_F_matrix, 2) = MinYaxis(i);
        line_K_F_matrix = line_K_F_matrix + 1;
        
        %Salvando os arquivos gerados em Excel
        save_name = get(handles.Archive_Name,'String');
        save_directory = get(handles.Select_Directory,'String');
    
        SaveFile(identationMatrix, i, save_name, save_directory, txtSize, K_Force_matrix); %Função que salva
    
        %Salvando um arquivo Excel com o valor das contantes K e de Força de
        %cada experimento
        
    end
    
    %Encontrando a média da Const. Elática da Amostra e a enviando  para o usuário
    
    K_Mean = (sum(K_Matrix)/length(K_Matrix)); %Média dos valores da matriz
    set(handles.ElastConstSample,'string',num2str(K_Mean));
    
    %Gerando o gráfico
    
        figure(1)
        plot(NumXaxis,NumYaxis,'LineWidth',0.5)
        ylabel('Força (nN)'),xlabel('Deslocamento do piezo (nm)')
        title('Curva de AFM' + " " + graph_direction)
        grid on
        drawnow
    
    
    
    txtIndex = txtIndex + 1; %Incrementando a variável do loop principal
    
    %Limpando as variáveis
    clear NumXaxis;
    clear NumYaxis;
    clear identationMatrix;



function ConstS_Callback(hObject, eventdata, handles)
% hObject    handle to ConstS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

S = str2double(get(handles.ConstS,'string'));
set(handles.ConstS,'Value', S);


% --- Executes during object creation, after setting all properties.
function ConstS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConstS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ConstK_Callback(hObject, eventdata, handles)
% hObject    handle to ConstK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

K = str2double(get(handles.ConstK,'string'));
set(handles.ConstK,'Value', K);


% --- Executes during object creation, after setting all properties.
function ConstK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConstK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ConstS2_Callback(hObject, eventdata, handles)
% hObject    handle to ConstS2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

S = str2double(get(handles.ConstS2,'string'));
set(handles.ConstS2,'Value', S);

% Hints: get(hObject,'String') returns contents of ConstS2 as text
%        str2double(get(hObject,'String')) returns contents of ConstS2 as a double


% --- Executes during object creation, after setting all properties.
function ConstS2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConstS2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in VoltRadioButtonY.
function VoltRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to VoltRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS2,'Enable','off');  %Desativa a caixa de entrada para nm/A
set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para nm/V

% Hint: get(hObject,'Value') returns toggle state of VoltRadioButtonY


% --- Executes on button press in mVRadioButtonY.
function mVRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to mVRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS2,'Enable','off');  %Desativa a caixa de entrada para n/A
set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para n/V

Status = get(handles.mVRadioButtonY,'Value');
set(handles.mVRadioButtonY,'Value', Status);

% Hint: get(hObject,'Value') returns toggle state of mVRadioButtonY


% --- Executes on button press in nVRadioButtonY.
function nVRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to nVRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS2,'Enable','off');  %Desativa a caixa de entrada para nm/A
set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para nm/V

Status = get(handles.nVRadioButtonY,'Value');
set(handles.nVRadioButtonY,'Value', Status);



% Hint: get(hObject,'Value') returns toggle state of nVRadioButtonY


% --- Executes on button press in AmpereRadioButtonY.
function AmpereRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to AmpereRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS2,'Enable','on');  %Ativa a caixa de entrada para nm/A
set(handles.ConstS,'Enable','off');    %Desativa a caixa de entrada para nm/V

% Hint: get(hObject,'Value') returns toggle state of AmpereRadioButtonY


% --- Executes on button press in nmRadioButtonX.
function nmRadioButtonX_Callback(hObject, eventdata, handles)
% hObject    handle to nmRadioButtonX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nmRadioButtonX


% --- Executes on button press in VoltRadioButtonX.
function VoltRadioButtonX_Callback(hObject, eventdata, handles)
% hObject    handle to VoltRadioButtonX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VoltRadioButtonX


% --- Executes on button press in AmpereRadioButtonX.
function AmpereRadioButtonX_Callback(hObject, eventdata, handles)
% hObject    handle to AmpereRadioButtonX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AmpereRadioButtonX


function GraphDirection_Callback(hObject, eventdata, handles)
% hObject    handle to GraphDirection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

direction = (get(handles.GraphDirection,'string'));
set(handles.GraphDirection,'String', direction);

% Hints: get(hObject,'String') returns contents of GraphDirection as text
%        str2double(get(hObject,'String')) returns contents of GraphDirection as a double


% --- Executes during object creation, after setting all properties.
function GraphDirection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GraphDirection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AdhesionForce_Callback(hObject, eventdata, handles)
% hObject    handle to AdhesionForce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AdhesionForce as text
%        str2double(get(hObject,'String')) returns contents of AdhesionForce as a double


% --- Executes during object creation, after setting all properties.
function AdhesionForce_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdhesionForce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ElastConstSample_Callback(hObject, eventdata, handles)
% hObject    handle to ElastConstSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ElastConstSample as text
%        str2double(get(hObject,'String')) returns contents of ElastConstSample as a double


% --- Executes during object creation, after setting all properties.
function ElastConstSample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ElastConstSample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Select_Directory_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_directory = uigetdir('C:\','Selecione uma pasta para salvar');
set(handles.Select_Directory,'String',save_directory);

% Hints: get(hObject,'String') returns contents of Select_Directory as text
%        str2double(get(hObject,'String')) returns contents of Select_Directory as a double


% --- Executes during object creation, after setting all properties.
function Select_Directory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Select_Directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Archive_Name_Callback(hObject, eventdata, handles)
% hObject    handle to Archive_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

archiveName = get(handles.Archive_Name,'String');
set(handles.Archive_Name,'String',archiveName);

% Hints: get(hObject,'String') returns contents of Archive_Name as text
%        str2double(get(hObject,'String')) returns contents of Archive_Name as a double


% --- Executes during object creation, after setting all properties.
function Archive_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Archive_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GraphDirectory.
function GraphDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to GraphDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.xls', 'MultiSelect', 'on');
if isequal(file,0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path,file)]);
end

numb_sel_graph = length(file); %Obtendo quantos gráficos foram selecionados


for i = 1:1:numb_sel_graph
    hold on
    grid on
    figure(1)
    directory = fullfile(path, file(i));        %Pega o diretório do arquivo
    xls_archive = xlsread(string(directory));   %Lê o arquivo excel e salva em xls_archive
    
    plot(flip(xls_archive(1:length(xls_archive),1)),flip(xls_archive(1:length(xls_archive),2))) %Plota os gráficos
    
end

ylabel('Força (nN)'),xlabel('Deslocamento do piezo (nm)')
title('Multiplas Curvas de AFM')
legend(file) %Insere as legendas no gráfico

% --- Executes on button press in ImportData2.
function ImportData2_Callback(hObject, eventdata, handles)
% hObject    handle to ImportData2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.xls', 'MultiSelect', 'on');
if isequal(file,0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path,file)]);
end

%Enviando o valor da variável pelo guidata

handles.file = file;
handles.path = path;
guidata(hObject,handles)


% --- Executes on button press in StartButton2.
function StartButton2_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = handles.file; %Recebe o valor da variável do guidata
path = handles.path;

xlsIndex = 1;
aux = 1;

archivesNumber = length(data); %Variável responsável por receber o número de arquivos selecionados
directory = fullfile(path, data(1));
xls_archive = xlsread(string(directory));

while aux <= archivesNumber
    i = 1;
    directory = fullfile(path, data(i));
    xls_archive = xlsread(string(directory));
    while xlsIndex <= length(xls_archive)
                  
        NumXaxis(i,xlsIndex) = xls_archive(xlsIndex,1); %Seleciono o índice do vetor onde está a string que necessito e salvo em outro vetor
        NumYaxis(i,xlsIndex) = xls_archive(xlsIndex,2);
        
        i = i + 1;
        xlsIndex = xlsIndex + 1;
    end
    aux = aux + 1;
end

firstMatrix = NumXaxis(1:length(NumXaxis),1); %Preenchendo as matrizes 1 e 2 com os valores do 1° e 2° arquivo respectivamente;
firstMatrix = NumYaxis(1:length(NumYaxis),1);
secondMatrix = NumXaxis(1:length(NumXaxis),2);
secondMatrix = NumYaxis(1:length(NumYaxis),2);

minPointFirstMatrix = min(firstMatrix);
minPointSecondMatrix = min(secondMatrix);

if minPointFirstMatrix < minPointSecondMatrix     %Esse if tem a função de decobrir qual matrix contém o gráfico de ida e volta
    matrixBack = firstMatrix;                     %Isso é importante para realizar corretamente a integral e achar a área correta
    matrixOut = secondMatrix;
else
    matrixBack = secondMatrix;
    matrixOut = firstMatrix;
end

energyDissipation = trapz(matrixBack,matrixOut) %Calculando a área entre as curvas

set(handles.EnergyDissipation,'string', energyDissipation); %Enviando para o usuário a energia dissipada



function EnergyDissipation_Callback(hObject, eventdata, handles)
% hObject    handle to EnergyDissipation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EnergyDissipation as text
%        str2double(get(hObject,'String')) returns contents of EnergyDissipation as a double


% --- Executes during object creation, after setting all properties.
function EnergyDissipation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EnergyDissipation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in idaOuVolta.
function idaOuVolta_Callback(hObject, eventdata, handles)
% hObject    handle to idaOuVolta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.idaOuVolta,'Value', 1);  %Marca a caixa de entrada para idaOuVolta
set(handles.ida_e_volta,'Value', 0);  %Desmarca a caixa de entrada para idaOuVolta

% Hint: get(hObject,'Value') returns toggle state of idaOuVolta


% --- Executes on button press in ida_e_volta.
function ida_e_volta_Callback(hObject, eventdata, handles)
% hObject    handle to ida_e_volta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ida_e_volta,'Value', 1);  %Marca a caixa de entrada para ida_e_volta
set(handles.idaOuVolta,'Value', 0);    %Desmarca a caixa de entrada para idaOuVolta

% Hint: get(hObject,'Value') returns toggle state of ida_e_volta

function OffsetWentTurn_Callback(hObject, eventdata, handles)
% hObject    handle to ida_e_volta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
get(handles.StartButton1,'Value', identationMatrix)

function SaveFile(identationMatrix, txtIndex, archiveName, directory, txtSize, K_Force_matrix)

save_name = archiveName;
save_name_concat = save_name + " " + num2str(txtIndex); %Aqui eu utilizo a variável txtIndex para enumerar os arquivos e salvar com nome diferentes

if (directory == "Diretório") %Verifica se foi selecionado um diretório
    save_directory = uigetdir('C:\','Selecione uma pasta para salvar');
else
    save_directory = directory;
end
xlswrite(strcat(save_directory,'\',save_name_concat), identationMatrix);

if (txtIndex == txtSize)
    xlswrite(strcat(save_directory,'\',save_name + " (Ks and Forces)"), K_Force_matrix);
end

function  OffsetNum = Offset(NumYaxis)

if NumYaxis(1) > NumYaxis(length(NumYaxis))
    
    FlippedArrayY = flip(NumYaxis);  %Inverte a ordem do vetor, pois ele está começando do fim para o início
    
else
    FlippedArrayY = NumYaxis;
end

averageY = sum(FlippedArrayY(1:1))/1;  %Faço a média com os 150 primeiros valores

if averageY < 0        %Se a média for negativa eu somo a média no vetor
    
    OffsetNum = -1 * averageY;     %Aplicando o offset com o valor da média
    
else %Caso contrário eu subtraio a média no vetor
    OffsetNum = -1 * averageY;
end
