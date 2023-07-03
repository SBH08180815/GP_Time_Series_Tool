function varargout = Gaussian1(varargin)
% GAUSSIAN1 MATLAB code for Gaussian1.fig
%      GAUSSIAN1, by itself, creates a new GAUSSIAN1 or raises the existing
%      singleton*.
%
%      H = GAUSSIAN1 returns the handle to a new GAUSSIAN1 or the handle to
%      the existing singleton*.
%
%      GAUSSIAN1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAUSSIAN1.M with the given input arguments.
%
%      GAUSSIAN1('Property','Value',...) creates a new GAUSSIAN1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Gaussian1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Gaussian1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Gaussian1

% Last Modified by GUIDE v2.5 19-Oct-2022 12:32:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gaussian1_OpeningFcn, ...
                   'gui_OutputFcn',  @Gaussian1_OutputFcn, ...
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


% --- Executes just before Gaussian1 is made visible.
function Gaussian1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Gaussian1 (see VARARGIN)

% Choose default command line output for Gaussian1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Gaussian1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Gaussian1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global num
num=get(handles.popupmenu1,'Value');
if num==1
    msgbox("Time is MJD,and the unit of data is mm!");
else
    msgbox("Time is Year,and the unit of data is mm!");
end

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fn,path]=uigetfile('*.xlsx','Open training data');
filename=fullfile(path,fn);%Gets the absolute path to the file
set(handles.edit10,'string',filename);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit_10=get(handles.edit10,'string');
tab=xlsread(edit_10,1);
time=tab(:,1);
time_series_data=tab(:,2);  
type=get(handles.popupmenu1,'Value');
if(type==1)%The choice is GNSS(IGS)
    %Gaussian regression model
    gprMdl= fitrgp(time,time_series_data,'Basis',@(X) [ones(size(X,1),1),(X-time(1))./365.25,sin(2.*pi.*(X-time(1))/365.25),cos(2.*pi.*(X-time(1))/365.25)],'Beta',[1;1;1;1],...
      'FitMethod','exact','PredictMethod','exact','KernelFunction','matern32','KernelParameters',[1;1],'Sigma',1,'OptimizeHyperparameters','auto','Optimizer','quasinewton','ComputationMethod','qr','OptimizeHyperparameters','auto','ActiveSetMethod','likelihood','ActiveSetSize',150);
    %Get the predicted data and confidence intervals corresponding to the time
    [ypred,~,yint] = predict(gprMdl,time);
    edit_11=get(handles.edit11,'string');
    %Whether to make prediction for the specified time
    if(edit_11~="")
        tab0=xlsread(edit_11,1);
        time0=tab0(:,1);
        [ypred0,~,yint0] = predict(gprMdl,time0);
        data0=[{'time0','ypred0','yint0(down)','yint0(up)'};num2cell([time0,ypred0,yint0(:,1),yint0(:,2)])];
        xlswrite('GP_prediciton_results.xlsx',data0);
    end
    %Hyperparameters
    beta_parameter=gprMdl.Beta;
    sigmaL=gprMdl.KernelInformation.KernelParameters(1);
    sigmaF=gprMdl.KernelInformation.KernelParameters(2);
    sigma=gprMdl.Sigma;
    set(handles.edit1,'string',num2str(roundn(beta_parameter(1),-3)));
    set(handles.edit2,'string',num2str(roundn(beta_parameter(2),-3)));
    set(handles.edit3,'string',num2str(roundn(beta_parameter(3),-3)));
    set(handles.edit4,'string',num2str(roundn(beta_parameter(4),-3)));
    set(handles.edit5,'string',num2str(roundn(sigmaL,-3)));
    set(handles.edit6,'string',num2str(roundn(sigmaF,-3)));
    set(handles.edit7,'string',num2str(roundn(sigma,-3)));
    %Obtain hyperparameter covariance matrix of the mean function through the law of error propagation
    cov=h_gnss(time,time(1),sigmaL,sigmaF,sigma);
    %Obtain the velocity error
    accuracy=sqrt(cov(2,2));
    set(handles.edit8,'string',strcat(num2str(roundn(beta_parameter(2),-3)),"+/-",num2str(roundn(accuracy,-3))));
    data=[{'time','ypred','yint(down)','yint(up)'};num2cell([time,ypred,yint(:,1),yint(:,2)])];
    xlswrite('GP_results.xlsx',data);
    %Residual plot   
    figure
    plot(time,time_series_data-ypred,'.k','MarkerSize',10),xlabel('MJD'),title('Residual result');
    axis tight;
    msgbox({'Operation Completed!','The results are output to the current directory'},'Done');
