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

% Last Modified by GUIDE v2.5 02-May-2022 23:27:39

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
set(handles.VoltRadioButtonY,'Value', 1);
set(handles.Sample_on_Substrate,'Value', 1);


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

%Tratamento de erros do usuário
if checkInput(handles)
    warndlg("Todos os campos devem ser preenchidos!","ALERTA");
    return
end

try
    file = handles.file; %Recebe o valor da variável do guidata
catch
    warndlg("Nenhum dado foi importado!!!","ALERTA");
    return;
end

if get(handles.Select_Directory,'String') == "Diretório"
    warndlg("Nenhum diretório foi selecionado!","ALERTA");
    return;
end

ConstS = get(handles.ConstS,'Value');

ConstK = get(handles.ConstK,'Value');
graph_direction = get(handles.GraphDirection,'String');  %Recebe a string do sentido do gráfico

txtIndex = 1;

txtSize = length(file); %Variável responsável por receber o número de arquivos selecionados

%if get(handles.ida_e_volta,'Value') == 1 && txtSize > 2
%    warndlg("Com a opção ida e volta ativada selecionar somente 2 arquivos!","ALERTA");
%    return;
%end

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
    
    try
        TakeLineThenStep = fgetl(mFile); %Muda de linha no arquivo .txt
    catch
        warndlg("Você deve selecionar pelo menos 2 arquivos!","ATENÇÃO");
        return;
    end
    
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

for j=1:txtSize
    for i=1:length(NumXaxis)
        if NumXaxis(i:length(NumXaxis),j) == 0
            NumXaxis(i:length(NumXaxis),j) = nan;
            NumYaxis(i:length(NumYaxis),j) = nan;
            break
        end
    end
end

txtIndex = 1; %Volto o valor da variável para usar no segundo loop

%Aplicando o offset no gráfico eixo Y
NumYaxis = Offset(NumYaxis,NumXaxis, handles); %Função que aplica o offset

%Convertendo os submultiplos de Volt/Ampere
if(get(handles.nVRadioButtonY,'Value'))
    NumXaxis = NumXaxis * 10^9;
    NumYaxis = NumYaxis * 10^9;
end
if(get(handles.mVRadioButtonY,'Value'))
    NumXaxis = NumXaxis * 10^3;
    NumYaxis = NumYaxis * 10^3;
end

%Convertendo de Volt para nm
K = ConstK; %N/m
S = ConstS; %N/V
NumYaxis = NumYaxis * S;

%Convertendo de Volt para nm
NumXaxis = NumXaxis * S;

%A condição abaixo verifica se o radioButton para amostra suspensa está
%marcado e caso verdade o eixo X é convertido para deslocamento
%vertical da amostra, dessa forma é descontada a deflexão da alavanca
%no momento que ela aplica força.
if get(handles.Suspended_Sample,'Value')
    
    %Convertendo o eixo X de deslocamento do piezo para deslocamento
    %vertical da amostra.
    NumXaxis = NumXaxis - NumYaxis; %OBS: Essa subtração esta fazendo o gráfico ficar em x negativo
end

%Convertendo o eixo Y para força
NumYaxis = NumYaxis * K;

%Obtendo a força de adesão
MinYaxis = min(NumYaxis);  %Encontra o ponto de mínimo no Array
% set(handles.AdhesionForce,'string',num2str(MinYaxis)); %Envia para a tela o valor de mínimo

%Salvando a força de adesão dos ensaios da amostra em uma matriz

AF_Matrix = MinYaxis;  %Salvando em uma matriz os valores de K

%Encontrando a média da Força de Adesão e a enviando  para o usuário

AF_Mean = (sum(AF_Matrix)/length(AF_Matrix)); %Média dos valores da matriz
set(handles.AdhesionForce,'string',num2str(AF_Mean));

%Obtendo a Constante Elástica do conjunto alavanca amostra (K)
flipY = flip(NumYaxis); %Invertendo o array das coordenadas Y,X para
flipX = flip(NumXaxis); %que o indice 1 seja a coordenada da origem.

