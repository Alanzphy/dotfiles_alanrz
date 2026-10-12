venv() {
  # Check if already activated
  if [[ "$VIRTUAL_ENV" != "" ]]; then
      echo -e "\n\e[1;33mDeactivating current virtual environment...\e[0m"
      deactivate
      return
  fi

  # Detect if .venv or venv directory exists
  if [ -d ".venv" ]; then
      echo -e "\n\e[1;33mActivating .venv virtual environment...\e[0m"
      source .venv/bin/activate
  elif [ -d "venv" ]; then
      echo -e "\n\e[1;33mActivating venv virtual environment...\e[0m"
      source venv/bin/activate
  else
      echo -e "\n\e[1;33mCreating and activating .venv virtual environment...\e[0m"
      python3 -m venv .venv
      source .venv/bin/activate
  fi
}
