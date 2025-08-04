# slides

Slides created using [marp][marp], a markdown presentation tool.

## Prerequisites

If you want to use [marp][marp], you need to install it first on your local machine.

Run this command to install [marp][marp] using the [brew](https://brew.sh) package manager:

```bash
brew install marp
```

## Usage

Convert slide deck into PDF using [marp][marp]:

```bash
docker run --rm --init -v $PWD:/home/marp/app/ -e LANG=$LANG marpteam/marp-cli slide-deck.md --pdf --allow-local-files
```

If you want to run [marp][marp] as server mode, you can use the following `docker` command:

```bash
# Server mode (Serve current directory in http://localhost:8080/)
docker run --rm --init -v $PWD:/home/marp/app -e LANG=$LANG -p 8080:8080 -p 37717:37717 marpteam/marp-cli -s .
```

Open the browser and go to [http://localhost:8080/](http://localhost:8080/) to see your presentation files made with [marp][marp].

[marp]: https://github.com/marp-team/marp-cli