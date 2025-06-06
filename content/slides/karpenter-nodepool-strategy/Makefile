.PHONY: serve clean open

serve:
	podman run --name slidev \
	 --rm -it \
	 --user node \
	 -p 3030:3030 \
	 -v ${PWD}:/slidev \
	 tangramor/slidev:latest --per-slide

clean:
	podman rm -f slidev

open:
	open http://localhost:3030