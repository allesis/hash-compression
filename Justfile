REMOTE_USERNAME := `echo ${REMOTE_USERNAME}`
REMOTE_IP := `echo ${REMOTE_IP}`
REMOTE_DIRECTORY := `echo ${REMOTE_DIRECTORY}`
all VIDEO: (run VIDEO) (convert VIDEO) (test VIDEO)
[working-directory: 'rav1e']
run VIDEO:
	just run {{VIDEO}}
[working-directory: 'rav1d']
convert VIDEO:
	just convert {{VIDEO}}
[working-directory: 'vqmtk']
test VIDEO:
	just test {{VIDEO}}
[working-directory: 'vqmtk']
dev-test VIDEO:
	just dev-test {{VIDEO}}
upload-wandb VIDEO:
	uv run upload.py {{VIDEO}}
run-ssg:
	cp vqmtk/results/vqmcli_results.csv content/results.csv
	luasmith src/main.lua
upload-site:
	echo {{REMOTE_USERNAME}}
	scp -i ~/.ssh/site -r out/* {{REMOTE_USERNAME}}@{{REMOTE_IP}}:{{REMOTE_DIRECTORY}}/.
