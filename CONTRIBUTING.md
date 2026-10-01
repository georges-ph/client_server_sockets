# Contributing

## Setup

```
git clone https://github.com/georges-ph/client_server_sockets.git
cd client_server_sockets
dart pub get
```

## Before submitting a change

```
dart format .
dart analyze
dart test
```

Try the example too if your change touches `SocketClient`/`SocketServer` behavior (see the README's "Trying the example" section).

## Submitting

- Open a PR against `main` with a short description of what changed and why.
- Add a `CHANGELOG.md` entry under an `[Unreleased]` heading if the change is user-facing.
- Keep PRs focused — one change per PR is easier to review.
