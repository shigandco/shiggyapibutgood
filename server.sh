#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2023 Linnea Gräf <nea@nea.moe>
#
# SPDX-License-Identifier: MIT

socat -t5 TCP4-LISTEN:${PORT-8080},fork EXEC:"$(dirname "$0")"/shiggy.sh
