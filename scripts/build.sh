#!/bin/bash

uvx --from mojo-compiler mojo package linux_raw -o linux_raw.mojopkg
uvx --from mojo-compiler mojo package mojix -o mojix.mojopkg
uvx --from mojo-compiler mojo package io_uring -o io_uring.mojopkg
