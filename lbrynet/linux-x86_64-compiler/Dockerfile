FROM ubuntu:18.04

RUN	apt update && \
	apt install -y \
		python3-pip \
		python3.7 \
		python3.7-dev \
		build-essential \
		libssl-dev \
		libacl1-dev \
		liblz4-dev \
		libfuse-dev \
		fuse \
		pkg-config \
		fakeroot \
		git \
		zlib1g-dev \
		libbz2-dev \
		libncurses5-dev \
		libreadline-dev \
		liblzma-dev \
		libsqlite3-dev \
		zip \
		libffi-dev

RUN	update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1 && \
	update-alternatives --install /usr/bin/python python /usr/bin/python3.7 10 && \
	update-alternatives --config python && \
	python --version && \
	pip3 --version


RUN	python3.7 -m pip install -U pyinstaller cryptography aiohttp coincurve pbkdf2 cryptography attrs pylru 

##	Split container here.
RUN	git clone https://github.com/lbryio/lbry.git --depth 1 /lbry && \
	cd /lbry && \
	git clone https://github.com/lbryio/torba.git --depth 1 /lbry/torba

RUN	cd /lbry/torba && python3.7 -m pip install -e . && cd /lbry/ && \
	python3.7 scripts/set_build.py && \
	python3.7 -m pip install -e . && \
	pyinstaller -F -n lbrynet lbrynet/extras/cli.py

RUN	echo "checking contents of /lbry/dist/" && ls -lAh /lbry/dist/ && \
	echo "checking contents of /" && ls -lAh / && \
	echo "redundantly setting executable bit for good measure" && chmod +x /lbry/dist/lbrynet && \
	echo "compressing lbrynet x86_64 binary" && zip -j /lbry/dist/lbrynet-x86_64.zip /lbry/dist/lbrynet && \
	echo "creating /target/" && mkdir /target
COPY	./start.sh /usr/local/bin/start

RUN	/lbry/dist/lbrynet --version

CMD	start
