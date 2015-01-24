portslay () {
   # portslay:  kill the task active on the specified TCP port
   kill -9 `lsof -i tcp:$1 | tail -1 | awk '{ print $2;}'`
}

source .env
portslay 4567
rackup -p 4567 -D
