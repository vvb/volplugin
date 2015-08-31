start: install-ansible
	vagrant up

stop:
	vagrant destroy -f

restart: stop start

provision:
	vagrant provision

ssh:
	vagrant ssh mon0

golint:
	[ -n "`which golint`" ] || go get github.com/golang/lint/golint
	golint ./...


install-ansible:
	[ -n "`which ansible`" ] || pip install ansible

test: golint
	vagrant ssh mon0 -c 'sudo -i sh -c "cd /opt/golang/src/github.com/contiv/volplugin; godep go test -v ./..."'

build: golint
	vagrant ssh mon0 -c 'sudo -i sh -c "cd /opt/golang/src/github.com/contiv/volplugin; make run-build"'

run:
	vagrant ssh mon0 -c 'sudo -i sh -c "cd /opt/golang/src/github.com/contiv/volplugin; make run-build; (make volplugin-start &); make volmaster-start"'

run-volplugin:
	vagrant ssh mon0 -c 'sudo -i sh -c "cd /opt/golang/src/github.com/contiv/volplugin; make run-build volplugin-start"'

run-volmaster:
	vagrant ssh mon0 -c 'sudo -i sh -c "cd /opt/golang/src/github.com/contiv/volplugin; make run-build volmaster-start"'

run-build:
	godep go install -v ./volplugin/volplugin/ ./volmaster

container:
	vagrant ssh mon0 -c 'sudo docker run -it --volume-driver tenant1 -v tmp:/mnt ubuntu bash'

volplugin-start:
	pkill volplugin || exit 0
	sleep 1
	volplugin tenant1

volmaster-start:
	pkill volmaster || exit 0
	sleep 1
	volmaster /etc/volmaster.json

reflex:
	@echo 'To use this task, `go get github.com/cespare/reflex`'
	which reflex &>/dev/null && ulimit -n 2048 && reflex -r '.*\.go' make test

update-subtree:
	git subtree -P librbd pull https://github.com/contiv/librbd master