for i=1:1:length(MinYaxis)
    
    %Pegando somente o regime repulsivo
    if i == 1
        allNumXaxis = NumXaxis;
        allNumYaxis = NumYaxis;
        [NumXaxis, NumYaxis] = repulsiveReg(NumXaxis, NumYaxis, handles);
    end
    
    if get(handles.Sample_on_Substrate,'Value')
        %Obtendo o K do conjunto sonda amostra
        x = NumXaxis(1:length(NumXaxis),i);
        y = NumYaxis(1:length(NumYaxis),i);
        kSample(i) = kIndent(x,y, handles);
    elseif get(handles.Suspended_Sample,'Value')
        %Para amostras suspensas o K precisa ser calculado de acordo
        %com o modelo adequando, por esse motivo ele não é calculado e
        %é retornado o valor zero.
        %NumXaxis = flip(NumXaxis);
        kSample(i) = 0;
    end
    
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
    
    sizeXall = size(allNumXaxis);
    fullIdentMatrix(1:sizeXall(1),1) = allNumXaxis(1:sizeXall(1),i);
    fullIdentMatrix(1:sizeXall(1),2) = allNumYaxis(1:sizeXall(1),i);
    
    %Salvando em uma matriz os valores de K e as Forças de todas as identações
    
    K_Force_matrix(line_K_F_matrix, 1) = kSample(i); %A mudança de linha na matriz segue o número referente a que arquivo está sendo processado no loop
    K_Force_matrix(line_K_F_matrix, 2) = MinYaxis(i);
    line_K_F_matrix = line_K_F_matrix + 1;
    
    %Salvando os arquivos gerados em Excel
    FileName = char(file(i));
    FileName = FileName(1:length(FileName));
    comma = FileName == '.';
    FileName(comma) = '_'; %Onde houver pontos substitui por _
    FileName = string(FileName);
    save_name = get(handles.Archive_Name,'String')+ FileName;
    save_directory = get(handles.Select_Directory,'String');
    save_name_full_curve = get(handles.Archive_Name,'String') + FileName + "Curva Completa";
    save_directory = get(handles.Select_Directory,'String');
    
    SaveFile(fullIdentMatrix, i, save_name_full_curve, save_directory, txtSize); %Função que salva o gráfico completo
    SaveFile(identationMatrix, i, save_name, save_directory, txtSize, K_Force_matrix); %Função que salva somemnte repulsivo
    
    %Salvando um arquivo Excel com o valor das contantes K e de Força de
    %cada experimento
    
end

%Encontrando a média da Const. Elática da Amostra e a enviando  para o usuário

K_Mean = (sum(K_Matrix)/length(K_Matrix)); %Média dos valores da matriz
set(handles.ElastConstSample,'string',num2str(K_Mean));

%Gerando o gráfico
if get(handles.Suspended_Sample,'Value')
    figure(1)
    plot(NumXaxis,NumYaxis,'LineWidth',0.5)
    ylabel('Força (nN)'),xlabel('Deflexão vertical da amostra (nm)')
    title('Curva de AFM' + " " + graph_direction)
    grid on
    drawnow
else
    figure(1)
    plot(NumXaxis,NumYaxis,'LineWidth',0.5)
    ylabel('Força (nN)'),xlabel('Deslocamento vertical do piezo (nm)')
    title('Curva de AFM' + " " + graph_direction)
    grid on
    drawnow
end

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

% --- Executes on button press in VoltRadioButtonY.
function VoltRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to VoltRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para nm/V

% Hint: get(hObject,'Value') returns toggle state of VoltRadioButtonY


% --- Executes on button press in mVRadioButtonY.
function mVRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to mVRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para n/V

Status = get(handles.mVRadioButtonY,'Value');
set(handles.mVRadioButtonY,'Value', Status);

% Hint: get(hObject,'Value') returns toggle state of mVRadioButtonY


% --- Executes on button press in nVRadioButtonY.
function nVRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to nVRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para nm/V

Status = get(handles.nVRadioButtonY,'Value');
set(handles.nVRadioButtonY,'Value', Status);

