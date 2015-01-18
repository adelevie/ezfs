git pull origin master
bundle
if [ ! -f db/config.yml ]; then
  cp db/config.yml.sample db/config.yml
  echo "Created config.yml"
  echo "To edit, type:"
  echo "nano db/config.yml"
fi