end

if(type==2)%The choice is GRACE(EWH)
    %Gaussian regression model
    gprMdl= fitrgp(time-time(1),time_series_data,'Basis',@(X) [ones(size(X,1),1),(X)./1,sin(2.*pi.*(X)/1),cos(2.*pi.*(X)/1)],'Beta',[1;1;1;1],...
      'FitMethod','exact','PredictMethod','exact','KernelFunction','matern32','KernelParameters',[1;1],'Sigma',1,'OptimizeHyperparameters','auto','Optimizer','quasinewton','ComputationMethod','qr','OptimizeHyperparameters','auto','ActiveSetMethod','likelihood','ActiveSetSize',150);
    %Get the predicted data and confidence intervals corresponding to the time
    [ypred,~,yint] = predict(gprMdl,time-time(1));
    edit_11=get(handles.edit11,'string');
    %Whether to make prediction for the specified time
    if(edit_11~="")
        tab0=xlsread(edit_11,1);
        time0=tab0(:,1);
        [ypred0,~,yint0] = predict(gprMdl,time0-time(1));
        data0=[{'time0','ypred0','yint0(down)','yint0(up)'};num2cell([time0,ypred0,yint0(:,1),yint0(:,2)])];
        xlswrite('GP_prediciton_results.xlsx',data0);
    end
    %Hyperparameters
    beta_parameter=gprMdl.Beta;
    sigmaL=gprMdl.KernelInformation.KernelParameters(1);
    sigmaF=gprMdl.KernelInformation.KernelParameters(2);
    sigma=gprMdl.Sigma;
    set(handles.edit1,'string',num2str(roundn(beta_parameter(1),-3)));
    set(handles.edit2,'string',num2str(roundn(beta_parameter(2),-3)));
    set(handles.edit3,'string',num2str(roundn(beta_parameter(3),-3)));
    set(handles.edit4,'string',num2str(roundn(beta_parameter(4),-3)));
    set(handles.edit5,'string',num2str(roundn(sigmaL,-3)));
    set(handles.edit6,'string',num2str(roundn(sigmaF,-3)));
    set(handles.edit7,'string',num2str(roundn(sigma,-3)));
    %Obtain hyperparameter covariance matrix of the mean function through the law of error propagation
    cov=h_grace(time-time(1),sigmaL,sigmaF,sigma);
    %Obtain the velocity error
    accuracy=sqrt(cov(2,2));
    set(handles.edit8,'string',strcat(num2str(roundn(beta_parameter(2),-3)),"+/-",num2str(roundn(accuracy,-3))));
    data=[{'time','ypred','yint(down)','yint(up)'};num2cell([time,ypred,yint(:,1),yint(:,2)])];
    xlswrite('GP_results.xlsx',data);
    %Residual plot 
    figure
    plot(time,time_series_data-ypred,'.k','MarkerSize',10),xlabel('Year'),title('Residual result');
    axis tight;
    msgbox({'Operation Completed!','The results are output to the current directory'},'Done');
end

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fn,path]=uigetfile('*.xlsx','Open prediction time data');
filename=fullfile(path,fn);
set(handles.edit11,'string',filename);

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
