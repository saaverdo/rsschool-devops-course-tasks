#!/bin/bash

HOOK_NAME="pre-commit"
PROECT_DIR=$(git rev-parse --show-toplevel)
HOOK_DIR=${PROECT_DIR}/.git/hooks

if [[ ! -f "${HOOK_DIR}/${HOOK_NAME}" ]] && [[ -x "${HOOK_DIR}/${HOOK_NAME}" ]]; then
    mv "${HOOK_DIR}/${HOOK_NAME}" "${HOOK_DIR}/${HOOK_NAME}.local"
fi
ln -s -f "${PROECT_DIR}/.git_hooks/${HOOK_NAME}" "${HOOK_DIR}/${HOOK_NAME}"
