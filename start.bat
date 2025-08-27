@chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion

set "PYTHONIOENCODING=utf-8"

set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "RESET=[0m"

set "VENV_NAME=myenv"

:check_and_create_env
if not exist ".env" (
  echo %YELLOW%未找到 .env 文件，正在自动创建...%RESET%
  
  (
      echo # 系统配置文件
      echo IS_TEMP_CONVERSATION=true
      echo IS_CUSTOM_SSO=false
      echo API_KEY=your_api_key
      echo PICGO_KEY=your_picgo_key
      echo TUMY_KEY=your_tumy_key
      echo PROXY=http://127.0.0.1:5200
      echo MANAGER_SWITCH=false
      echo ADMINPASSWORD=admin123
      echo CF_CLEARANCE=your_cloudflare_clearance
      echo PORT=5200
      echo SHOW_THINKING=true
      echo ISSHOW_SEARCH_RESULTS=true
      echo SSO=ssoCookie1;ssoCookie2;ssoCookie3
  ) > .env
  
  echo %GREEN%.env 文件已创建%RESET%
  echo %YELLOW%请手动编辑 .env 文件并配置您的密钥和设置%RESET%
  pause
  exit /b 0
)

for /f "tokens=2 delims=." %%a in ('python --version 2^>^&1 ^| findstr /R "^Python [0-9]"') do set "PYTHON_VERSION=%%a"

if %PYTHON_VERSION% LSS 8 (
  echo %RED%错误：需要 Python 3.8 或更高版本%RESET%
  pause
  exit /b 1
)

if not exist "%VENV_NAME%" (
  echo %GREEN%创建虚拟环境...%RESET%
  python -m venv %VENV_NAME%
)

call %VENV_NAME%\Scripts\activate

python -m pip install --upgrade pip

echo %GREEN%安装依赖...%RESET%
pip install --no-cache-dir flask flask_cors requests curl_cffi werkzeug datetime python-dotenv loguru

if %ERRORLEVEL% NEQ 0 (
  echo %RED%依赖安装失败%RESET%
  deactivate
  pause
  exit /b 1
)

echo %GREEN%启动应用...%RESET%
python app.py

deactivate

pause