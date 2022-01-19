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
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Programa_AFM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Programa_AFM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Programa_AFM

% Last Modified by GUIDE v2.5 14-Dec-2021 14:17:52

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


% --- Executes on button press in Import_Data.
function Import_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Import_Data (see GCBO)
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

% --- Executes on button press in StartButon.
function StartButon_Callback(hObject, eventdata, handles)
% hObject    handle to StartButon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


file = handles.file; %Recebe o valor da variável do guidata

if get(handles.VoltRadioButtonY,'Value') == 1   %Verifica se o usuário escolheu Volt
    ConstS = get(handles.ConstS,'Value');   
    
elseif get(handles.AmpereRadioButtonY, 'Value') == 1  %Verifica se o usuário escolheu Ampere
    ConstS = get(handles.ConstS2,'Value');
end

ConstK = get(handles.ConstK,'Value');

mFile = fopen(string(file(2)),'r'); %Atenção o indice do file deve ser omitido quando ouver somente 1 .txt ficando somente file sem e ñ file(x)

TakeLineThenStep = fgetl(mFile); %Muda de linha no arquivo .txt

condition = true;
i = 1;

%Pegando os dados do .txt e alimentando o vetor

while condition
    
    TakeLineThenStep = fgetl(mFile);
    
    if TakeLineThenStep ~= -1  %Essa condição verifica se chegou ao final do arquivo .txt
        
       stringNum = regexp(TakeLineThenStep, '\t', 'split'); %Muda de linha no arquivo .txt e separa as strings do vetor
       NumXaxis(i) = str2double(stringNum(1)); %Seleciono o índice do vetor onde está a string que necessito e salvo em outro vetor
       NumYaxis(i) = str2double(stringNum(2));
     
    else 
       condition = false;
    end
    i = i + 1;
end

 %Aplicando o offset no gráfico eixo Y
 
 FlippedArrayY = flip(NumYaxis);  %Inverte a ordem do vetor, pois ele está começando do fim para o início
 
 averageY = sum(FlippedArrayY(1:150))/150;  %Faço a média com os 150 primeiro valores
 
 if averageY < 0        %Se a média for negativa eu somo a média no vetor
     NumYaxis = NumYaxis + (-1 * averageY);     %Aplicando o offset com o valor da média
     
 else %Caso contrário eu subtraio a média no vetor
      NumYaxis = NumYaxis - averageY;
 end
 
 %Convertendo de Volt para nN
 K = ConstK; %N/m
 S = ConstS; %N/V
 NumYaxis = NumYaxis * K * S;
 
 %Convertendo de Volt para nm
 NumXaxis = NumXaxis * S;
 
 %Obtendo a força de adesão
     MinYaxis = min(NumYaxis);  %Encontra o ponto de mínimo no Array
     set(handles.AdhesionForce,'string',num2str(MinYaxis)); %Envia para a tela o valor de mínimo

 %Obtendo a Constante Elástica da Amostra (K)
 
 flipY = flip(NumYaxis); %Invertendo o array das coordenadas Y,X para que o indice 1 seja a coordenada da origem
 flipX = flip(NumXaxis);
 
 minimumIndex = find(flipY == MinYaxis);  %Obtendo a posição do ponto de mínimo no array NumYaxis
 lastIndex = minimumIndex(length(minimumIndex)); %Indice do último número do ponto mínimo
 IndexStart = lastIndex + 20; %Pequena distância do ponto de mínimo para evitar oscilações no início da reta
 IndexAnd = length(NumYaxis); %Último índice do array
 
 Yend = flipY(IndexAnd);
 Ystart = flipY(IndexStart);
 Xend =  flipX(IndexAnd);
 Xstart =  flipX(IndexStart);
 
 kSample = abs((Yend - Ystart)/(Xend - Xstart)); %Calculando a inclinação da reta
 
 set(handles.ElastConstSample,'string',kSample); %Enviando para o usuário a inclinação da reta
 
 %Salvando os valores de K das amostras em uma matriz
 
 line_kM = 1;
 kMatrix(line_kM,1) = kSample;  %Salvando em uma matriz os valores de K
 line_kM = line_kM + 1;
 
 %Salvando NumXaxis e NumYaxis em uma matriz
     sizeX = size(NumXaxis);
     sizeX = sizeX(2);
     sizeY = size(NumYaxis);
     sizeY = sizeY(2);
     identationMatrix(1:sizeX,1) = NumXaxis(1:sizeX);  %Preencho a matriz coluna 1 e linhas até o tamanho do arrayX
     identationMatrix(1:sizeY,2) = NumYaxis(1:sizeY);  %Preencho a matriz coluna 2 e linhas até o tamanho do arrayY

 %Gerando o gráfico
 
     figure(1)
     plot(NumXaxis,NumYaxis,'LineWidth',0.5)
     ylabel('Força (nN)'),xlabel('Deslocamento do piezo (nm)')
     title('Curva de AFM')
     grid on
     drawnow
     
 %Salvando os arquivos gerados em Excel
 
    save_name = get(handles.Archive_Name,'String');
    if (get(handles.Select_Directory,'String') == "Diretório")
    save_directory = uigetdir('C:\','Selecione uma pasta para salvar');
    else
        save_directory = get(handles.Select_Directory,'String');
    end
    xlswrite(strcat(save_directory,'\',save_name), identationMatrix);

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

        set(handles.ConstS2,'Enable','off');  %Desativa a caixa de entrada para nm/A
        set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para nm/V
        
% Hint: get(hObject,'Value') returns toggle state of mVRadioButtonY


% --- Executes on button press in nVRadioButtonY.
function nVRadioButtonY_Callback(hObject, eventdata, handles)
% hObject    handle to nVRadioButtonY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        set(handles.ConstS2,'Enable','off');  %Desativa a caixa de entrada para nm/A
        set(handles.ConstS,'Enable','on');    %Garante a ativação da caixa de entrada para nm/V

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
