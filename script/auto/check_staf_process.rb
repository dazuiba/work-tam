exec_result = `STAF localhost PING PING`
if exec_result.split("\n")[2] == "PONG"
	p "ok!"
else
	`sudo /usr/local/staf/startSTAFProc.sh`
end
p "finished!"