#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

VENV_NAME="myenv"

check_python_version() {
  python_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
  
  if [[ "$(printf '%s\n' "3.8" "$python_version" | sort -V | head -n1)" != "3.8" ]]; then
      echo -e "${RED}错误：需要 Python 3.8 或更高版本${RESET}"
      exit 1
  fi
}

create_env_file() {
  if [ ! -f ".env" ]; then
      echo -e "${YELLOW}未找到 .env 文件，正在自动创建...${RESET}"
      
      cat > .env << EOL
# 系统配置文件
IS_TEMP_CONVERSATION=true
IS_CUSTOM_SSO=false
API_KEY=your_api_key
PICGO_KEY=your_picgo_key
TUMY_KEY=your_tumy_key
PROXY=http://127.0.0.1:5200
MANAGER_SWITCH=false
ADMINPASSWORD=admin123
CF_CLEARANCE=your_cloudflare_clearance
PORT=5200
SHOW_THINKING=true
ISSHOW_SEARCH_RESULTS=true
SSO=ssoCookie1;ssoCookie2;ssoCookie3
EOL
      
      echo -e "${GREEN}.env 文件已创建${RESET}"
      echo -e "${YELLOW}请手动编辑 .env 文件并配置您的密钥和设置${RESET}"
      exit 0
  fi
}

create_venv() {
  if [ ! -d "$VENV_NAME" ]; then
      echo -e "${GREEN}创建虚拟环境...${RESET}"
      python3 -m venv "$VENV_NAME"
  fi
}

main() {
  create_env_file

  check_python_version

  create_venv

  source "$VENV_NAME/bin/activate"

  python3 -m pip install --upgrade pip

  echo -e "${GREEN}安装依赖...${RESET}"
  pip install --no-cache-dir \
      flask flask_cors requests curl_cffi \
      werkzeug datetime python-dotenv loguru

  if [ $? -ne 0 ]; then
      echo -e "${RED}依赖安装失败${RESET}"
      deactivate
      exit 1
  fi

  echo -e "${GREEN}启动应用...${RESET}"
  python3 app.py

  deactivate
}

chmod +x "$0"

main