% Hint: get(hObject,'Value') returns toggle state of nVRadioButtonY

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
    return; %Finaliza a função para não causar erro
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
    try
        xlswrite(strcat(save_directory,'\',save_name + " (Ks and Forces)"), K_Force_matrix);
    catch
        
    end
end

function  OffsetNum = Offset(NumYaxis,NumXaxis, handles)

percentageInit = get(handles.Percentage_Start,'Value');
percentageEnd = get(handles.Percentage_End,'Value');

FlippedArrayY = NumYaxis;
FlippedArrayX = NumXaxis;

auxSize = size(NumYaxis);
lastNumberIndex = length(NumXaxis);
aux = true;

for i=1:auxSize(2)
    
    %Aqui é verificado se os números do fim para o início são NaN, caso
    %afirmativo a variável lastNumber é decrementada de 1 em 1 até chegar
    %em um valor que não seja NaN e que é realmente o último número
    while aux
        if ~isnan(NumXaxis(lastNumberIndex,i))
            if NumXaxis(1,i) > NumXaxis(lastNumberIndex,i)
                FlippedArrayY(1:lastNumberIndex,i) = flip(NumYaxis(1:lastNumberIndex,i));  %Inverte a ordem do vetor, pois ele está começando do fim para o início
                FlippedArrayX(1:lastNumberIndex,i) = flip(NumXaxis(1:lastNumberIndex,i));
                aux = false;
            else
                aux = false;
            end
        else
            lastNumberIndex = lastNumberIndex - 1;
        end
    end
    %Aqui é utilizada a posição que o lastNumberIndex contém para definir
    %os pontos iniciais e finais usar length(NumXaxis) não dá certo para os
    %casos em que as colunas possuírem número de linhas diferentes. A
    %primeira linha de valueInit armazena o inpicio da faixa.
    valueInit(1,i) = round((percentageInit/100) * lastNumberIndex) + 1; %Posição correspondente a porcentagem inicial
    valueEnd(2,i) = round((percentageEnd/100) * lastNumberIndex); %Posição correspondente a porcentagem final
    aux = true;
    lastNumberIndex = length(NumXaxis);
end

numFiles = size(NumYaxis);
numFiles = numFiles(2);

%Laço for responsável por tirar os NaNs do arquivo para evitar erro quando
%for realizar o cálculo da equação da reta
for j=1:numFiles
    for i=1:length(FlippedArrayY)
        if isnan(FlippedArrayY(i,j))
            FlippedArrayX(i:length(FlippedArrayY),j) = 0;
            FlippedArrayY(i:length(FlippedArrayY),j) = 0;
            break
        end
    end
end

%aux = FlippedArrayY(valueInit:valueEnd);
%yRangeMean = sum(aux)/length(aux);

aux_2 = size(FlippedArrayY);
aux_2 = aux_2(2);

for i=1:aux_2
    x = FlippedArrayX(valueInit(1,i):valueEnd(2,i),i);
    y = FlippedArrayY(valueInit(1,i):valueEnd(2,i),i);
    p1 = polyfit(x,y,1);
    yFitOffSet = p1(2);
    
    if yFitOffSet < 0        %Se a média for negativa eu somo a média no vetor
        
        auxOffsetNum = -1 * yFitOffSet;     %Aplicando o offset com o valor da média
        OffsetNum(1:length(NumYaxis),i) = NumYaxis(1:length(NumYaxis),i) + auxOffsetNum;
        
    else %Caso contrário eu subtraio a média no vetor
        auxOffsetNum = -1 * yFitOffSet;
        OffsetNum(1:length(NumYaxis),i) = NumYaxis(1:length(NumYaxis),i) + auxOffsetNum;
    end
end


%A função abaixo separa somente o regime repulsivo da identação
function [newXAxis, newYAxis] = repulsiveReg(xAxis, yAxis, handles)

numArc = size(yAxis);
numArc = numArc(2); %Variável que recebe o número de arquivos importados

%if(yAxis(length(yAxis))> yAxis(1))
%    yAxis = flip(yAxis); %Tem que dar um jeito pra quando for gráfico de ida
%end

for i=1:1:numArc
    auxY = yAxis(1:length(yAxis),i);
    auxX = xAxis(1:length(xAxis),i);
    %A condição abaixo faz um teste para saber se a matriz está na ordem
    %crescente, caso não esteja a matriz é invertida. A condição para inverção
    %compara o primeiro elemento com o elemento 10% à frente dele.
    if auxY(i) > auxY(round((length(auxY)/10)))
        yAxis(1:length(yAxis),i) = flip(auxY);
        xAxis(1:length(xAxis),i) = flip(auxX);
    end
end

for i=1:1:numArc
    minValue = min(yAxis);
    minValue = minValue(i); %Ponto de minimo de cada vetor coluna
    minIndex = find(yAxis(1:length(yAxis),i) == minValue);  %Posição do menor valor
    minIndex = minIndex(length(minIndex));
    
    auxNewYAxis = yAxis(minIndex:length(yAxis),i);
    auxIndex = find(auxNewYAxis >= 0);
    
    %A condição abaixo tenta evitar definir o começo de um falso regime
    %repulsivo, isso pode acontecer com sinais ruidosos onde um ponto pode
    %ser de força positiva e em sequencia voltar a ser negativo.
    if auxIndex(1) == (auxIndex(1) + 1)
        auxIndex = auxIndex(1);
    else
        auxIndex = auxIndex(2);
    end
    auxNewXAxis = xAxis(minIndex:length(xAxis),i);
    
    newYAxis(1:length(auxNewYAxis)-auxIndex+1,i) = auxNewYAxis(auxIndex:length(auxNewYAxis),1);
    newXAxis(1:length(auxNewXAxis)-auxIndex+1,i) = auxNewXAxis(auxIndex:length(auxNewYAxis),1) - auxNewXAxis(auxIndex); %Subtração que faz o eixo X começar em 0
end

%Salvando nas matrizes somente os valores maiores que zero após o gráfico
%interceptar o eixo X.
for i=1:1:numArc
    for j=1:1:length(newYAxis)
        if newYAxis(j,i) == 0
            newYAxis(j,i) = NaN;
            newXAxis(j,i) = NaN;
        end
    end
end

% --- Executes on button press in Curve_Visualizer.
function Curve_Visualizer_Callback(hObject, eventdata, handles)
% hObject    handle to Curve_Visualizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.txt', 'MultiSelect', 'off');
if isequal(file,0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path,file)]);
end

