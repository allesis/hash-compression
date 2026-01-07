all VIDEO: (run VIDEO) (convert VIDEO) (test VIDEO)
run VIDEO:
	just rav1e/run {{VIDEO}}
convert VIDEO:
	just rav1d/convert {{VIDEO}}
test VIDEO:
	just vqmtk/test {{VIDEO}}
upload-wandb VIDEO:
	uv run upload.py {{VIDEO}}
dev-test VIDEO:
	just vqmtk/dev-test {{VIDEO}}


