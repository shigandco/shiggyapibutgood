#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2023 Linnea Gräf <nea@nea.moe>
#
# SPDX-License-Identifier: MIT

socat TCP4-LISTEN:${PORT-8080},fork EXEC:"$(dirname "$0")"/shiggy.sh