txtIndex = 1;
txtSize = length(file);

while txtIndex <= txtSize
    
    auxChangeLine = true;
    i = 1;
    j = 1;
    
    mFile = fopen(string(file),'r'); %Atenção o indice do file deve ser omitido quando houver somente 1 .txt ficando somente file sem e ñ file(x)
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

if NumYaxis(1) > NumYaxis(length(NumYaxis))
    NumYaxis = flip(NumYaxis);  %Inverte a ordem do vetor, pois ele está começando do fim para o início
end

figure
txt_archive(1:length(NumYaxis),1) = 0:100/(length(NumYaxis)-1):100; %Crio o eixo X em função do tamanho do arquivo
txt_archive(1:length(NumYaxis),2) = NumYaxis;                       %para representar a porcentagem dos dados

plot(txt_archive(1:length(txt_archive),1),txt_archive(1:length(txt_archive),2)) %Plota o gráfico

ylabel('Eixo Y'),xlabel('Porcentagem do arquivo')
title('Curva de AFM')
legend(file) %Insere as legendas no gráfico
grid on
drawnow


% --- Executes on button press in Suspended_Sample.
function Suspended_Sample_Callback(hObject, eventdata, handles)
% hObject    handle to Suspended_Sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Sample_on_Substrate,'Value', 0);  %desmarca a caixa de entrada para amostra sob substrato
set(handles.Suspended_Sample,'Value', 1);   %Marca a caixa de entrada para amostra suspensa

% Hint: get(hObject,'Value') returns toggle state of Suspended_Sample


% --- Executes on button press in Sample_on_Substrate.
function Sample_on_Substrate_Callback(hObject, eventdata, handles)
% hObject    handle to Sample_on_Substrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.Sample_on_Substrate,'Value', 1);  %Marca a caixa de entrada para amostra sob substrato
set(handles.Suspended_Sample,'Value', 0);   %Desmarca a caixa de entrada para amostra suspensa

% Hint: get(hObject,'Value') returns toggle state of Sample_on_Substrate

function Percentage_Start_Callback(hObject, eventdata, handles)
% hObject    handle to Percentage_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Init = str2double(get(handles.Percentage_Start,'String'));
set(handles.Percentage_Start,'Value',Init);



% --- Executes during object creation, after setting all properties.
function Percentage_Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Percentage_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Percentage_End_Callback(hObject, eventdata, handles)
% hObject    handle to Percentage_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
End = str2double(get(handles.Percentage_End,'String'));
set(handles.Percentage_End,'Value',End);


% --- Executes during object creation, after setting all properties.
function Percentage_End_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Percentage_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Suspended_Sample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Suspended_Sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function kSample = kIndent(NumXaxis,NumYaxis, ~)
for i=1:1:length(NumXaxis)
    if ~isnan(NumXaxis(i))
        x = NumXaxis(i);
        y = NumYaxis(i);
    end
end
p1 = polyfit(x,y,1);
kSample = p1(1);

function response = checkInput(handles)
if get(handles.Archive_Name,'String') == ""
    response = 1;
elseif get(handles.ConstS,'String') == ""
    response = 1;
elseif get(handles.ConstK,'String') == ""
    response = 1;
elseif get(handles.Percentage_Start,'String') == ""
    response = 1;
elseif get(handles.Percentage_End,'String') == ""
    response = 1;
else
    response = 0;
end
