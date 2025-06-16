---
draft: false
params:
  author: Sienna
  privacy: public
title: Developers
category: About
---

# Contributing Code

Governments and corporations that commissioned the same weaponized software used to surveil and control their populations are now weaponizing it against their own citizens. It is our turn to show them what we can do when we're set free to build our own weapons.

## Code of Ethics

Our core ethics can be found in our [Ethics Guide](/docs/ethics.md). Above and beyond that, we should also strive to abide by the Association of Computing Machinery's [Code of Ethics](https://www.acm.org/about/code-of-ethics). We are building a weapon designed to protect our communities and promote freedom. Therefore, we must treat it with the utmost care and respect.

If you do not believe you can help us navigate the nuances and complexity of building an intelligence platform by the people, for the people, that is okay! There are other ways you can get involved in our community and support our mission.

# Repository Architecture

We use a monorepo to manage our codebase. From the root of the repository:

* `backend-src`: Backend Rust & Typescript code used for the backend services.
* `frontend-src`: Frontend React Native & Expo code used for the frontend services.
* `docs`: Documentation for the project. These are what you see on the public website.
* `ops`: Operations & Infrastructure code used for the project.

# Bootstrapping Local Development

## Credentials

The only credential you will need is a Github Packages token.

## Installation

You will need:

* [`terraform`](https://www.terraform.io/downloads.html): for managing the infrastructure (it's not compatible with opentofu)
* [`overmind`](https://github.com/DarthSim/overmind): to connect to backend services sanely
* [`lima`](https://github.com/lima-vm/lima): for running the backend services
* [`docker`](https://docs.docker.com/get-docker/): for building the backend services
* [`rust`](https://www.rust-lang.org/tools/install): for building the backend services
* [`nvm`](https://github.com/nvm-sh/nvm) (and Node 22): for building the fronend services
* [`Expo`](https://expo.dev/): for compiling and running the frontend services
* [`xcode`](https://developer.apple.com/xcode/): for running the frontend services on iOS (can use a standalone device if you have windows/linux)
* [`android-studio`](https://developer.android.com/studio): for running the frontend services on Android (can use a standalone device if you have windows/linux)
* [`yarn`](https://yarnpkg.com/getting-started/install): for building the frontend services
* [`supabase-cli`](https://supabase.com/docs/guides/cli/installation): for pushing any necessary functions

There are a few recommended aliases use to save a whole lot of typing:

```sh
alias kctl='kubectl'
alias lctl='limactl'
alias tf='terraform'
```

So if you see the shorthand `kctl`, `lctl`, or `tf`, you know what it's for.

## Bootstrapping

Bootstrapping takes place in two separate places: the backend and the frontend. The backend is Supabase + Rust microservices running in a Kubernetes cluster. The frontend is Expo + React Native.

### Backend

We designed this to be as simple and straightforward as possible. Here are the steps to get started:

```sh
# clone
git clone git@github.com:siennathesane/f2.git
cd f2

# boot the VM
cat k3s.yml | lctl create --name k3s -
lctl start k3s
# you might need to modify your KUBECONFIG but it will tell you what you do.

# boot everything
cd ops/k3s
./bootstrap.sh dev
```

That will completely bootstrap the entire backend. If for some reason terraform fails, just run `./bootstrap.sh dev` again. If that doesn't work, just ping us on Discord.

There are also code generators that are needed for the backend services as well. For example, to generate any necessary protocol buffers, you will need `protoc`, the various `protoc-gen-*` plugins, and `buf`. You can find more details in the backend readme.

### Frontend

This is a fairly standard Expo app.

```sh
cd frontend-src

# install the deps
yarn install

# start the dev server
yarn start
```

Then you can choose to run the app on your device, in the Expo Go app on your phone, or the browser.

## Connecting to Everything

The absolute easiest way to connect to the backend is to use `overmind`. It will handle all of the backend service connections for you. In a separate terminal, run `overmind start -r all` to start the port forwarding.

The Supabase dashboard will be available at [http://localhost:3000](http://localhost:3000), and the backend data models will all be available at [http://localhost:8080/rest/v1/](http://localhost:8080/rest/v1/).

Again, if you get stuck, feel free to reach out to us on Discord ❤️
