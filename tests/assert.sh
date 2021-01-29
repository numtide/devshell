#!/usr/bin/env bash
# Copied from https://github.com/orangemug/bash-assert/blob/28a08c136196bd97d9e3724400aa9a07cd0e7da7/assert.sh
# License: The MIT License (MIT)
# Copyright (c) 2015 Jamie Blair

__assert ()
{
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  lineno=`caller 1`

  if [[ $# < 2 || $# > 4 ]]
  then
    num=`expr $# - 1`
    >&2 echo "ERR: assert require 1, 2 or 3 params, got $num"
    return $E_PARAM_ERR
  fi

  if [ $# -eq 2 ]; then
    cmd="check exit code: $?"

    if [ "$?" -eq 0 ]
    then
      success="true"
    else
      success="false"
    fi
  elif [ $# -eq 3 ]; then
    cmd="\"$2\" -eq \"$4\""

    if [ "$2" "$3" ]
    then
      success="true"
    else
      success="false"
    fi
  else
    cmd="\"$2\" $3 \"$4\""

    if [ "$2" "$3" "$4" ]
    then
      success="true"
    else
      success="false"
    fi
  fi

  if [ "$success" != "$1" ]
  then
    >&2 echo "Assertion failed:  \"$cmd\""
    >&2 echo "File \"$0\", line $lineno"
    return $E_ASSERT_FAILED
  fi
}

assert() {
  __assert "true" "$@";
  return $?
}

assert_fail() {
  __assert "false" "$@";
  return $?
}
